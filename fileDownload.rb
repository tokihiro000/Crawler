require 'net/http'
require 'uri'

Net::HTTP.version_1_2

uri  = URI("http://livedoor.4.blogimg.jp/news4vip2/imgs/9/6/96a36e43.jpg")
dest = "./image/foo.jpg"

Net::HTTP.start(uri.host, uri.port) do |http|
  req = Net::HTTP::Get.new(uri.request_uri)
  #req.basic_auth 'tsun', 'dere'

  http.request(req) do |response|
    size = response["Content-Length"].to_f
    File.open(dest, "wb") do |file|
      response.read_body do |data|
        file.write data
        puts file.tell / size
      end
    end
  end
end
