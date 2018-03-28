from skimage import io, color
import matplotlib.pyplot as plt
import skimage.morphology as morph
from skimage.measure import label
from skimage.filters import threshold_otsu
import numpy as np
from scipy import ndimage

# https://carpefridiem.wordpress.com/2015/11/16/basic-image-segmentation-using-python-and-scikit-image/

def plot_image(data, title):
    plt.figure(figsize=(7,7))
    io.imshow(data)
    plt.axis('off')
    plt.title(title)
    plt.show()

bird = io.imread('flower.jpg')
# plot_image(bird, 'Original')
bird = ndimage.median_filter(bird, 4)   # filter image
bird = color.rgb2gray(bird)             # convert to greyscale
# plot_image(bird, 'Grayscale')
# bird = np.rint(1.0-bird)
Thresh = threshold_otsu(bird)
picBW = bird < Thresh
# plot_image(picBW, "B&amp;amp;W")
# Strel = morph.disk(2)
# Strel2 = morph.disk(5)
# plt.figure(figsize=(7,7))
# plt.subplot(131)
# plt.imshow(Strel)
# plt.title("2-Pixel Radius Disk Element")
# plt.subplot(133)
# plt.imshow(Strel2)
# plt.title("5-Pixel Radius Disk Element")
# plt.show()
# BWimg_dil = morph.dilation(picBW,Strel)
# plot_image(BWimg_dil, "Dilated")
# BWimg_close = morph.closing(BWimg_dil,Strel2)
# plot_image(BWimg_close, "Closed")
L = label(picBW)
plot_image(color.label2rgb(L), 'Labeled Regions')