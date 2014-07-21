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
char *stringptr; //holds GPS NMEA string
//Altimeter Stuff
#include "MPL3115A2.h" //Alt sensor libraries
MPL3115A2 myPressure;//Create an instance of the alt sensor
float altitude, pressure, temperature;
//Accel Stuff
/*** Defines the frequency at which the data is requested ***/
/*** frequency f=1/T, T=period; ie. 100ms --> f=10Hz, 200ms --> f=5Hz ***/
#define PERIOD      100 // [ms]
/*** Vars for IMU ***/ 
HardwareSerial imuSerial = Serial2;
const int NUMBER_OF_FIELDS = 3; // how many comma seperated fields we expect                                           
float rpy[NUMBER_OF_FIELDS];    // array holding values for all the fields
float yaw, pitch, roll;
boolean r1,r2,r3,r4,r5,r6;
uint32_t timer1 = millis();
// this keeps track of whether we're using the interrupt
// off by default!
boolean usingInterrupt = false;
void useInterrupt(boolean); // Func prototype keeps Arduino 0023 happy
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
  logfile.println( \
  "yaw, pitch, roll, altitude, pressure, temperature, " \
  "Time (HH:MM:SS), Date (MM/DD/YY)," 
  "GPS Fix, Fix Quality, Latitude, Longitude, " \
  "knots, altitude, # of satellite fixes");
}

/************************************************************/
/*** Loop
/************************************************************/
void loop()
{
  GPS_loop();
  Accel_loop();
  // approximately every 0.5 second or so, print out the current stats
  if (millis() - timer1 > 100) { 
    timer1 = millis(); // reset the timer
    
    logfile.print(GPS.hour, DEC); logfile.print(':');
    logfile.print(GPS.minute, DEC); logfile.print(':');
    logfile.print(GPS.seconds, DEC); logfile.print('.');
    logfile.print(GPS.milliseconds);
    logfile.print(",");
    logfile.print(GPS.month, DEC); logfile.print("/");
    logfile.print(GPS.day, DEC); logfile.print('/');
    logfile.print(GPS.year, DEC);
    logfile.print(",");
    logfile.print((int)GPS.fix);
    logfile.print(",");
    logfile.print((int)GPS.fixquality);
    logfile.print(","); 
    if (GPS.fix) {
      logfile.print(GPS.latitude, 4); logfile.print(GPS.lat);
      logfile.print(", "); 
      logfile.print(GPS.longitude, 4); logfile.print(GPS.lon);
      logfile.print(",");
      logfile.print(GPS.speed);
      logfile.print(",");
      logfile.print(GPS.altitude);logfile.print(",");
      logfile.println((int)GPS.satellites);
    }else{
      logfile.println(", , , ,"); 
    }
  }
}




