# -*- coding: utf-8 -*-
=begin


参照:ser1zw's blog(http://ser1zw.hatenablog.com/entry/20110507/1304724698)

=end

require 'opencv'
include OpenCV

# Windowに描画領域を作成
window = GUI::Window.new('color check')
image_canvas = CvMat.load(ARGV[0])
hsv_image = image_canvas.BGR2HSV
window.show image_canvas

# マウスイベントの処理
point = nil
window.on_mouse{ |m|
  case m.event
  when :left_button_down # マウスドラッグで線の描画
    point = m
    print "m.x = ",  m.x, "m.y = ", m.y, "\n"
    pixel = image_canvas[m.y, m.x]
    blue, green, red = pixel[0], pixel[1], pixel[2]

    pixel_2 = hsv_image[m.y, m.x]
    hue, sat, val = pixel_2[0], pixel_2[1], pixel_2[2]

    print "blue = ",  blue, " green = ", green, " red =", red, "\n"
    print "hue = ",  hue, " sat = ", sat, " val =", val, "\n"
  end
  window.show image_canvas
}

# キー入力の処理
while key = GUI.wait_key
  next if key < 0 or key > 255
  case key.chr
  when "\e" # ESCキーで終了
    exit
  end
end
