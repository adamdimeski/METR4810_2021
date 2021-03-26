import cv2
import urllib.request
import numpy
from matplotlib import pyplot as plt


#urllib.request.urlretrieve("http://192.168.137.150/capture?_cb=15/03/2021", "image.jpg")

image = cv2.imread("imagec2.jpg", cv2.IMREAD_COLOR);
cv2.imshow("image", image)
cv2.waitKey(0)
cv2.destroyAllWindows()
alpha = 1
# Contrast control (1.0-3.0)
beta = 50 # Brightness control (0-100)

#image = cv2.convertScaleAbs(image, alpha=alpha, beta=beta)
lower_red = numpy.array([30,30,87])
upper_red = numpy.array([85,80,255]) #BGR colour thresholds -> colorizer.org

mask = cv2.inRange(image, lower_red, upper_red) #creates a mask based on what colours have been thresholded
binary = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (30, 30))) #closes holes

edges = cv2.Canny(binary, 0, 100) #canny edge detector
contours, _ = cv2.findContours(edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
for c in contours:
    rect = cv2.boundingRect(c)
    if rect[2] < 15 or rect[3] < 15: continue
    x,y,w,h = rect
    print(x,y,w,h)
    cv2.rectangle(image, (x, y), (x + w, y + h), (0, 0, 255), 2)

cv2.imshow("image", image)
cv2.waitKey(0)
cv2.destroyAllWindows()

#(h, w, d) = image.shape
#print("width={}, height={}, depth={}".format(w, h, d))
#edges = cv2.Canny(image,50,200)

#plt.subplot(121),plt.imshow(image,cmap = 'gray')
#plt.title('Original Image'), plt.xticks([]), plt.yticks([])
#plt.subplot(122),plt.imshow(edges,cmap = 'gray')
#plt.title('Edge Image'), plt.xticks([]), plt.yticks([])

#plt.show()
