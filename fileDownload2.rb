require 'net/http'
require 'uri'

Net::HTTP.version_1_2

uri  = URI("http://livedoor.4.blogimg.jp/news4vip2/imgs/9/6/96a36e43.jpg")
dest = "./image/foo.jpg"
response = ""


Net::HTTP.start(uri.host, uri.port) do |http|
  req = Net::HTTP::Get.new(uri.request_uri)
  #req.basic_auth 'tsun', 'dere'
  response = http.request(req)
end

p response
