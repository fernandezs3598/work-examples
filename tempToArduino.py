#!/home/group9/.virtualenvs/py3cv4/bin/python

import serial
import time
import BME280

# initialize BME280 temperature sensor
bme280 = BME280.BME280()
bme280.get_calib_param()

# initialize Serial communication between Jetson Nano and Arduino
ser = serial.Serial('/dev/ttyUSB0', 9600, timeout = 1)
#ser.reset_input_buffer()

#gets temperature data from BME280 sensor and sends it to Arduino via Serial communication
def tempToIno():
    # gather temperature data from BME280
    bme = list(bme280.readData())

    temp = round(bme[1])
    highTempAlertSystem(temp)

    temp = '<' + str(temp) + '>' # "<" and ">" are start and end markers telling Arduino when each message from Jetson Nano begins and ends

    # write temp data to Arduino
    ser.write(temp.encode('utf-8'))

    # read and print confirmation of receipt message from Arduino
    #line = ser.readline().decode('utf-8').rstrip()
    #print(line)

# initialize timer variables
tempVeryHigh = False # flag indicating whether temp is hgiher than 30 degrees
startTime = None # records start time of timer
elapsedTime = 0 # records elapsed time since timer began

# to be used to report how long temperature remains above 30 degrees Celcius
def highTempAlertSystem(temp):
    global tempVeryHigh, startTime, elapsedTime

    # measure how long temperature rises above 30 degrees
    if temp >= 30:
        # if necessary, set high temperature flag, and begin timer
        if tempVeryHigh == False: 
            tempVeryHigh = True; 
            startTime = time.time()

        # calculate elapsed time since timer began
        elif tempVeryHigh == True: 
            currentTime = time.time()
            elapsedTime = currentTime - startTime
    
    # create deadzone between (roughly, due to rounding) 29 degrees and 30 degrees so that effect of insignificant fluctuations in temperature is nullified
    # if system spends too much time operating above 30 degrees, system is overheating
    elif temp < 29:
        # once temperature drops again...
        if tempVeryHigh == True:
            tempVeryHigh = False # negate high temperature flag

            elapsedTime = round(elapsedTime)
            elapsedMin = round(elapsedTime / 60, 1) # convert timer value from seconds to minutes

            # print out results for inspection by team upon completion of mission
            print("Temperature exceedded 30 degrees Celcius for {} seconds ({} minutes)!".format(elapsedTime, elapsedMin))


if __name__ == '__main__':
    while True:
        tempToIno()
        time.sleep(0.1) # update interval