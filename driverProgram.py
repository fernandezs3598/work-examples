#!/home/group9/.virtualenvs/py3cv4/bin/python

import time
from typing import Counter
import aimCameras as camera
import detectMotion as MD # Motion Detetction
import tempToArduino as AI # Arduino Interface

# nested dictionary holding data about the frames captured by each of our cameras (camera 1, camera 2, camera 3)
# each frame is divided up into five sections or regions: center, top, bottom, left, and right 
# each frame region has associated with it a Boolean value indicating whether motion has been detected in this region or not
# if the Boolean value is "1" or True, then motion has been detected; and if it's "0" or False, then motion has not been detected
camFrame = {1: {'top': 0, 'left': 0, 'bottom': 0, 'right': 0, 'center': 0},
            2: {'top': 0, 'left': 0, 'bottom': 0, 'right': 0, 'center': 0},
            3: {'top': 0, 'left': 0, 'bottom': 0, 'right': 0, 'center': 0}}

# creates three timers, one for each of our cameras
# at the end of each timer, the camera position is reset to default position
# timers get reset whenever motion is detected, or after three minutes of no activity
# used for setting cameras in default position after lander first lands, and also after having deviated from home position to follow a fish
def checkTimer():
    # get current time
    currTime = round(time.time())

    #iterate through all three timers
    for t in range(3):
        # limit timer to 180 seconds
        if elapsedTime[t] < 180:   
            # calculate total time elapsed since the timers started
            elapsedTime[t] = currTime - startTime[t]
            # when timer ends after 180 seconds (3 minutes), set camera in home position
            if elapsedTime[t] >= 180: camera.home(t + 1); trustCamData[t] = False

            # print out timer values
            #print("This is Timer {}: {} seconds".format(t + 1, elapsedTime[t]))    
    
#reset the specified timer 
def resetTimer(tNum):
    startTime[tNum - 1] = round(time.time())

# update camFrame with newly received frame data
def updateFishData():
    global camFrame
    #collect fish data from detectMotion.py as a nested list
    fishData = MD.returnFishData()
    
    #convert fish data from list to dictionary
    # scan through each of the three frames
    for fNum in camFrame: 
        # check whether motion detection data is trustworthy
        if trustCamData[fNum - 1] == False:
            # nullify bad data and assume no motion has been detected
            for region in camFrame[fNum]: 
                camFrame[fNum][region] = 0 
            
            # decide whether to trust motion detection data again
            cycleCounter[fNum - 1] += 1
            # after throwing away 10 cycles of bad data...
            if cycleCounter[fNum - 1] == 10: 
                trustCamData[fNum - 1] = True # accept motion detection data again
                cycleCounter[fNum - 1] = 0 # reset counter
        
            continue # no need to consider actual motion detection data coming in when flagged as untrustworthy
   
        ndx = 0 #index variable for iterating through list
        activityDetected = False # flag variable indicating the presence of fish in front of camera

        # scan through each region in the frame
        for region in camFrame[fNum]:
            # incorporate list data into dict item by item
            camFrame[fNum][region] = fishData[fNum - 1][ndx]; ndx += 1
            
            # check if activity has been detected anywhere within the frame
            if activityDetected != True:
                if camFrame[fNum][region] == True: activityDetected = True 
        
        # if fish activity found, reset timer
        if activityDetected == True: resetTimer(fNum)

    # print out new camFrame data
    #print(camFrame)

def trackFish():
    # iterate through the data coming from each camera
    for ID in camFrame:
        # define main camera being considered
        main = ID
        # define camera to the left of main camera
        left = ID + 1
        if left == 4: left = 1
        # define camera to the right of main camera
        right = ID - 1
        if right == 0: right = 3

        # check if center region of frame is empty
        # no movement necessary when activity is detected in center of frame
        if not camFrame[main]['center']:
            # if activity is detected either at the top or bottom of the frame, then swing camera either up or down to center the object
            if camFrame[main]['top'] and not camFrame[main]['bottom']: camera.up(main); trustCamData[main - 1] = False
            elif camFrame[main]['bottom'] and not camFrame[main]['top']: camera.down(main); trustCamData[main - 1] = False

        # if there is activity in the left region of the frame, then allow camera to the right to match the position of the main camera
        # this is in the hope that object of interest will swim into the view of the right camera if it swims out of the view of the main camera
        if camFrame[main]['left']:
            activity = False #flag variable indicating that activity has been detected by camera
            #check for activity in view of the camera to the right
            for region in camFrame[right]:
                if camFrame[right][region] == True: activity = True; break
            # right camera should only change position if its view is empty
            if activity == False: camera.copy(main, right); trustCamData[right - 1] = False

        # similar process, but for camera to the right of main camera
        if camFrame[main]['right']:
            activity = False
            for region in camFrame[left]:
                if camFrame[left][region] == True: activity = True; break
            if activity == False: camera.copy(main, left); trustCamData[left - 1] = False

if __name__ == "__main__":
    # initialize three timers
    currentTime = round(time.time())
    startTime = [currentTime for i in range(3)]
    elapsedTime = [0, 0, 0]

    # set cameras in home position
    camera.home(1, 2, 3)
    
    # initialize motion detection data nullification system, called every time one or more of the cameras move
    # this system essentially throws away 10 cycles of motion detection data when it gets flagged as untrustworthy
    # whenever a camera moves, the change of view it gains triggers false positives from the motion detection system
    # these false positives trigger more camera movement, which triggers more false positives, et cetera
    # in order to avoid this chain reaction, we temporarily ignore the motion detection data coming from any camera that has recently moved
    trustCamData = [False, False, False]
    cycleCounter = [0, 0, 0]

    while True: 
        MD.lookForFish() # operates motion detection  
        updateFishData() # retrieves motion detection data
        trackFish()      # operates servos according to motion detection data
        checkTimer()     # returns servos to home position after 3 minutes of no motion being detected

        AI.tempToIno()   # sends temperature data to Arduino for cooling fan control

    