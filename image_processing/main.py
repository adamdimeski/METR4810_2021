import cv2
import urllib.request
import numpy
from Site import Site
from matplotlib import pyplot as pl
from math import exp, pow, sqrt

lower_blue = numpy.array([115,30,30])
upper_blue = numpy.array([255,90,90])

lower_red = numpy.array([30,30,80])
upper_red = numpy.array([85,80,255]) #BGR colour thresholds -> colorizer.org
#lower_red = numpy.array([30,30,50])
#upper_red = numpy.array([128,128,255]) #BGR colour thresholds -> colorizer.org

siteList = []

alpha = 1
# Contrast control (1.0-3.0)
beta = 50 # Brightness control (0-100)
#image = cv2.convertScaleAbs(image, alpha=alpha, beta=beta)
altitude = 10

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
        #cv2.rectangle(image, (x, y), (x + w, y + h), (255, 0, 0), 2)
    blueList.sort(key=getBlueArea, reverse = True)
    for rect in blueList:
        if (len(siteList) == 0):
            siteList.append(Site(rect))
        else:
            foundSite = False
            for site in siteList:
                if(site.isInside(rect)):
                    site.addBlueObject(rect)
                    foundSite = True
                    continue
            if(foundSite == False):
                siteList.append(Site(rect))

def getSiteArea(height):
    return (50*50)

def getHeight(w,h):
    size = (w + h) /2
    return (24111 * math.pow(size, -0.972))

def getBlueArea(height):
    #Use this this to check when to discard to small area bounding boxes
    rect = (0,0,0,0)
    return rect

def getRedArea(height):
    rect = (0,0,0,0)
    return rect

def filterSites():
    #check geometry
    #check if too small
    for site in reversed(siteList):
        site.calculateMean()

        if(site.getGeo() > 3):
            siteList.remove(site)
        elif((site.meanW*site.meanH) < getSiteArea(10)):
            siteList.remove(site)

    iRange = len(siteList)-1
    jRange = len(siteList)-2
    for i in range(0, iRange):
        for j in range(1, jRange):
            site = siteList[i]
            site2 = siteList[j]
            site2.calculateMean()
            rect = (site2.meanX, site2.meanY, site2.meanW, site2.meanH)
            if(site.isInside(rect)):
                try:
                    site.blueList.extend(site2.blueList)
                    site.redList.extend(site2.redList)
                    siteList.remove(site2)
                    i += 1
                    j += 1
                    iRange -= 1
                    jRange -= 1
                    continue
                except:
                    print("error")



def getRedObjects(image):
    redList = []
    mask_red = cv2.inRange(image, lower_red, upper_red) #creates a mask based on what colours have been thresholded
    showImage(mask_red)

    binary_red = cv2.morphologyEx(mask_red, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (30, 30))) #closes holes

    edges = cv2.Canny(binary_red, 0, 100) #canny edge detector
    contours_red, _ = cv2.findContours(edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    for c in contours_red:
        rect = cv2.boundingRect(c)
        x,y,w,h = rect
        if(altitude > 8 and w*h > 25*25): continue
        #print("X={}, Y={}, W={}, H={}".format(x,y,w,h))
        redList.append(rect)
        cv2.rectangle(image, (x, y), (x + w, y + h), (0, 0, 255), 2)
    for rect in redList:
        bestSite = None
        for site in siteList:
            if(bestSite == None):
                bestSite = site
            else:
                if(site.isInside(rect)):
                    bestSite = site
                #elif(site.calculateDistance(rect) < bestSite.calculateDistance(rect)):
                    #bestSite = site
        bestSite.addRedObject(rect)
#def getNavigation():
    #Returns location data based on red circle size, position and orientation
def showSites(color):
    bestSite = None
    for site in siteList:
        site.calculateMean()
        x = int(site.meanX)
        y = int(site.meanY)
        w = int(site.meanW)
        h = int(site.meanH)
        if(bestSite == None):
            bestSite = site
        else:
            if(len(site.redList) < len(bestSite.redList) and len(site.redList) > 1):
                bestSite = site
        cv2.rectangle(image, (x, y), (x + w, y + h), color, 2)
        print("X={}, Y={}, W={}, H={}, NumBlueObjs={}, NumRedObjects={}".format(x,y,w,h,len(site.blueList), len(site.redList)))
    x = int(bestSite.meanX)
    y = int(bestSite.meanY)
    w = int(bestSite.meanW)
    h = int(bestSite.meanH)
    cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
    print("Preferred Site X={}, Y={}, W={}, H={}, NumBlueObjs={}, NumRedObjects={}".format(x,y,w,h,len(bestSite.blueList), len(bestSite.redList)))
image = captureImage()
showImage(image)
getBlueObjects(image)
filterSites()
print(len(siteList))
getRedObjects(image)
showImage(image)
showSites((1,1,1))
showImage(image)
