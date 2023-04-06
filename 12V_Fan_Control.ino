const int fanPin = 11;      // the pin where fan is
int fanSpeed;
int lastSpeed = -1;
const int fanOff = 255;
const int halfSpeed = 127;
const int fullSpeed = 0;

int temp;
const int tempMin = 30;  // the temperature to start the fan 0%
const int tempMax = 60;  // the maximum temperature when fan is at 100%

const byte numChars = 32;
char receivedChars[numChars]; // an array to collect temp data from Jetson Nano
boolean newData = false;

void setup() {
  pinMode(fanPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  readTemp();  // get the temperature

  if (newData == true)
  {
    temp = atoi(receivedChars);
    setFanSpeed();
    newData = false;

    //Serial.print("Arduino received ");
    //Serial.print(temp);
    //Serial.println("°C from Jetson Nano.");
  }
}

void readTemp() {  // get the temperature from Jetson Nano
  static boolean recvInProgress = false;
  static byte ndx = 0; //index
  char startMarker = '<';
  char endMarker = '>';
  char rc; //received charcter

  while (Serial.available() > 0 && newData == false) {
    rc = Serial.read();

    if (recvInProgress == true) {
        if (rc != endMarker) {
          receivedChars[ndx] = rc;
          ndx++;
          if (ndx >= numChars) {
            ndx = numChars - 1;
          }
        }
        else {
          receivedChars[ndx] = '\0'; // terminate the string
          recvInProgress = false;
          ndx = 0;
          newData = true;
        }
    }
  
    else if (rc == startMarker) {
      recvInProgress = true;
    }
  }
}

void setFanSpeed() { //set fan speed according to temp data received from Jetson Nano
  // if temp is higher than maximum temp
  if (temp > tempMax) {fanSpeed = fullSpeed;}

  // if temperature is higher than minimum temp 
  else if ((temp >= tempMin) && (temp <= tempMax)) {fanSpeed = map(temp, tempMin, tempMax, halfSpeed, fullSpeed);}
  
  // if temp is lower than minimum temp
  else {fanSpeed = fanOff;}

  if (fanSpeed != lastSpeed) 
  {
    analogWrite(fanPin, fanSpeed);
    lastSpeed = fanSpeed;
  }
}
