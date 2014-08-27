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
#define GPSECHO  false //false = no echo to Serial, true = raw GPS sentences for debugging
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
const int NUMBER_OF_FIELDS = 6; // how many comma seperated fields we expect                                           
float rpy[NUMBER_OF_FIELDS];    // array holding values for all the fields
float yaw, pitch, roll, rawX, rawY, rawZ;
boolean r1,r2,r3,r4,r5,r6;
uint32_t timer1 = millis();
//rotate led pins
int L0 = 0; int L1 = 0; int L2 = 0; //disabled
int L3 = 36; int L4 = 40; int L5 = 44;
//status LED pins (red)
int alt_status = 24; int gps_status = 28; int temp_status = 32;
//TMP36 Pin Variables
int tmp36 = 0; //the analog pin the TMP36's Vout (sense) pin is connected to
int reading;   //the resolution is 10 mV / degree centigrade with a
float voltage; //500 mV offset to allow for negative temperatures
float temperatureF;
#define aref_voltage 3.3 // we tie 3.3V to ARef
//tri LED pins
int redPin = 46;
int greenPin = 48;
int bluePin = 50;
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
  //altimeter_setup();
  delay(500); //give the IMU time to start-up
  Accel_setup();
  logfile.println( \
  "yaw, pitch, roll, rawX (accel), rawY, rawZ, tmp36, " \
  "Time (HH:MM:SS), Date (MM/DD/YY)," 
  "GPS Fix, Fix Quality, Latitude, Longitude, " \
  "knots, altitude, # of satellite fixes");
  
  pinMode(alt_status, OUTPUT);
  pinMode(gps_status, OUTPUT);
  pinMode(temp_status, OUTPUT);
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT); 
  // ARef set externally (for TMP36)
  analogReference(EXTERNAL); 
}
void setColor(int red, int green, int blue)
{
  //#ifdef COMMON_ANODE
    red = 255 - red;
    green = 255 - green;
    blue = 255 - blue;
  //#endif
  analogWrite(redPin, red);
  analogWrite(greenPin, green);
  analogWrite(bluePin, blue);  
}
/************************************************************/
/*** Loop
/************************************************************/
void loop()
{
  
  GPS_loop();
  Accel_loop();
  tmp36_loop(); //in Altimeter.ino
  // approximately every 0.5 second or so, print out the current stats
  if (millis() - timer1 > 100) { 
    timer1 = millis(); // reset the timer
    
    #if ECHO_TO_SD
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
    #endif
  }
  
  //status pins
  (pressure < -900) ? digitalWrite(alt_status, HIGH) : digitalWrite(alt_status, LOW);
  (temperatureF < -100) ? digitalWrite(temp_status, HIGH) : digitalWrite(temp_status, LOW);
}




