# -*- coding: utf-8 -*-
require "net/http"
require "uri"

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
  #  p response.body

  #
  # imgタグとaタグのみをレスポンスデータから抽出する
  #
  reImg = /<img.*?>/
  str = response.body
  str.gsub(reImg) do |matched|
    ImgArray << matched
  end

  reA = /<a.*?>/
  str.gsub(reA) do |matched|
    LinkArray << matched
  end
}

http_img = /http.*?jpg/
ImgArray.each do |image|
  if image =~ http_img
    puts $&
  end
end

http_link = /http.*?\"/
LinkArray.each do |link|
  if link =~ http_link
    puts $&
  end
end
