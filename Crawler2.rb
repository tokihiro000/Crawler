# -*- coding: utf-8 -*-
require "net/http"
require "uri"

$http_img = /http:[^\"]*?(jpg|gif|png)/
$http_link = /http:.*?\"/
ImgTag = Array.new
LinkTag = Array.new

ImgArray = Array.new
LinkArray = Array.new

#AccessedImgURI = Array.new
AccessedLinkURI = Array.new

imageDir = "./image/"


def fetch(uri_str, save_path, limit = 10)
  # You should choose better exception.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  #print "download fetch uri = ", uri_str, "\n"

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
    File.open(save_path, "wb") do |file|
      file.write response.body
    end
  when Net::HTTPRedirection
    puts response, " Redirect..."
    new_uri = response['location']
    if new_uri =~ $http_img
      fetch(response['location'], save_path, limit - 1)
    else
      puts "download redirect error"
    end
  when Net::HTTPClientError
    puts response, " HTTPClientError"
  when Net::HTTPServerError
    puts response "HTTPServerError"
  else
    print "not exist image ", response.value, ".\n"
  end
end

def fetch_post(uri_str, limit = 10)
    # You should choose better exception.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  #print "fetch_post uri = ", uri_str, "\n"
  response = Net::HTTP.get_response(URI.parse(uri_str))
  case response
  when Net::HTTPSuccess
    puts response, " http_success"
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
  when Net::HTTPRedirection
    new_uri = response['location']
    print response, " Redirect...", new_uri, ".\n"
    if new_uri =~ $http_link
      fetch_post(new_uri, limit - 1)
    else
      print "fetch post error ", new_uri, "\n"
    end
  when Net::HTTPClientError
    puts response, " HTTPClientError(fetch_post)"
  when Net::HTTPServerError
    puts response "HTTPServerError(fetch_post)"
  else
    print response.value, ".\n"
  end
end

def tag_retrieve
  #src_img = /src\s*=\s*\".*?\"/

  ImgTag.each do |image|
    #    if image =~ $http_img
    #if image =~ src_img
      #tmp = $&
      if image =~ $http_img
        # if AccessedImgURI.find_index(tmp) == nil
        #   ImgArray << $&
        # end
        puts $&
        ImgArray << $&

    end
  end


  LinkTag.each do |link|
    if link =~ $http_link
      tmp = $&
      tmp = tmp.delete!("\"")
      #とりあえずカンマを除いておく。ほんとは日本語の文字コードどーのこーのをどうにかしたい
      if AccessedLinkURI.find_index(tmp) == nil && tmp.include?(",") == false
        puts "まだアクセスしたこのないアドレスです"
        LinkArray << tmp
      end
    end

  #if link =~ src_img
      #tmp = $&
      if link =~ $http_img
        #   if AccessedImgURI.find_index(tmp) == nil
        #     #puts "まだダウンロードしてない画像です"
        #     ImgArray << $&
        #   end
        puts $&
        ImgArray << $&
      end
end

  ImgTag.clear
  LinkTag.clear
end


#LinkArray << "http://gigazine.net/news/20120921-companion-tgs-2012/"
LinkArray << "http://image.search.biglobe.ne.jp/search?q=%E5%A4%95%E7%84%BC%E3%81%91"
while LinkArray.length != 0
  link = LinkArray.pop
  fetch_post(link)
  AccessedLinkURI << link
  tag_retrieve

  ImgArray.each do |image|
    #AccessedImgURI << image
    column = image.split(/\//)
    save_path = imageDir + column.pop
    fetch(image, save_path)
  end
  ImgArray.clear
end
