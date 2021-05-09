import math

class Site:

    def __init__(self, rect):
        self.blueList= []
        self.redList = []
        self.weight = 0
        self.meanX = 0
        self.meanY = 0
        self.meanW = 0
        self.meanH = 0
        self.addBlueObject(rect)
        self.calculateMean()

    def addBlueObject(self, rect):
        self.blueList.append(rect)

    def addRedObject(self, rect):
        self.redList.append(rect)

    def calculateMean(self):
        self.meanX = 0
        self.meanY = 0
        self.meanW = 0
        self.meanH = 0
        for rect in self.blueList:
            x,y,w,h = rect
            self.meanX += x
            self.meanY += y
            self.meanW += w
            self.meanH += h
        self.meanX = self.meanX / len(self.blueList)
        self.meanY = self.meanY / len(self.blueList)
        self.meanW = self.meanW / len(self.blueList)
        self.meanH = self.meanH / len(self.blueList)

    def calculateDistance(self,rect):
        x,y,w,h = rect
        distX = (self.meanX + (self.meanW/2)) - (x + (w/2))
        distY = (self.meanY + (self.meanH/2)) - (y + (h/2))
        dist = math.sqrt(math.pow(distX, 2) + math.pow(distY,2))
        return dist

    def isInside(self,rect):
        #checks for inside mean box, completely inside and partially inside
        self.calculateMean()
        x,y,w,h = rect
        #print("----------------------------")
        #print(self.toString())
        #print("x={}, y={}, w={}, h={}".format(x,y,w,h))
        if (x >= self.meanX and x <= self.meanX + self.meanW and y >= self.meanY and y <= self.meanY + self.meanH):
            return True
        else:
            retVal = False
            for rect2 in self.blueList:
                x2,y2,w2,h2 = rect2
                if (x >= x2 and x <= (x2 + w2) and y >= y2 and y <= (y2 + h2)):
                    #completely inside
                    retVal = True
                elif((x+w) >= x2 and (x+w) <= (x2+w2) and y > y2 and y < (y2+h2)):
                    #right-top corner
                    retVal = True
                elif((x) >= x2 and (x) <= (x2+w2) and y > y2 and y < (y2+h2)):
                    #left-top corner
                    retVal = True
                elif((x+w) >= x2 and (x+w) <= (x2+w2) and (y+h) > y2 and (y+h) < (y2+h2)):
                    #right-bottom corner
                    retVal = True
                elif((x) >= x2 and (x) <= (x2+w2) and (y+h) > y2 and (y+h) < (y2+h2)):
                    #left-bottom corner
                    retVal = True
            return retVal

    def getGeo(self):
        geo = self.meanH / self.meanW
        if(geo < 1):
            geo = 1.0/geo;
        return geo

    def calculateWeight(self):
        self.weight = 1
        if(self.redList.len() == 0 or self.redList.len() > 2):
            self.weight -= 0.5


    def toString(self):
        return ("X={}, Y={}, W={}, H={}, Weight={}, blueListSize={}".format(self.meanX, self.meanY, self.meanW, self.meanH, self.weight, len(self.blueList)))
