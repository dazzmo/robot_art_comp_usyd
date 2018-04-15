import matplotlib.pyplot as plt
from skimage import io, color
from scipy import ndimage
from skimage.filters import threshold_otsu
import skimage.morphology as morph
from skimage.measure import label
import numpy as np

# https://carpefridiem.wordpress.com/2015/11/16/basic-image-segmentation-using-python-and-scikit-image/

WHITE_THRESHOLD = 0.95


def plot_image(data, title):
    plt.figure(figsize=(7, 7))
    io.imshow(data)
    plt.axis('off')
    plt.title(title)
    plt.show()


def normalise(n, input_min, input_max):
    return (n - input_min)/(input_max - input_min)

img = io.imread('bird.png')
img = ndimage.median_filter(img, 7)   # filter image
img = ndimage.gaussian_filter(img, sigma=(2, 2, 0), order=0)
img = color.rgb2gray(img)             # convert to greyscale
# plot_image(img, 'Grayscale')

n_colours = 2
strel = morph.disk(2)
strel2 = morph.disk(4)
for x in range(0, n_colours):

    lower_limit = WHITE_THRESHOLD*x/n_colours
    upper_limit = WHITE_THRESHOLD*(x + 1)/n_colours

    img_thresholded = np.array(img) # set pixels too white or too black to the white threshold
    img_thresholded[img < lower_limit] = WHITE_THRESHOLD
    img_thresholded[img > upper_limit] = WHITE_THRESHOLD

    img_new = normalise(img_thresholded, lower_limit, upper_limit)
    img_new[img_new < 0.0] = 0.0
    img_new[img_new > 1.0] = 1.0
    plot_image(img_new, str(n_colours))

    img_otsu = threshold_otsu(img_new)
    img_bw = img_new < img_otsu
    img_dilated = morph.dilation(img_bw, strel)
    plot_image(img_dilated, 'dilated')
    labels = label(img_dilated)
    plot_image(color.label2rgb(labels), str(n_colours) + ' segments')

    img_dilated = morph.dilation(img_dilated, strel2)
    # print(img_dilated)
    img[img_dilated] = 1.0

    # TODO: remove the previous segment in next iteration
    # TODO: remove islands
