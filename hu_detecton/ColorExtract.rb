# -*- coding: utf-8 -*-
require 'rubygems'
require 'opencv'
include OpenCV


original_image = IplImage.load(ARGV[0])

image = original_image.copy

sc = CvScalar.new(255, 255, 255)
sc_b = CvScalar.new(0, 0, 0)

im_w = image.width
im_h = image.height

hsv_image = image.BGR2HSV
im_w.times do |x|
  im_h.times do |y|
    pixel = hsv_image[y, x]
    hue, saturation, value = pixel[0], pixel[1], pixel[2]
    #if hue >= 0 && hue <= 15 && saturation >= 50 && saturation <= 255 && value >= 50 && value <= 255
    if hue > 5 && hue <= 20 && saturation >= 10 && saturation <= 200 && value >= 110 && value <= 255
      # オレンジの壁をはじく
      if (value >= 230 && saturation >= 130) || (value >= 250 && saturation <= 30)
        # 人じゃない
        image[y, x] = sc_b
      else
        #image[y, x] = sc
      end
    else
      image[y, x] = sc_b
    end
  end
end


window = GUI::Window.new('Image')
window.show(image)

window2 = GUI::Window.new('original_Image')
window2.show(original_image)


GUI::wait_key

# hash = Hash.new
# im_w.times do |x|
#   im_h.times do |y|
#     if hash[image[y, x]] == nil
#       hash[image[y, x]] = 0
#     else
#       hash[image[y, x]] += 1
#     end
#   end
# end

