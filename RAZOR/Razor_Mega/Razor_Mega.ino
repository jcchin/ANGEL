//I2C
#include <Wire.h>
//SD libraries
#include <SD.h>
#include <SPI.h>
//GPS libraries
#include <Adafruit_GPS.h>
#include <SoftwareSerial.h> //not actually used, keeps Ada_GPS from barking
#include <avr/sleep.h>
//etc
#include "RTClib.h" //RTC
#define ECHO_TO_SD   1 // echo data to SDcard
#define PRINT_ALT 0//print alt (can't if using processing)
// Set GPSECHO to 'false' to turn off echoing the GPS data to the Serial console
// Set to 'true' if you want to debug and listen to the raw GPS sentences
#define GPSECHO  true
/* set to true to only log to SD when GPS has a fix, for debugging, keep it false */
#define LOG_FIXONLY false  

RTC_DS1307 RTC; // define the Real Time Clock object
// for the data logging shield, we use digital pin 10 for the SD cs line
const int chipSelect = 10;
// the logging file
File logfile;

//Alt sensor libraries
#include "MPL3115A2.h"
//Create an instance of the alt sensor
MPL3115A2 myPressure;

//Accel Stuff
/*** Defines the frequency at which the data is requested ***/
/*** frequency f=1/T, T=period; ie. 100ms --> f=10Hz, 200ms --> f=5Hz ***/
#define PERIOD      100 // [ms]
/*** Vars for IMU ***/ 
const int NUMBER_OF_FIELDS = 3; // how many comma seperated fields we expect                                           
float rpy[NUMBER_OF_FIELDS];    // array holding values for all the fields

// Set the pins used
#define chipSelect 10
#define ledPin 30

Adafruit_GPS GPS(&Serial3);

/************************************************************/
/*** Setup
/************************************************************/
void setup()
{
  Wire.begin();        // Join i2c bus (RTC, Altimeter)  
  if (!RTC.begin()) { // Check for Real Time Clock
  Serial.println("RTC failed");
  }
  
  Serial.begin(115200);  // init the Serial port to print the data to PC
  //Serial2.begin(57600); // init the Serial2 port to get data from the IMU
  //delay(500);
  //initIMU();
  GPS_setup();
  //Accel_setup();
  //altimeter_setup();
}

/************************************************************/
/*** Loop
/************************************************************/
void loop()
{
  //Accel_loop();
  GPS_loop();   
  
}




