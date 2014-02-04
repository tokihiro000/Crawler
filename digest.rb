# -*- coding: utf-8 -*-
require 'openssl'

class DigestClass

  def initialize(alg = "sha256")
    @digest = OpenSSL::Digest.new(alg)
  end

  #文字列のハッシュ
  def StringDigest(str)
    return @digest.hexdigest(str)
  end

  #ファイルのハッシュ
  def FileDigest(filename)
    File.open(filename){|f|
      while data = f.read(1024)
        @digest.update(data)
      end
    }
    return @digest.hexdigest
  end

end

if __FILE__ == $0
  plaintext = ARGV[0]
  dig = DigestClass.new()
  digest_text = dig.StringDigest(plaintext)
  puts digest_text
end
