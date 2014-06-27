# -*- coding: utf-8 -*-
=begin

initializeメソッドで指定したurlを始点として画像をかき集めるクローラです。
画像の保存先はデフォルトではカレント以下のimageディレクトリです。
インスタンス生成後はstartCrawlメソッドを呼ぶことでクロールを開始します。
(startCrawlメソッド以外はprivateです)
グローバル変数でアドレスを取り出す正規表現を定義していますが、勉強不足のため
完璧ではないです(泣)

=end

require "net/http"
require "uri"
load("rbt.rb")
load("CreateDigest.rb")
load("face_detection.rb")

$reg_absolute_img_path = /http:[^\:|^\"]*?(jpg|gif|png)/
# $reg_absolute_img_path = /http:[^\:|^\"]*?(jpg)/
$reg_relative_img_path = /\".*?(jpg|gif|png)/
$http_link = /http:[^\"]*?\"/
$http_sharp = /http:.*?#/
$last_path = /[^\/]+?\z/



$gallery_dir = "./image/human/"
$etc_dir = "./image/not_human/"
$image_dir = "./image/"


class Crawler

  def initialize(uri, max_img = 100)
    @ImgTag = Array.new
    @AnchorTag = Array.new
    @ImgArray = Array.new
    @LinkArray = Array.new
    @AccessedLinkTree = Red_Black_Tree.new
    @digest256 = DigestClass.new("sha256")
    @image_count = 0
    @max_img = max_img
    @first_uri = uri
    @uri_access_now = nil
  end

  #ここからprivateメソッド
  private
  #画像ファイルをダウンロードするメソッド。
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
      save_path = $image_dir + file_name
      File.open(save_path, "wb") do |file|
        file.write response.body
      end

      #人物ならhumanフォルダへ、それ以外ならnot_humanフォルダへ
      begin
        if faceDetection(save_path) == true
          new_save_path = $image_dir + "human/" + file_name
          File.rename(save_path, new_save_path)
        else
          new_save_path = $image_dir + "not_human/" + file_name
          File.rename(save_path, new_save_path)
        end
      rescue
        puts "invalid format image"
        return
      end
    when Net::HTTPRedirection
      puts response, " Redirect..."
      new_uri = response['location']
      if new_uri =~ $reg_absolute_img_path
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

  #httpでwebページへアクセスするメソッド。
  def getHttpResponse(uri_str, limit = 10)
    if limit == 0
      puts "Redirect too deep"
      return
    end

    begin
      response = Net::HTTP.get_response(URI.parse(uri_str))
    rescue
      puts "resoponse error"
      return
    end

    case response
    when Net::HTTPSuccess
      puts response, " http_success"

      # imgタグとaタグのみをレスポンスデータから抽出する
      reImg = /<img.*?>/
      print reImg, "\n"
      res = response.body

      if res == nil
        puts "response.body is nil"
        return
      end

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
      getHttpResponse(new_uri, limit - 1)
    when Net::HTTPClientError
      puts response, " HTTPClientError(getHttpResponse)"
    when Net::HTTPServerError
      puts response, "HTTPServerError(getHttpResponse)"
    else
      print response.value, ".\n"
    end
  end

  #抽出したアンカータグとイメージタグからアドレスを取り出すメソッ
  def tagRetrieve
    @ImgTag.each do |image|
      # 絶対パスの場合
      if image =~ $reg_absolute_img_path
        @ImgArray << $&
      # 相対パスの場合
      elsif image =~ $reg_relative_img_path
        relative_path = $&
        relative_path.slice!(0)
        img_uri = @uri_access_now.gsub($last_path, relative_path)
        @ImgArray << img_uri
      end
    end

    @AnchorTag.each do |link|
      if link =~ $reg_absolute_img_path
        @ImgArray << $&
        # 相対パスの場合
      elsif link =~ $reg_relative_img_path
        relative_path = $&
        relative_path.slice!(0)
        img_uri = @uri_access_now.gsub($last_path, relative_path)
        @ImgArray << img_uri
      end


      if link =~ $http_link
        tmp = $&
        link_uri = tmp.delete!("\"")
        #画像のurlがくる可能性があるので、その場合無視して次のループへ
        if link_uri =~ $reg_absolute_img_path
          next
        end

        #"#"がついてるurlはページが重複するので"#"以下を消していく。
        if link_uri =~ $http_sharp
          tmp = $&
          new_uri = tmp.delete!("\#")
          print "sharp is deleted = ", new_uri,"\n"
        else
          new_uri = link_uri
        end

        digest_text = @digest256.StringDigest(new_uri)
        #アクセスしことがあるアドレスかを調べる
        if @AccessedLinkTree[digest_text] == nil
            print "new url =", new_uri, "\n"
            @LinkArray.unshift(new_uri)
        end
      end

    end
    @ImgTag.clear
    @AnchorTag.clear
  end

  #ここからpublicメソッド
  public

  def startCrawl
    if @first_uri =~ /http:[^\"]*?/
      @LinkArray << @first_uri
    else
      puts "first uri is invalid"
      return nil
    end

    #既に存在しているファイル数を保存しておく。
    exist_image = Dir::entries($gallery_dir).size + Dir::entries($etc_dir).size

    while @LinkArray.length != 0
      @LinkArray.uniq!
      @uri_access_now = @LinkArray.pop
      print "this access == == ", @uri_access_now, "\n"
      getHttpResponse(@uri_access_now)

      #アクセスしたアドレスは赤黒木で保存しておく。keyはアドレスのsha256を計算した値とする。
      digest_text = @digest256.StringDigest(@uri_access_now)
      res = @AccessedLinkTree[digest_text] = @uri_access_now

      #アドレスを取り出す
      tagRetrieve

      @ImgArray.each do |image|
        column = image.split(/\//)
        getHttpImage(image, column.pop)
      end

      @ImgArray.clear

      #ダウンロードした画像数を確認して、設定を越えたらクロール終了
      num = Dir::entries($gallery_dir).size + Dir::entries($etc_dir).size
      if (num - exist_image) > @max_img
        return 0
        #exit(0)
      end
    end
  end
end

if __FILE__ == $0
  # cl = Crawler.new("http://gigazine.net/news/20120921-companion-tgs-2012/", 100)
  cl = Crawler.new("http://www.falcom.com/info/secret_giftwp/twitter/icon2014.html", 100)
  result = cl.startCrawl
  if result == 0
    puts "正常終了"
  else
    puts "異常終了"
  end
end
