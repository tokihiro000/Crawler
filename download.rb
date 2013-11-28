require 'open-uri'
open("http://tokihiro-k.hatenablog.com/entry/2013/11/08/192911") {|f|
  f.each_line {|line| p line}
}
