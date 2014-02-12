# -*- coding: utf-8 -*-
require 'rubygems'
require 'opencv'
include OpenCV

image = CvMat.load("error.jpg", CV_LOAD_IMAGE_GRAYSCALE)

### CvMat#adaptive_threshold メソッド ###
# グレースケール画像を2値画像へと変換する。第1引数で最大値を指定し、ピクセルを0か最大値のどちらかに振り分ける。
# threshold_type: CV_THRESH_BINARY => 通常, CV_THRESH_BINARY_INV => 反転
# adaptive_method: 閾値アルゴリズムを指定する。MEAN_CかGAUSSIAN_C
# block_size: 計算する近傍のサイズ
# param1: 閾値計算の際に引かれる定数????
result = image.adaptive_threshold(255, threshold_type: CV_THRESH_BINARY, adaptive_method: CV_ADAPTIVE_THRESH_MEAN_C, block_size: 5, param1: 5)
result2 = image.adaptive_threshold(255, threshold_type: CV_THRESH_BINARY_INV, adaptive_method: CV_ADAPTIVE_THRESH_MEAN_C, block_size: 5, param1: 5)

window = GUI::Window.new('MEAN_C')
window.show(result)
window2 = GUI::Window.new('MEAN_C(INV)')
window2.show(result2)

GUI::wait_key

