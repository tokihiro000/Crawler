require 'rubygems'
require 'opencv'
include OpenCV

mat = CvMat.new(3, 3, CV_8U, 1)
mat.set_data([1, 2, 3, 4, 5, 6, 7, 8, 9])
# mat #=> [1, 2, 3,
#          4, 5, 6,
#          7, 8, 9]

result = mat.threshold(4, 7, CV_THRESH_BINARY, true)

# result #=> [0, 0, 0,
#             0, 7, 7,
#             7, 7, 7]
p result
