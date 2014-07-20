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
#define ECHO_TO_SD   0 // echo data to SDcard
#define PRINT_ALT 0//print alt (can't if using processing)
// Set GPSECHO to 'false' to turn off echoing the GPS data to the Serial console
// Set to 'true' if you want to debug and listen to the raw GPS sentences
#define GPSECHO  false
/* set to true to only log to SD when GPS has a fix, for debugging, keep it false */
#define LOG_FIXONLY true  

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
  
  Serial.begin(57600);  // init the Serial port to print the data to PC
  Serial2.begin(57600); // init the Serial2 port to get data from the IMU
  delay(500);
  initIMU();
  GPS_setup();
  Accel_setup();
  altimeter_setup();
}

/************************************************************/
/*** Loop
/************************************************************/
void loop()
{
  //forward all IMU to serial
  int inByte = Serial2.read();
  Serial.write(inByte);
  
  float yaw;
  float pitch;
  float roll;
  boolean r1,r2,r3,r4,r5,r6;
  // print manager timer
  static unsigned long timer = 0;
  static unsigned long currentTime = 0;

  /************************************************************/
  /*** Request after a specific period for the data
  /************************************************************/
  currentTime = millis();
  if(currentTime - timer >= PERIOD)
  {
    // Request one output frame from the IMU
    // #f only requests one reply, replies are still bound to the internal 20ms (50Hz) time raster.
    // So worst case delay that #f can add is 19.99ms.
    Serial2.write("#f");

    /************************************************************/
    /*** Get the IMU values
    /************************************************************/
    // the current field being received
    int fieldIndex = 0;            
    // search the Serial Buffer as long as the header character is found
    boolean found_HeaderChar = Serial2.find("#YPR=");
    if (found_HeaderChar)
    {
      // Get all 3 values (yaw, pitch, roll) from the Serial Buffer
      while(fieldIndex < NUMBER_OF_FIELDS)
      {
        rpy[fieldIndex++] = Serial2.parseFloat();
      }
    }

    /************************************************************/
    /*** Print out the values
    /*** Format: yaw, pitch, roll, left_Encoder, right_Encoder
    /************************************************************/
    if (found_HeaderChar)
    {
      // print Interval
      //Serial.print(currentTime - timer);
      Serial.print(",");
      // print IMU values
      for(fieldIndex=0; fieldIndex < NUMBER_OF_FIELDS; fieldIndex++)
      {
        Serial.print(rpy[fieldIndex]);
        Serial.print(",");
        if (fieldIndex == 0){
          yaw = rpy[fieldIndex];
        }if  (fieldIndex == 1){
          pitch = rpy[fieldIndex];
        }if  (fieldIndex == 2){
          roll = rpy[fieldIndex];
        }
      }
      Serial.print("");
      //Convert body frame to inertial frame and find closest face
      float R[3][3];
      int led;
      R_b_to_i(yaw, pitch, roll, R);
      led = pick(R);
      Serial.print(led);
      (led==0) ? digitalWrite(22, HIGH) : digitalWrite(22, LOW);
      (led==1) ? digitalWrite(23, HIGH) : digitalWrite(23, LOW);
      (led==2) ? digitalWrite(24, HIGH) : digitalWrite(24, LOW);
      (led==3) ? digitalWrite(25, HIGH) : digitalWrite(25, LOW);
      (led==4) ? digitalWrite(26, HIGH) : digitalWrite(26, LOW);
      (led==5) ? digitalWrite(27, HIGH) : digitalWrite(27, LOW);
        
      }else{
        r1 = false; r2 = false; r3 = false; r4 = false; r5 = false; r6 = false;
      }
      
      timer = millis();
      
      float altitude = myPressure.readAltitudeFt();
      float pressure = myPressure.readPressure();
      float temperature = myPressure.readTempF();
      
      Serial.println();
      #if PRINT_ALT
      Serial.print(altitude, 2);
      Serial.print(",");
      Serial.print(pressure, 2);
      Serial.print(",");
      Serial.print(temperature, 2);
      Serial.println();
      #endif
      
      #if ECHO_TO_SD
      //SD logging
      DateTime now;
      now = RTC.now();
      // log time
      logfile.print(now.year(), DEC);
      logfile.print("/");
      logfile.print(now.month(), DEC);
      logfile.print("/");
      logfile.print(now.day(), DEC);
      logfile.print(", ");
      logfile.print(now.hour(), DEC);
      logfile.print(":");
      logfile.print(now.minute(), DEC);
      logfile.print(":");
      logfile.print(now.second(), DEC);
      logfile.print(',');
      logfile.print(yaw);
      logfile.print(',');
      logfile.print(pitch);
      logfile.print(',');
      logfile.print(roll);
      logfile.print(',');
      logfile.print(altitude);
      logfile.print(',');
      logfile.print(pressure);
      logfile.print(',');
      logfile.print(temperature);
      logfile.print('\n');
      logfile.flush();
      #endif
  }
  
}




