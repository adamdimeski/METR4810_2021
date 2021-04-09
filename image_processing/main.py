import cv2
import urllib.request
import numpy
from Site import Site
from matplotlib import pyplot as plt

lower_blue = numpy.array([115,30,30])
upper_blue = numpy.array([255,90,90])

lower_red = numpy.array([30,30,80])
upper_red = numpy.array([85,80,255]) #BGR colour thresholds -> colorizer.org

siteList = []

alpha = 1
# Contrast control (1.0-3.0)
beta = 50 # Brightness control (0-100)
#image = cv2.convertScaleAbs(image, alpha=alpha, beta=beta)

def captureImage():
    image = cv2.imread("capture.jpg", cv2.IMREAD_COLOR);
    return image
    #urllib.request.urlretrieve("http://192.168.137.150/capture?_cb=15/03/2021", "image.jpg")

def showImage(imageshow):
    cv2.imshow("image", imageshow)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def getBlueArea(rect):
    x,y,w,h = rect
    return (w*h)

def getBlueObjects(image):
    blueList = []
    mask_blue = cv2.inRange(image, lower_blue, upper_blue)
    showImage(mask_blue)
    binary_blue = cv2.morphologyEx(mask_blue, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (30, 30))) #closes holes

    edges_blue = cv2.Canny(binary_blue, 0, 100) #canny edge detector
    contours_blue, _ = cv2.findContours(edges_blue, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

    for c in contours_blue:
        rect = cv2.boundingRect(c)
        if (rect[2] < 10 or rect[3] < 10): continue
        x,y,w,h = rect
        blueList.append(rect)
        cv2.rectangle(image, (x, y), (x + w, y + h), (255, 0, 0), 2)
    blueList.sort(key=getBlueArea, reverse = True)
    print(len(blueList))
    for rect in blueList:
        if (len(siteList) == 0):
            siteList.append(Site(rect))
        else:
            foundSite = False
            for site in siteList:
                if(site.isInside(rect)):
                    print("hey")
                    site.addBlueObject(rect)
                    foundSite = True
                    continue
            if(foundSite == False):
                siteList.append(Site(rect))


def getRedObjects():
    mask_red = cv2.inRange(image, lower_red, upper_red) #creates a mask based on what colours have been thresholded
    showImage(mask_red)

    binary_red = cv2.morphologyEx(mask_red, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (30, 30))) #closes holes

    edges = cv2.Canny(binary_red, 0, 100) #canny edge detector
    contours_red, _ = cv2.findContours(edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    for c in contours_red:
        rect = cv2.boundingRect(c)
        x,y,w,h = rect
        print(x,y,w,h)
        cv2.rectangle(image, (x, y), (x + w, y + h), (0, 0, 255), 2)

#def getNavigation():
    #Returns location data based on red circle size, position and orientation

image = captureImage()
showImage(image)
getBlueObjects(image)
showImage(image)
print(len(siteList))
for site in siteList:
    print(site.meanH)
    #cv2.rectangle(image, (site.meanX, site.meanY), (site.meanX + site.meanW, site.meanY + site.meanH), (0, 255, 0), 2)
showImage(image)
