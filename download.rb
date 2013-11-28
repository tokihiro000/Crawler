# -*- coding: utf-8 -*-
=begin

ファイルをダウンロードするプログラム。リダイレクト対応

=end

require 'net/http'
require 'uri'

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
    puts response.value
  end
end


if __FILE__ == $0
  fetch('http://livedoor.blogimg.jp/news4vip2/imgs/9/6/96a36e43.jpg', './image/foo.jpg')
end
