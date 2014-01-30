# -*- coding: utf-8 -*-
=begin

文字列またはファイルのハッシュを計算するクラスです。
用途上16進数文字列を返すメソッドのみの実装です。

=end
require 'openssl'

class DigestClass

  def initialize(alg = "sha256")
    @dig = OpenSSL::Digest.new(alg)
  end

  #文字列のハッシュ
  def StringDigest(str)
    return @dig.hexdigest(str)
  end

  #ファイルのハッシュ
  def FileDigest(filename)
    File.open(filename){|f|
      while data = f.read(1024)
        @dig.update(data)
      end
    }
    return @dig.hexdigest
  end

end

if __FILE__ == $0
  plaintext = ARGV[0]
  dig = DigestClass.new()
  digest_text = dig.StringDigest(plaintext)
  puts digest_text
end
