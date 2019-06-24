import numpy
from IPUFLoader import IPUFLoader
import keras 
from keras.models import Sequential 
from keras.layers import Dense, Dropout, Flatten 
from keras.layers import Conv2D, MaxPooling2D 
from keras import backend as K 
import tensorflow as tf
import time
import winsound
import os
os.environ["CUDA_VISIBLE_DEVICES"]="1" #Make it so only the correct GPU is seen by the program 
#Configuration for the GPU 
config = tf.ConfigProto(allow_soft_placement = True)
config.gpu_options.allow_growth=True
sess = tf.Session(config=config)
keras.backend.set_session(sess)

phiLength=65
num_classes=2
batch_size = 128
epochs = 50



start = time.time()

#trainDir="C:\\Users\\Windows\\Desktop\\Kaleel\\PUF Work\\IPUFKerasTensorFlowV2\\Data64-7XOR\\Training"
#testDir="C:\\Users\\Windows\Desktop\\Kaleel\PUF Work\\IPUFKerasTensorFlowV2\\Data64-7XOR\\Testing"

trainDir="C:\\Users\\Windows\\Desktop\\Kaleel\\PUF Work\\Data64-4XOR\\Training"
testDir="C:\\Users\\Windows\\Desktop\\Kaleel\\PUF Work\\Data64-4XOR\\Testing"

tr_images, tr_labels=IPUFLoader.LoadIPUFTrainingData(trainDir)
test_images, test_labels=IPUFLoader.LoadIPUFTrainingData(testDir)

X_train=numpy.array(tr_images)
Y_train=numpy.array(tr_labels)

X_test=numpy.array(test_images)
Y_test=numpy.array(test_labels)
end = time.time()
print(end - start)
print("IPUF Data Loaded.")

numIterations=10 #How many times the attack is repeated for 
allAccuracies=[]

Y_train = keras.utils.to_categorical(Y_train, num_classes) 
Y_test = keras.utils.to_categorical(Y_test, num_classes) 

for iteration in range(0,10):
    with tf.device('/device:GPU:1'):
        
        model = Sequential() 
        model.add(Dense(100, input_dim=phiLength, activation='sigmoid'))
        model.add(Dense(60, input_dim=phiLength, activation='sigmoid'))
        model.add(Dense(20, input_dim=phiLength, activation='sigmoid'))
        model.add(Dense(num_classes, activation='softmax')) 

        print("\n" + "model.compile()") 
        model.compile(loss=keras.losses.categorical_crossentropy, 
                      optimizer=keras.optimizers.Adam(), 
                      metrics=['accuracy']) 

        print("\n" + "model.fit()") 
        #model.fit(X_train, Y_train, 
        #          batch_size=batch_size, 
        #          epochs=epochs, 
        #          verbose=1, 
        #          validation_data=(X_test, Y_test))
                  #shuffle=True)
        model.fit(X_train, Y_train, 
                  batch_size=batch_size, 
                  epochs=epochs, 
                  verbose=1)
        scoreTrain = model.evaluate(X_train, Y_train, verbose=0) 
        print('Train loss:', scoreTrain[0]) 
        print('Train accuracy:', scoreTrain[1])

        print("\n" + "model.evaluate()") 
        score = model.evaluate(X_test, Y_test, verbose=0) 
        print('Test loss:', score[0]) 
        print('Test accuracy:', score[1])
        allAccuracies.append(score[1])

print("All runs complete.")
avgAccuracy=0
for i in range(0, numIterations):
    avgAccuracy=avgAccuracy+allAccuracies[i]
avgAccuracy=avgAccuracy/float(numIterations)
print("The average accuracy is:")
print(avgAccuracy)
#fname = "C:\\Users\\kaleel\\Desktop\\complete.wav"
#winsound.PlaySound(fname, winsound.SND_FILENAME)
#x=4


