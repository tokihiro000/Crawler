# -*- coding: utf-8 -*-
require 'rubygems'
require 'opencv'
include OpenCV

def faceDetection file_path
  # 画像をロード
  img = IplImage.load(file_path)

  # 顔検出に使うカスケードをロード
  detector = CvHaarClassifierCascade::load('./haarcascades/haarcascade_frontalface_default.xml')

  detector.detect_objects(img) { |x|
    return true
  }
  return false
end

if __FILE__ == $0
  if faceDetection('sample2.jpg') == true
    puts "人がいました！"
  else
    puts "人がいません。。。"
  end
end
