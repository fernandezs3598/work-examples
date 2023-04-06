#!/home/group9/.virtualenvs/py3cv4/bin/python

import time
from adafruit_servokit import ServoKit # pwm/servo driver
import ICM20948 # gyroscope/accelerometer/magnetometer

# initialize icm20948 sensor
icm20948 = ICM20948.ICM20948()

# initialize pca9685 servo driver
kit = ServoKit(channels = 16)

# nested dictionary holding information pertaining to each of our cameras (camera 1, camera 2, and camera 3)
# "p_servo" and "r_servo" reference the (pca9685 channels driving the) servos that control the pitch and roll of each camera, respectively 
# "p_sen" and "r_sen" represent the sensitivity of the pitch and roll servos to changes in the orientation of the icm20948
# adjust these to change sensitivity of servos (to aim cameras more accurately): increasing decreases servo sensitivity, and vice versa; and 100 is default
# "p_max" and "p_min" define the max/min pitch angles that each camera can be set at, so they don't crash into anything or inhibit visibility
# "p_offset" and "r_offset" enable offsetting of pitch and roll values, in case physical limitations disallow cameras from being mounted perfectly straight
camera = {1: {'p_servo': 0, 'r_servo': 1, 'p_sen': 100, 'r_sen': 100, 'p_max': 128, 'p_min': 60, 'p_offset': 0, 'r_offset': 0},
          2: {'p_servo': 14, 'r_servo': 15, 'p_sen': 74, 'r_sen': 74, 'p_max': 120, 'p_min': 40, 'p_offset': 0, 'r_offset': -10},
          3: {'p_servo': 7, 'r_servo': 8, 'p_sen': 74, 'r_sen': 74, 'p_max': 130, 'p_min': 50, 'p_offset': -8, 'r_offset': -12}}

# set camera in home position
def home(*args):
    # read icm 20948 sensor data
    icm = list(icm20948.getdata()) 
    
    # convert each data value to a value between -100 and 100 (normalization formula)
    # icm[3] is accelemroter measurement of acceleration along x-axis (raw values roughly between -16150 and 16550)
    # icm[4] is accelemroter measurement of acceleration along y-axis (raw values roughly between -18800 and 14000)
    icm[3] = (2 * (((icm[3] - (-16150))) / (16550 - (-16150))) - 1) * 100
    icm[4] = (2 * (((icm[4] - (-18800))) / (14000 - (-18800))) - 1) * 100
    
    # iterate through every specified camera
    for ID in args: 
        # organize useful sensor data based on specified camera
        # camera at 0 degrees on unit circle
        if ID == 1: 
            newPitch = icm[3] # camera's pitch angle set by sensor's roll angle
            newRoll = -icm[4] # camera's roll angle set by sensor's pitch angle
        
        # camera at 120 degrees on unit circle
        elif ID == 2:
            # the servo controlling this camera's pitch is inverted, so sensor data needs to be inverted (multipled by -1) as well
            newPitch = -((-icm[3] * 1/3) + (icm[4] * 2/3)) # camera's pitch set 33% by sensor's roll and 66% by sensor's pitch
            newRoll = (icm[3] * 2/3) + (icm[4] * 1/3) # camera's roll set 66% by sensor's roll and 33% by sensor's pitch
    
        # camera at 240 degrees on unit circle
        elif ID == 3:
            newPitch = (-icm[3] * 1/3) + (-icm[4] * 2/3) # camera's pitch set 33% by sensor's roll and 66% by sensor's pitch
            newRoll = (-icm[3] * 2/3) + (icm[4] * 1/3) # camera's roll set 66% by sensor's roll and 33% by sensor's pitch
        
        # map pitch and roll values to full servo range, or between 0 and 180 (normalization formula)
        newPitch = ((newPitch - (-camera[ID]['p_sen'])) * 180) / (camera[ID]['p_sen'] - (-camera[ID]['p_sen']))
        newRoll = ((newRoll - (-camera[ID]['r_sen'])) * 180) / (camera[ID]['r_sen'] - (-camera[ID]['r_sen']))
        
        # round pitch and roll values, and incorporate offset value
        newPitch = round(newPitch) + camera[ID]['p_offset']
        newRoll = round(newRoll) + camera[ID]['r_offset']
        
        # constrain pitch and roll between maximum and minimum values
        if newPitch <= camera[ID]['p_min']: newPitch = camera[ID]['p_min']
        elif newPitch >= camera[ID]['p_max']: newPitch = camera[ID]['p_max']

        if newRoll <= 0: newRoll = 0
        elif newRoll >= 180: newRoll = 180

        # another way
        #newPitch = min(max(camera[ID]['p_min'], newPitch), camera[ID]['p_min'])
        #newRoll = min(max(0, newRoll), 180)

        # write to servos controlling specified camera (only if necessary)
        currPitch = kit.servo[camera[ID]['p_servo']].angle
        currRoll = kit.servo[camera[ID]['r_servo']].angle

        if newPitch != currPitch:
            kit.servo[camera[ID]['p_servo']].angle = newPitch
        if newRoll != currRoll:
            kit.servo[camera[ID]['r_servo']].angle = newRoll

        # print pitch and roll values
        #print("This is camera #{}'s pitch: {}".format(ID, newPitch))
        #print("This is camera #{}'s roll: {}".format(ID, newRoll))
        #print("-------------------------------")

# move camera up
def up(ID):
    # get current pitch angle
    currPitch = kit.servo[camera[ID]['p_servo']].angle

    # camera 2 needs special treatment because pitch servo is installed upside down by necessity
    if ID == 2:
        # increase current pitch angle by ~15 degrees
        newPitch = currPitch + 15 
        # make sure new pitch angle is within limit
        if newPitch >= camera[ID]['p_max']: newPitch = camera[ID]['p_max']

    else:
        # increase current pitch angle by ~15 degrees
        newPitch = currPitch - 15 
        # make sure new pitch angle is within limit
        if newPitch <= camera[ID]['p_min']: newPitch = camera[ID]['p_min']

    # write new pitch angle to specified servo (only if necessary)
    if newPitch != currPitch:
        kit.servo[camera[ID]['p_servo']].angle = newPitch 

# move camera down
def down(ID):
    # get camera's current pitch angle
    currPitch = kit.servo[camera[ID]['p_servo']].angle
    
    # camera 2 needs special treatment because pitch servo is installed upside down by necessity
    if ID == 2:
        # decrease current pitch angle by ~15 degrees
        newPitch = currPitch - 15 
        # make sure new pitch angle is within limit
        if newPitch <= camera[ID]['p_min']: newPitch = camera[ID]['p_min']
    
    else:
        # decrease current pitch angle by ~15 degrees
        newPitch = currPitch + 15 
        # make sure new pitch angle is within limit
        if newPitch >= camera[ID]['p_max']: newPitch = camera[ID]['p_max']

    # write new pitch angle to specified servo (only if necessary)
    if newPitch != currPitch:
        kit.servo[camera[ID]['p_servo']].angle = newPitch 

# set one camera's pitch angle as equivalent to another's
def copy(ID1, ID2):
    # define camera's current angle
    currPitch = kit.servo[camera[ID2]['p_servo']].angle
    
    # define camera's new desired angle 
    # subtract offset in order to get absolute pitch angle
    newPitch = kit.servo[camera[ID1]['p_servo']].angle - camera[ID1]['p_offset']
    
    # camera 2 needs special treatment because pitch servo is installed upside down by necessity
    if ID2 == 2:
        newPitch = 180 - newPitch

    # add offset to new pitch angle
    newPitch += camera[ID2]['p_offset']

    # constrain desired pitch between max and min possible pitch
    if newPitch <= camera[ID2]['p_min']: newPitch = camera[ID2]['p_min']
    elif newPitch >= camera[ID2]['p_max']: newPitch = camera[ID2]['p_max']
    
    # write camera's new pitch angle to the servo controlling its pitch (only if necessary)
    if newPitch != currPitch:
        kit.servo[camera[ID2]['p_servo']].angle = newPitch 


if __name__ == '__main__':
    try:
        # aim all 3 cameras in their default positions indefinitely
        while True:
            home(1, 2, 3)
            time.sleep(0.05)
    
    except: 
        for x in camera:
            kit.servo[camera[x]['p_servo']].angle = 90 + camera[x]['p_offset']
            kit.servo[camera[x]['r_servo']].angle = 90 + camera[x]['r_offset']

"""
    When importing this module into another program, these are the functions at your disposal.

        import aimCameras as camera
    
    To aim a camera in its default or home position (straight forward, based on the orientation of our gyro sensor), 
    first each of our cameras individually (useful to bring a camera back home after deviating for any reason), 
    and lastly all three at the same time (useful such as when the ocean lander first lands on the seafloor):
        
        camera.home(1)
    
        camera.home(2)
    
        camera.home(3)
        
        camera.home(1, 2, 3)

    To rotate, for example, camera #1 up by about five degrees (useful when repeatedley called in a loop, 
    while following objects of interest as they swim up out of the camera's field of view):
    
        camera.up(1)

    To rotate, for example, camera #3 down by about five degrees (useful when repeatedley called in a loop, 
    while following objects of interest as they swim down out of the camera's field of view):
    
        camera.down(3)
    
    To copy, for example, the pitch angle of camera #3 over to camera #2 (useful when a camera deviates from default position, and the object 
    of interest swims horizontally out of its field of view; ensures object of interest continues to be captured by adjacent camera):

        camera.copy(3, 2)
"""