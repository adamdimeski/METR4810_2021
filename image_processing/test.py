import cv2
import urllib.request
import numpy
from matplotlib import pyplot as plt


#urllib.request.urlretrieve("http://192.168.137.150/capture?_cb=15/03/2021", "image.jpg")

image = cv2.imread("capture.jpg", cv2.IMREAD_COLOR);
cv2.imshow("image", image)
cv2.waitKey(0)
cv2.destroyAllWindows()
alpha = 1
# Contrast control (1.0-3.0)
beta = 50 # Brightness control (0-100)


#Find first within blue box
lower_blue = numpy.array([115,30,30])
upper_blue = numpy.array([255,90,90])

mask_blue = cv2.inRange(image, lower_blue, upper_blue)

cv2.imshow("image", mask_blue)
cv2.waitKey(0)
cv2.destroyAllWindows()


binary_blue = cv2.morphologyEx(mask_blue, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (30, 30))) #closes holes

edges_blue = cv2.Canny(binary_blue, 0, 100) #canny edge detector
contours_blue, _ = cv2.findContours(edges_blue, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
for c in contours_blue:
    rect = cv2.boundingRect(c)
    if (rect[2] < 10 or rect[3] < 10): continue
    x,y,w,h = rect
    print(x,y,w,h)
    cv2.rectangle(image, (x, y), (x + w, y + h), (255, 0, 0), 2)

cv2.imshow("image", image)
cv2.waitKey(0)
cv2.destroyAllWindows()



#image = cv2.convertScaleAbs(image, alpha=alpha, beta=beta)
lower_red = numpy.array([30,30,80])
upper_red = numpy.array([85,80,255]) #BGR colour thresholds -> colorizer.org

mask_red = cv2.inRange(image, lower_red, upper_red) #creates a mask based on what colours have been thresholded
cv2.imshow("image", mask_red)
cv2.waitKey(0)
cv2.destroyAllWindows()
binary_red = cv2.morphologyEx(mask_red, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (30, 30))) #closes holes

edges = cv2.Canny(binary_red, 0, 100) #canny edge detector
contours_red, _ = cv2.findContours(edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
for c in contours_red:
    rect = cv2.boundingRect(c)
    x,y,w,h = rect
    print(x,y,w,h)
    cv2.rectangle(image, (x, y), (x + w, y + h), (0, 0, 255), 2)

cv2.imshow("image", image)
cv2.waitKey(0)
cv2.destroyAllWindows()

#def getImage():
    #put in code for gettign image

#def getBlueBoundingArea():
    #Searches image for blue bounding box

#def getRedObjects():
    #Code for getting red circles, inside blue bounding box

#def getLocation():
    #Returns location data based on red circle size, position and orientation

#(h, w, d) = image.shape
#print("width={}, height={}, depth={}".format(w, h, d))
#edges = cv2.Canny(image,50,200)

#plt.subplot(121),plt.imshow(image,cmap = 'gray')
#plt.title('Original Image'), plt.xticks([]), plt.yticks([])
#plt.subplot(122),plt.imshow(edges,cmap = 'gray')
#plt.title('Edge Image'), plt.xticks([]), plt.yticks([])

#plt.show()
