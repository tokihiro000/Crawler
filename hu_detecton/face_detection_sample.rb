# -*- coding: utf-8 -*-
require 'rubygems'
require 'opencv'
include OpenCV

# 画像をロード
img = IplImage.load('sample.jpg')

# 顔検出に使うカスケードをロード
detector = CvHaarClassifierCascade::load('/usr/local/Cellar/opencv/2.4.7.1/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml')
#detector = CvHaarClassifierCascade::load('haarcascade_frontalface_alt.xml')

# 顔を検出して四角で囲む
detector.detect_objects(img) { |rect|
  img.rectangle!(rect.top_left, rect.bottom_right, :color => CvColor::Red)
}

# ウィンドウを作って画像を表示
window = GUI::Window.new('Face Detection')
window.show(img)
GUI::wait_key

