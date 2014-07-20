//I2C
#include <Wire.h>
//SD libraries
#include <SD.h>
#include <SPI.h>
//GPS libraries
#include <Adafruit_GPS.h>
#include <SoftwareSerial.h> //not actually used, keeps Ada_GPS from barking
#include <avr/sleep.h>
#include "RTClib.h" //RTC
#define ECHO_TO_SD  1 // echo data to SDcard
#define PRINT_ALT   0 //print alt (can't if using processing)
#define GPSECHO  true //false = no echo to Serial, true = raw GPS sentences for debugging
#define LOG_FIXONLY false //false = always log, true = log only when GPS fix
//GPS + Logging Stuff
RTC_DS1307 RTC; // define the Real Time Clock object
const int chipSelect = 10;// for the GPSshield, use digital pin 10 for the SD CS line
File logfile;// the logging file
#define ledPin 30 //pin for GPS LED (wired for 13 on GPS shield)
HardwareSerial gpsSerial = Serial3;
Adafruit_GPS GPS(&gpsSerial);
//Altimeter Stuff
#include "MPL3115A2.h" //Alt sensor libraries
MPL3115A2 myPressure;//Create an instance of the alt sensor
float altitude, pressure, temperature;
//Accel Stuff
/*** Defines the frequency at which the data is requested ***/
/*** frequency f=1/T, T=period; ie. 100ms --> f=10Hz, 200ms --> f=5Hz ***/
#define PERIOD      200 // [ms]
/*** Vars for IMU ***/ 
HardwareSerial imuSerial = Serial2;
const int NUMBER_OF_FIELDS = 3; // how many comma seperated fields we expect                                           
float rpy[NUMBER_OF_FIELDS];    // array holding values for all the fields
float yaw, pitch, roll;
boolean r1,r2,r3,r4,r5,r6;

/************************************************************/
/*** Setup
/************************************************************/
void setup()
{
  Wire.begin();        // Join i2c bus (RTC, Altimeter)  
  if (!RTC.begin()) { // Check for Real Time Clock
    Serial.println("RTC failed");
  }
  
  Serial.begin(115200);  // init the Serial port to print the data to PC connect
                         // at 115200 so we can read the GPS fast enough and
                         // echo without dropping chars and also spit it out;
  imuSerial.begin(57600); // init the Serial2 port to get data from the IMU
  GPS.begin(9600); //init the Serial3 port to read from the GPS
  GPS_setup();
  altimeter_setup();
  delay(500); //give the IMU time to start-up
  Accel_setup();
}

/************************************************************/
/*** Loop
/************************************************************/
void loop()
{
  Accel_loop();
  GPS_loop();   
}




