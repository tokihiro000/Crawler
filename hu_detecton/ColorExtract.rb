# -*- coding: utf-8 -*-
require 'rubygems'
require 'opencv'
include OpenCV


image = IplImage.load("sample.jpg")
#image2 = CvMat.load("sample.jpg", CV_LOAD_IMAGE_COLOR)
sc = CvScalar.new(100, 100, 0)
im_w = image.width
im_h = image.height
pixel = image[100, 100]
p image[100, 100][0]
p sc[0]

pixel = image[100, 100]
blue, green, red = pixel[0], pixel[1], pixel[2]
print "[", 100, ",", 100, "]  ", "blue = ", blue, ", green = ", green, ", red = ", red, "\n"

im_w.times do |x|
  im_h.times do |y|
    pixel = image[y, x]
    blue, green, red = pixel[0], pixel[1], pixel[2]
    if (240 < red) && (217 < green) && (green < 235) && (181 < blue) && (blue < 209)
      image[y, x] = sc
      puts "きた！"
    end
  end
end
image[100, 100][0]=0.0
image[100, 100][1]=0.0

window = GUI::Window.new('Image')
window.show(image)
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

