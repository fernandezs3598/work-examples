#include <msp430.h>
#include <stdio.h>
#include <stdbool.h>

// 2 Light Sensors
#define LS1        BIT0        // Light Sensor #1
#define LS2        BIT1        // Light Sensor #2

int ADCReading[2];
int inLight = 0;
int outLight = 0;

void ConfigureADC(void);
void getLightValues(void);

// Ultrasonic Distance Sensor
#define TRIGGER    BIT7
#define ECHO       BIT4
#define TIMER      TA1R
#define MIN_DIST   0           // Distance from sensor to blind when blind fully closed
#define MAX_DIST   100         // Distance from sensor to blind when blind fully open

int echoPulseDuration;         // Time in µs
int distance;                  // Distance in mm
int currDistance;              // Indicates current position of blinds

void getDistance(void);

// Keypad
#define ROW1       BIT0
#define ROW2       BIT1
#define COL1       BIT2
#define COL2       BIT3
#define ALLROWS    (ROW2 | ROW1)
#define ALLCOLS    (COL2 | COL1)
#define ROWS_OUT   P2OUT
#define COLS_IN    P1IN

int rowNum;
int keyNum = 0;

void initKeypad();

// DC Motor
#define DIR        BIT5        // Direction
#define DCME       BIT6        // DC Motor Enable

int speed = 0;                 // Defines speed of DC motor (0 - 100)
bool doneMoving = false;       // Flag indicating whether blind movement complete

void motorSpeed(int valuePWM);

// LCD
#define CMD        0
#define DATA       1
#define RS         BIT2
#define EN         BIT3
#define D4         BIT4
#define D5         BIT5
#define D6         BIT6
#define D7         BIT7
#define LCD_OUT    P2OUT

char str[4];
int setting = 0;               // Defines setting under which system is operating

void intToStr(char str[], int num);
void pulseEN(void);
void writeToLCD(int value, int mode);
void printToLCD(char *s);
void setCursorLCD(int row, int col);
void initLCD();
void setLayoutLCD();
void updateLCD();

// Other
void delay(int t);

int main(void)
{
    WDTCTL = WDTPW + WDTHOLD;               // Stop WDT

    P1OUT = 0;              // Set default values to all zeros for port 1
    P1DIR = 0;              // Set port DIR to all inputs for port 1
    P2OUT = 0;              // Set default values to all zeros for port 2
    P2DIR = 0;              // Set port DIR to all inputs for port 2
    P1REN = 0;              // Disable pull up/down resistors for port 1
    P2REN = 0;              // Disable pull up/down resistors for port 2

    P1DIR |= TRIGGER;       // Make P1.7 an output for the trigger pulses
    P1DIR |= (DCME | DIR);  // Set P1.4 and P1.5 as outputs to enable DC motor and control direction

    // Set up Timer_A1 for ultrasonic distance sensor
    // SMCLK clock, "continuous" mode
    // It counts from 0 to 65535, incrementing once per clock cycle (every microsecond)
    TA1CTL = TASSEL_2 + MC_2;

    // Start the motor in forward direction and wait 2 seconds so the voltages on the breadboard settle before you start reading the analog values
    P1OUT |= DCME; P1OUT |= DIR; motorSpeed(100); delay(20000); motorSpeed(0);

    ConfigureADC();

    // Set up the LCD to display data
    initLCD();
    setLayoutLCD();

    // Initialize the keypad
    initKeypad();
    __enable_interrupt();      // Enable interrupts

    for (;;)
    {
        // Read light values and distance value from sensors, and update LCD with new values
        getLightValues();
        getDistance();
        updateLCD();

        // Automatically keep the inside of the house as bright as possible
        if (keyNum == 1)
        {
            // At night, close the blinds
            if (outLight < 10) {if (distance > MIN_DIST) {P1OUT &= ~DIR; motorSpeed(100); delay(300); motorSpeed(0);}}
            // During the day, maximize amount of light coming into the house
            else
            {
                // If brighter outside than inside, open window blind to let light in
                if ((outLight - inLight) > 10) {if (distance < MAX_DIST) {P1OUT |= DIR; motorSpeed(100); delay(800);}}
                // While outside light and inside light are balanced, no need to move blinds
                else {motorSpeed(0);}
            }

            // Gradually adjusts blinds using only one sensor
            /*if (distance > outLight - 20 && distance < outLight + 20) {motorSpeed(0);}
            else
            {
                // While blind too low
                if (distance <= outLight) {if (distance < MAX_DIST) {P1OUT |= DIR; motorSpeed(100); delay(600);}}
                // While blind too high
                else if (distance >= outLight) {if (distance > MIN_DIST) {P1OUT &= ~DIR; motorSpeed(100); delay(150); motorSpeed(0);}}
            }*/
        }

        // Automatically keep the inside of the house as dark as possible
        else if (keyNum == 4)
        {
            // During the day, close the blinds
            if (outLight > 10) {if (distance > MIN_DIST) {P1OUT &= ~DIR; motorSpeed(100); delay(300); motorSpeed(0);}}
            // Only open blinds at night when there is no sunlight for them to block
            else {if (distance < MAX_DIST) {P1OUT |= DIR; motorSpeed(100); delay(600);}}
        }

        // Manual adjustment of window blind upward by increments
        else if (keyNum == 2)
        {
            // Remember starting position of blind (0 - 100)
            if (doneMoving == true) {currDistance = distance; doneMoving = false;}

            // Increase position of blind by 20 units
            if (distance < currDistance + 20 && distance < MAX_DIST) {P1OUT |= DIR; motorSpeed(100); delay(700);}
            else {motorSpeed(0); doneMoving = true; keyNum = 0;} // Reset keyNum when finished moving so button can be pressed repeatedly
        }

        // Manual adjustment of window blind downward by increments
        else if (keyNum == 5)
        {
            // Remember starting position of blind (0 - 100)
            if (doneMoving == true) {currDistance = distance; doneMoving = false;}

            // Decrease position of blind by 20 units
            if (distance > currDistance - 20 && distance > MIN_DIST) {P1OUT &= ~DIR; motorSpeed(100); delay(150); motorSpeed(0);}
            else {doneMoving = true; keyNum = 0;} // Reset keyNum when finished moving so button can be pressed repeatedly
        }
    } //end for
} //end main

// Set up ADC to receive signals from two light sensors
void ConfigureADC(void)
{
   ADC10CTL1 = INCH_1 | CONSEQ_1;                 // A1 + A0, single sequence
   ADC10CTL0 = ADC10SHT_2 | MSC | ADC10ON;
   while (ADC10CTL1 & BUSY);
   ADC10DTC1 = 0x02;                              // 2 conversions
   ADC10AE0 |= (LS1 | LS2);                       // ADC10 option select
}

// Get light readings from light sensors
void getLightValues(void)
{
  inLight = 0; outLight = 0;                      // Set all analog values to zero

  int i;
  for (i = 1; i <= 5; i++)                        // Read all three analog values 5 times each and average
  {
    ADC10CTL0 &= ~ENC;
    while (ADC10CTL1 & BUSY);                     // Wait while ADC is busy
    ADC10SA = (unsigned) & ADCReading[0];         // RAM Address of ADC Data, must be reset every conversion
    ADC10CTL0 |= (ENC | ADC10SC);                 // Start ADC Conversion
    while (ADC10CTL1 & BUSY);                     // Wait while ADC is busy
    inLight += ADCReading[1];                     // Sum  all 5 readings for the two variables
    outLight += ADCReading[0];
  }

  inLight = inLight  / 5;                         // Average the 5 readings for the two variables
  outLight = outLight / 5;

  inLight = 100 - (((inLight - 50) * 100) / (950 - 50));        // Normalize values between 0 and 100, where 0 means complete darkness
  outLight = 100 - (((outLight - 50) * 100) / (950 - 50));

  if (inLight <= 0) inLight = 0;                  // Constrain values between 0 and 100
  else if (inLight >= 100) inLight = 100;
  if (outLight <= 0) outLight = 0;
  else if (outLight >= 100) outLight = 100;
}

// ADC10 interrupt service routine
#pragma vector=ADC10_VECTOR
__interrupt void ADC10_ISR(void)
{
    __bic_SR_register_on_exit(CPUOFF);
}

// Get distance reading from ultrasonic distance sensor
void getDistance(void)
{
    // Send a 10 us trigger pulse
    P1OUT |= TRIGGER;                                      // Set trigger high
    __delay_cycles(20);                                    // 10 µs delay
    P1OUT &= ~TRIGGER;                                     // Set trigger low

    // Measure duration of echo pulse
    motorSpeed(0);
    while (!(P1IN & ECHO)); TIMER = 0;                     // Wait for start of echo pulse, and reset timer
    while ((P1IN & ECHO)); echoPulseDuration = TIMER;      // Wait for end of echo pulse, and capture timer value
    motorSpeed(speed);

    // Convert from µs to mm
    distance = echoPulseDuration * 0.17;                   // Formula: distance = (speed of sound(0.34 mm/µs) * time) / 2

    distance = (((distance - 40) * 100) / (125 - 40));     // Normalize values between 0 and 100, where 0 means completely closed

    if (distance <= 2) distance = 0;                       // Constrain values between 0 and 100
    else if (distance >= 98) distance = 100;
}


// Initialize KeyPad
void initKeypad()
{

    P1DIR    &= ~ALLCOLS;         // Set port 1 all inputs
    P1REN    |=  ALLCOLS;         // Enable resistors for all columns
    P1OUT    |=  ALLCOLS;         // Make those resistors pull-ups
    P1IES    |=  ALLCOLS;         // Interrupt edge select, high to low
    P1IE     |=  ALLCOLS;         // Enable interrupt on all columns
    P1IFG    &= ~ALLCOLS;         // Clear all interrupt flags on the columns
    P2DIR    |=  ALLROWS;         // Set all rows as output

    ROWS_OUT &= ~ALLROWS; delay(2);   // Assert low on all rows low to detect any key stroke interrupt
}

// Port 1 interrupt service routine
#pragma vector=PORT1_VECTOR
__interrupt void Port_1(void)
{
   ROWS_OUT |= ALLROWS; delay(1);                // Make all rows high

   for (rowNum = 0; rowNum <= 1; rowNum++)       // Start scanning the KP
   {
       // Start at 1 in first row and shift left rowNum times, and XOR
       ROWS_OUT = ((ROW1 << rowNum) ^ ALLROWS); delay(1);

       if (!(COLS_IN & COL1)) {keyNum = 3 * rowNum + 1;}
       if (!(COLS_IN & COL2)) {keyNum = 3 * rowNum + 2;}
    }

   ROWS_OUT &= ~ALLROWS; delay(1);               // Make all rows low for next key stroke interrupt
   P1IFG    &= ~ALLCOLS; delay(1);               // Clear the interrupt flags
}

// Set motor speed using PWM
void motorSpeed(int valuePWM)
{
    P1SEL |= (DCME);                              // P1.0 and P1.6 TA1/2 options
    CCR0 = 100 - 0;                               // PWM Period
    CCTL1 = OUTMOD_3;                             // CCR1 reset/set
    CCR1 = 100 - valuePWM;                        // CCR1 PWM duty cycle
    TACTL = TASSEL_2 + MC_1;                      // SMCLK, up mode

    speed = valuePWM;                             // Save current speed to global variable, to make accessible program-wide
}

// Integer to char conversion
void intToStr(char str[], int num)
{
   int len = 0, rem, n = num;

   if (n == 0) {len = 1;}
   else {while (n != 0) {len++; n /= 10;}}

   int i;
   for (i = 0; i < len; i++)
   {rem = num % 10; num = num / 10; str[len - (i + 1)] = rem + '0';}

   str[len] = '\0';
}


// Function to pulse EN pin after data is written
void pulseEN(void)
{
   LCD_OUT |= EN; delay(1); LCD_OUT &= ~EN; delay(1);
}

// Function to write data/command to LCD
void writeToLCD(int value, int mode)
{
   if (mode == CMD)  {LCD_OUT &= ~RS;}            // Set RS -> LOW for Command mode
   else              {LCD_OUT |= RS;}             // Set RS -> HIGH for Data mode

   LCD_OUT = ((LCD_OUT & 0x0F) | (value & 0xF0));        pulseEN(); delay(1);      // Write high nibble first
   LCD_OUT = ((LCD_OUT & 0x0F) | ((value << 4) & 0xF0)); pulseEN(); delay(1);      // Write low nibble next
 }

// Function to print a string on LCD
void printToLCD(char *s)
{
   while (*s) {writeToLCD(*s, DATA); s++;}
}

// Function to move cursor to desired position on LCD
void setCursorLCD(int row, int col)
{
   const int row_offsets[] = {0x00, 0x40};
   writeToLCD(0x80 | (col + row_offsets[row]), CMD); delay(1);
}

// Initialize LCD
void initLCD()
{
   P2SEL   &= ~(BIT6 | BIT7);
   P2DIR   |=  D4 | D5 | D6 | D7 | RS | EN;

   LCD_OUT &= ~(D4 | D5 | D6 | D7 | RS | EN);

   delay(150);                             // Wait for power up (15ms)
   writeToLCD(0x33, CMD); delay(50);       // Initialization Sequence 1
   writeToLCD(0x32, CMD); delay(1);        // Initialization Sequence 2

   // All subsequent commands take 40 us to execute, except clear & cursor return (1.64 ms)
   writeToLCD(0x28, CMD); delay(1);          // 4 bit mode, 2 line
   writeToLCD(0x0C, CMD); delay(1);          // Display ON, Cursor off, for cursor on F
   writeToLCD(0x01, CMD); delay(20);         // Clear screen
}

// LCD fixed layout text
void setLayoutLCD()
{
    setCursorLCD(0, 1); printToLCD("SET:");  // Indicates what "setting" system is operating under
    setCursorLCD(0, 9); printToLCD("POS:");  // Indications what "position" blind is in, in terms of percentage open
    setCursorLCD(1, 1); printToLCD("OTL:");  // Indicates strength of light outdoors
    setCursorLCD(1, 9); printToLCD("INL:");  // Indicates strength of light indoors
}

// LCD fields updates
void updateLCD()
{
   if (keyNum == 1) {setting = 1;}                      // System lets the most light into the house (automated)
   else if (keyNum == 4) {setting = 2;}                 // System keeps the most light out of the house (automated)
   else if (keyNum == 2 || keyNum == 5) {setting = 3;}  // Manual adjustment mode

   intToStr(str, setting);       setCursorLCD(0, 5);  printToLCD("   "); setCursorLCD(0, 5);  printToLCD(str);
   intToStr(str, distance);      setCursorLCD(0, 13); printToLCD("   "); setCursorLCD(0, 13); printToLCD(str);
   intToStr(str, inLight);       setCursorLCD(1, 13); printToLCD("   "); setCursorLCD(1, 13); printToLCD(str);
   intToStr(str, outLight);      setCursorLCD(1, 5);  printToLCD("   "); setCursorLCD(1, 5);  printToLCD(str);
}

// Delay function for producing delay in 0.1 ms increments
void delay(int t)
{
   int i;
   for (i = t; i > 0; i--) {__delay_cycles(100);}
}
