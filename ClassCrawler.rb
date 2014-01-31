# -*- coding: utf-8 -*-
=begin

initializeメソッドで指定したurlを始点として画像をかき集めるクローラです。
画像の保存先はデフォルトではカレント以下のimageディレクトリです。
インスタンス生成後はstartCrawlメソッドを呼ぶことでクロールを開始します。
(startCrawlメソッド以外はprivateです)
グローバル変数でアドレスを取り出す正規表現を定義していますが、勉強不足のため
完璧ではないかもしれないです(泣)

=end

require "net/http"
require "uri"
load("rbt.rb")
load("CreateDigest.rb")
load("face_detection.rb")

# $http_img = /http:[^\:|^\"]*?(jpg|gif|png)/
$http_img = /http:[^\:|^\"]*?(jpg)/
$http_link = /http:[^\"]*?\"/

class Crawler

  def initialize(uri, max_img = 100, img_dir = "./image/")
    @ImgTag = Array.new
    @AnchorTag = Array.new
    @ImgArray = Array.new
    @LinkArray = Array.new
    @AccessedLinkTree = Red_Black_Tree.new
    @digest256 = DigestClass.new("sha256")
    @max_img = max_img
    @image_dir = img_dir
    @LinkArray << uri
  end

  #ここからprivateメソッド
  private

  def getHttpImage(uri_str, file_name, limit = 10)
    if limit == 0
      puts "Redirect too deep"
      return
    end

    begin
      response = Net::HTTP.get_response(URI.parse(uri_str))
    rescue
      puts "response error"
      return
    end

    case response
    when Net::HTTPSuccess
      puts response, " download..."
      size = response["Content-Length"].to_f
      save_path = @image_dir + file_name
      File.open(save_path, "wb") do |file|
        file.write response.body
      end

      #人物ならhumanフォルダへ、それ以外ならnot_humanフォルダへ
      if faceDetection(save_path) == true
        new_save_path = @image_dir + "human/" + file_name
        File.rename(save_path, new_save_path)
      else
        new_save_path = @image_dir + "not_human/" + file_name
        File.rename(save_path, new_save_path)
      end
    when Net::HTTPRedirection
      puts response, " Redirect..."
      new_uri = response['location']
      if new_uri =~ $http_img
        getHttpImage(response['location'], file_name, limit - 1)
      else
        puts "download redirect error"
      end
    when Net::HTTPClientError
      puts response, " HTTPClientError"
    when Net::HTTPServerError
      puts response, "HTTPServerError"
    else
      print "not exist image ", response.value, ".\n"
    end
  end

  def getHttpResponse(uri_str, limit = 10)
    if limit == 0
      puts "Redirect too deep"
      return
    end

    response = Net::HTTP.get_response(URI.parse(uri_str))
    case response
    when Net::HTTPSuccess
      puts response, " http_success"

      # imgタグとaタグのみをレスポンスデータから抽出する
      reImg = /<img.*?>/
      res = response.body
      res.gsub(reImg) do |matched|
        @ImgTag << matched
      end

      reA = /<a.*?>/
      res.gsub(reA) do |matched|
        @AnchorTag << matched
      end
    when Net::HTTPRedirection
      new_uri = response['location']
      print response, " Redirect...", new_uri, ".\n"
      if new_uri =~ $http_link
        getHttpResponse(new_uri, limit - 1)
      else
        print "getHttpImage post error ", new_uri, "\n"
      end
    when Net::HTTPClientError
      puts response, " HTTPClientError(getHttpResponse)"
    when Net::HTTPServerError
      puts response, "HTTPServerError(getHttpResponse)"
    else
      print response.value, ".\n"
    end
  end

  def tagRetrieve
    @ImgTag.each do |image|
      if image =~ $http_img
        puts $&
        @ImgArray << $&
      end
    end

    @AnchorTag.each do |link|
      if link =~ $http_link
        tmp = $&
        link_uri = tmp.delete!("\"")
        digest_text = @digest256.StringDigest(link_uri)

        #アクセスしことがあるアドレスかを調べる
        if @AccessedLinkTree[digest_text] == nil
          puts "まだアクセスしたことのないアドレスです"
          @LinkArray.unshift(link_uri)
          @LinkArray.uniq!
        end
      end

      if link =~ $http_img
        puts $&
        @ImgArray << $&
      end
    end
    @ImgTag.clear
    @AnchorTag.clear
  end

  #ここからpublicメソッド
  public

  def startCrawl
    image_count = 0
    while @LinkArray.length != 0
      link = @LinkArray.pop
      getHttpResponse(link)
      digest_text = @digest256.StringDigest(link)
      res = @AccessedLinkTree[digest_text] = link
      tagRetrieve

      @ImgArray.each do |image|
        column = image.split(/\//)
        #file_name = @image_dir + column.pop
        getHttpImage(image, column.pop)
        image_count += 1
      end

      @ImgArray.clear
      if image_count  > @max_img
        puts image_count
        exit(0)
      end
    end
  end
end

if __FILE__ == $0
  #cl = Crawler.new("http://gigazine.net/news/20120921-companion-tgs-2012/", 1000)
  cl = Crawler.new("http://burusoku-vip.com/archives/1711144.html", 1000)
  cl.startCrawl
end
