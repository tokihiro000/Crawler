# -*- coding: utf-8 -*-
require "net/http"
require "uri"

$http_img = /http:.*?(jpg|gif|png)/
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
    new_uri = response['location']
    if new_uri =~ $http_img
      fetch(response['location'], save_path, limit - 1)
    else
      puts "download redirect error"
    end
  else
    print "not exist image ", response.value, ".\n"
  end
end

def fetch_post(uri_str, limit = 10)
    # You should choose better exception.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  response = Net::HTTP.get_response(URI.parse(uri_str))
  case response
  when Net::HTTPSuccess
    puts response, " download..."
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
      print "fetch post error", new_uri, "\n"
    end
  else
    print response.value, ".\n"
  end
end

def tag_retrieve
  src_img = /src\s*=\s*\".*?\"/
  ImgTag.each do |image|
    #    if image =~ $http_img
    if image =~ src_img
      tmp = $&
      if tmp =~ $http_img
        # if AccessedImgURI.find_index(tmp) == nil
        #   ImgArray << $&
        # end
        ImgArray << $&
      end
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

    if link =~ src_img
      tmp = $&
      if tmp =~ $http_img
        #   if AccessedImgURI.find_index(tmp) == nil
        #     #puts "まだダウンロードしてない画像です"
        #     ImgArray << $&
        #   end
        ImgArray << $&
      end
    end
  end

  ImgTag.clear
  LinkTag.clear
end


LinkArray << "http://gigazine.net/news/20120921-companion-tgs-2012/"
LinkArray << "http://image.search.biglobe.ne.jp/search?q=%E6%97%A9%E5%B7%9D%E7%80%AC%E9%87%8C%E5%A5%88&o_sf=0"
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
