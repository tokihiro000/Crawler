# -*- coding: utf-8 -*-
require 'rubygems'
require 'opencv'
include OpenCV

# 画像をロード
img = IplImage.load('error.jpg')
print "img.roi = ", img.get_roi(), "\n"

# 顔検出に使うカスケードをロード
detector = CvHaarClassifierCascade::load('./haarcascades/haarcascade_frontalface_default.xml')
#detector = CvHaarClassifierCascade::load('haarcascade_frontalface_alt.xml')

count = 0
# 顔を検出して四角で囲む
detector.detect_objects(img) { |rect|
  count += 1
  puts count
  img.rectangle!(rect.top_left, rect.bottom_right, :color => CvColor::Red)
}

# ウィンドウを作って画像を表示
window = GUI::Window.new('Face Detection')
window.show(img)
GUI::wait_key

