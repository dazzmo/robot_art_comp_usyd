import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from skimage.filters import sobel
from skimage import morphology
from skimage.color import label2rgb
from scipy import ndimage as ndi


# http://scikit-image.org/docs/dev/auto_examples/xx_applications/plot_coins_segmentation.html

def rgb2gray(rgb):
    return np.dot(rgb[...,:3], [0.299, 0.587, 0.114])

img = mpimg.imread('bird.png')
# img = ndi.gaussian_filter(img, sigma=(2, 2, 0), order=0)    # Gaussian smoothing
img = ndi.median_filter(img, 5)
gray = rgb2gray(img)                        # convert to grayscale
# plt.imshow(gray, cmap = plt.get_cmap('gray'))
# plt.show()

gray = np.rint(255.0-gray*255.0)        # round to 0 - 255 values and invert
# print(gray)

elevation_map = sobel(gray)

# fig, ax = plt.subplots(figsize=(4, 3))
# ax.imshow(elevation_map, cmap=plt.cm.gray, interpolation='nearest')
# ax.set_title('elevation map')
# ax.axis('off')

# # create an array of integers, where the integer can range from 1 to 4
# markers = np.zeros_like(gray)
# for x in range(1,5):
#     threshold = 256*x/4 - 1
#     markers[gray < threshold] = markers[gray < threshold] + 1

markers = np.zeros_like(gray)
markers[gray < 30] = 1
markers[gray > 150] = 2
print(markers)

segmentation = morphology.watershed(elevation_map, markers)

segmentation = ndi.binary_fill_holes(segmentation - 1)
labeled_coins, _ = ndi.label(segmentation)
image_label_overlay = label2rgb(labeled_coins, image=gray)

fig, axes = plt.subplots(1, 2, figsize=(8, 3), sharey=True)
axes[0].imshow(gray, cmap=plt.cm.gray, interpolation='nearest')
axes[0].contour(segmentation, [0.5], linewidths=1.2, colors='y')
axes[1].imshow(image_label_overlay, interpolation='nearest')
plt.show()