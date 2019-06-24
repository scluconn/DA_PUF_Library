import numpy as np
import os

class IPUFLoader():

    def PhiStringToPhiArray(stringIN):
        phi=np.zeros(shape=len(stringIN))
        for i in range(0,len(stringIN)):
            if stringIN[i]=="m":
                phi[i]=-1.0
            elif stringIN[i]=="1":
                phi[i]=1.0
        return phi

    def LoadIPUFTrainingData(trainDir):
        trainImages = os.listdir(trainDir)
        count=0
        #Reading the train images
        tr_Images = []
        tr_Labels = []
        for trainImage in trainImages:
            count=count+1
            if(count % 1000 ==0):
                print(count)
            lbl = int(trainImage[0]); #int object
            f=open(trainDir+"\\"+trainImage,'r')
            phiString = f.readline()
            phiString=phiString.rstrip() #Remove /n /r type of white space from string 
            phiArray=IPUFLoader.PhiStringToPhiArray(phiString)
            tr_Images.append(phiArray) #adding the train image to list                        
            tr_Labels.append(lbl)   #adding the train label to list
            #phiString=trainImage[1:-4] #This cuts off the ".txt" part 
        print("length of tr_Images = " + str(len(tr_Images))) #3491
        print("length of tr_Labels = " + str(len(tr_Labels))) #3491
        return tr_Images, tr_Labels



