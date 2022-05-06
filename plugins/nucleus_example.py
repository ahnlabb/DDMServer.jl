import numpy as np
import pandas as pd
from skimage.filters import threshold_otsu
from skimage.measure import label, regionprops_table
from math import isclose

def filter_objects_in_image(labeled_image, minsize, maxsize):
    values, counts = np.unique(labeled_image, return_counts=True)
    count_dict = dict(zip(values, counts))

    def object_filter(lb):
        if lb > 0:
            c = count_dict[lb]
            if minsize <= c <= maxsize:
                return c
        return 0
    
    return np.vectorize(object_filter)(labeled_image)

def simple_segmentation(img, minsize=150, maxsize=2000):
    binary = otsu_segment(img)
    labels = label(img)
    return filter_objects_in_image(labels)

def keyfun(data):
    x = data["image"].Pixels[:Plane][1][:PositionX]
    y = data["image"].Pixels[:Plane][1][:PositionY]
    return (x,y)

def keytest(kleft, kright):
    atol = 1.2
    return all(map(isclose, kleft, kright))

def analyze(image, config):
    # Segmentation parameters
    seg_params = config["segmentation"]

    # Segment and filter objects on size in image
    labeled_image = simple_segmentation(image, **seg_params)

    # Extract stats about our objects
    return pd.DataFrame(regionprops_table(image, labeled_image))

add_plugin(multipoint(analyze, "NucleusProperties", keyfun))
