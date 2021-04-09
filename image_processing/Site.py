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
        x,y,w,h = rect
        self.blueList.append((x,y,w,h))

    def addRedObject(self, rect):
        x,y,w,h = rect
        self.redList.append(x,y,w,h)

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

    def isInside(self,rect):
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
                if (x >= x2 and x <= x2 + w2 and y >= y2 and y <= y2 + h2):
                    retVal = True
            return retVal

    def calculateWeight(self):
        self.weight = 1
        if(self.redList.len() == 0 or self.redList.len() > 2):
            self.weight -= 0.5


    def toString(self):
        return ("X={}, Y={}, W={}, H={}, Weight={}, blueListSize={}".format(self.meanX, self.meanY, self.meanW, self.meanH, self.weight, len(self.blueList)))
