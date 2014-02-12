# -*- coding: utf-8 -*-
require 'rubygems'
require 'opencv'
include OpenCV

# 画像をロード
img = IplImage.load('syugo2.jpg')

# 体検出に使うカスケードをロード
detector = CvHaarClassifierCascade::load('/usr/local/Cellar/opencv/2.4.7.1/share/OpenCV/haarcascades/haarcascade_mcs_upperbody.xml')
#detector = CvHaarClassifierCascade::load('haarcascade_frontalface_alt.xml')

# 全身を検出して四角で囲む
count = 0
detector.detect_objects(img) { |rect|
  count += 1
  img.rectangle!(rect.top_left, rect.bottom_right, :color => CvColor::Red)
}

print "合計", count, "個の人がいます\n"
# ウィンドウを作って画像を表示
window = GUI::Window.new('Face Detection')
window.show(img)
GUI::wait_key

