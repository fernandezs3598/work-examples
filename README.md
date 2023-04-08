# work-examples

The purpose of this repository is simply to demonstrate the programming skills that I acquired during my education at FAU. These programs were written by me as components of three major projects that I completed over the course of my degree, which all received A grades. 

1. 

"DatabaseCode" is a database that I programmed from scratch using SQL, and "Sample Queries" is a simple program which executes five queries against the database. 

2. 

"automatedWindowBlindSystem" is a C program designed to run on an MSP430G2553 microcontroller governing a proof-of-concept electronically controlled window blind system. The system involved the following sensors and actuators: two photoresistors (light sensors), an ultrasonic distance sensor, a keypad, an LCD screen, and two DC motors. 

*** In full disclosure, some parts of this program were provided by my professor as a foundation to start with, however I thoroughly studied them and modified them to suit my needs.

3. 

[Capstone Project] 

"aimCameras" is a Python program designed to run on a Jetson Nano microcomputer, which independently manages the movements of six servomotors. Three cameras were mounted to two servos each, and were intelligently aimed by the servos based on accelerometer sensor data. 

"tempToArduino" established Serial communication between the Jetson Nano and an Arduino Nano in order to send data from a temperature sensor attached to the Jetson Nano. 

"12V_Fan_Control" is a C program desgined to run on the Arduino that utilized the temperature data to determine the speed of a cooling fan connected to the Arduino. 

"driverProgram" is a Python program that ran in an indefinite loop on the Jetson Nano, which imported the above programs along with a program (that adds motion detention functionality to the cameras) written by my teammate, and combined them all into one harmonious system operating at the same time. This program also utilized the motion detection data to aim the cameras in the direction of the motion being detected. 
