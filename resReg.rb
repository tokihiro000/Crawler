# -*- coding: utf-8 -*-
require "net/http"
require "uri"

ImgTag = Array.new
LinkTag = Array.new

ImgArray = Array.new
LinkArray = Array.new

def ImgLinkOpt str
  re = /http:\/\/livedoor\..*?\/news4vip2\/.*?/
  if str =~ re
    str = str.gsub(/http:\/\/livedoor\./, 'http://livedoor.4.')
  end
  return str
end



uri = URI.parse("http://news4vip.livedoor.biz/");
#uri = URI.parse("http://livedoor.4.blogimg.jp/news4vip2/imgs/9/6/96a36e43.jpg")
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

http_img = /http.*?jpg/
ImgTag.each do |image|
  if image =~ http_img
    tmp = $&
    tmp = ImgLinkOpt tmp
    ImgArray << tmp
  end
end

http_link = /http.*?\"/
LinkTag.each do |link|
  if link =~ http_link
    tmp = $&
    LinkArray << tmp.delete!("\"")
  end
end

ImgArray.each do |image|
  puts image
end

LinkArray.each do |link|
  puts link
end


