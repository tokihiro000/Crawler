# -*- coding: utf-8 -*-
require "net/http"
require "uri"
require './download.rb'

ImgTag = Array.new
LinkTag = Array.new

ImgArray = Array.new
LinkArray = Array.new

AccessedImgURI = Array.new
AccessedLinkURI = Array.new

imageDir = "./image/"


def fetch(uri_str, save_path, limit = 10)
  # You should choose better exception.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  response = Net::HTTP.get_response(URI.parse(uri_str))
  case response
  when Net::HTTPSuccess
    puts response, " download..."
    size = response["Content-Length"].to_f
    File.open(save_path, "wb") do |file|
      file.write response.body
    end
  when Net::HTTPRedirection
    puts response, " Redirect..."
    fetch(response['location'], save_path, limit - 1)
  else
    print "not exist image ", response.value, ".\n"
  end
end


def http_post(str_uri)
  uri = URI.parse(str_uri);
  Net::HTTP.start(uri.host, uri.port){|http|
    #ヘッダー部
    header = {
      "user-agent" => "Ruby/#{RUBY_VERSION} MyHttpClient"
    }
    #ボディ部
    body = "id=1&name=name"
    #送信
    response = http.post(uri.path, body, header)
    print  "http_post[response] = ", response, ".\n"

    #  p response.body

    #
    # imgタグとaタグのみをレスポンスデータから抽出する
    #
    reImg = /<img.*?>/
    res = response.body
    res.gsub(reImg) do |matched|
      ImgTag << matched
    end

    reA = /<a.*?>/
    res.gsub(reA) do |matched|
      LinkTag << matched
    end
  }
end

def tag_retrieve
  http_img = /http:.*?(jpg|gif|png)/
  http_link = /http:.*?\"/

  ImgTag.each do |image|
    if image =~ http_img
      tmp = $&
      if AccessedImgURI.find_index(tmp) == nil
        #puts "まだダウンロードしてない画像です"
        ImgArray << $&
      end
    end
  end

  LinkTag.each do |link|
    if link =~ http_link
      tmp = $&
      tmp = tmp.delete!("\"")
      #とりあえずカンマを除いておく。ほんとは日本語の文字コードどーのこーのをどうにかしたい
      if AccessedLinkURI.find_index(tmp) == nil && tmp.include?(",") == false
        #puts "まだアクセスしたこのないアドレスです"
        LinkArray << tmp
      end
    end
  end

  ImgTag.clear
  LinkTag.clear
end


#LinkArray << "http://news4vip.livedoor.biz/"
LinkArray << "http://blog.livedoor.jp/nemusoku/archives/30683412.html"
while LinkArray.length != 0
  link = LinkArray.pop
  http_post(link)
  AccessedLinkURI << link
  tag_retrieve

  ImgArray.each do |image|
    AccessedImgURI << image
    column = image.split(/\//)
    save_path = imageDir + column.pop
    fetch(image, save_path)
  end
  ImgArray.clear

  if AccessedImgURI.length > 200
    exit
  end
end
