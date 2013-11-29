# -*- coding: utf-8 -*-
require "net/http"
require "uri"
require './download.rb'

ImgTag = Array.new
LinkTag = Array.new

ImgArray = Array.new
LinkArray = Array.new

uri = URI.parse("http://news4vip.livedoor.biz/");
Net::HTTP.start(uri.host, uri.port){|http|
  #ヘッダー部
  header = {
    "user-agent" => "Ruby/#{RUBY_VERSION} MyHttpClient"
  }
  #ボディ部
  body = "id=1&name=name"
  #送信
  response = http.post(uri.path, body, header)
  p response
  #p response['location']
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

http_img = /http:.*?(jpg|gif|png)/
ImgTag.each do |image|
  if image =~ http_img
    ImgArray << $&
  end
end

http_link = /http:.*?\"/
LinkTag.each do |link|
  if link =~ http_link
    tmp = $&
    LinkArray << tmp.delete!("\"")
  end
end


ImageDir = "./image/"
ImgArray.each do |image|
  column = image.split(/\//)
  save_path = ImageDir + column.pop
  fetch(image, save_path)
end


