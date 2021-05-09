import cv2
from matplotlib import pyplot as pl
from math import exp

ambientLight = 0

def calculateAmbient(image):
    return cv2.mean(image)

def initialCalibrate(imageCheck, backgroundImage, rect1, rect2):

    ambientLight = calculateAmbient(imageCheck)/2 + calculateAmbient(backgroundImage)/2
    b,g,r = cv2.split(imageCheck)
    #saturate colours based on ambient ambient
    #find for colours that best adjust reduce amount of objects
    image = cv2.merge((b,g,r))


def calibrate(image):
    return image
