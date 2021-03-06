//I2C
#include <Wire.h>
//SD libraries
#include <SD.h>
//SPI
#include <SPI.h>
//Barometers and Thermocouple
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP183.h>
#include <Adafruit_BMP085_U.h>
#include <Adafruit_MAX31855.h>
//GPS libraries
#include <Adafruit_GPS.h>
#include <SoftwareSerial.h> //not actually used, keeps Ada_GPS from barking
#include <avr/sleep.h>

#define BMP183_CLK  38
#define BMP183_SDO  36  // AKA MISO
#define BMP183_SDI  34  // AKA MOSI

//courner one
#define MAX1_DO 26 //no power pin needed, sitting on 5v rail
#define MAX1_CS 28
#define MAX1_CLK 30
Adafruit_MAX31855 thermocouple1(MAX1_CLK, MAX1_CS, MAX1_DO);
//middle lower
#define MAX2_PWR 37 
#define MAX2_DO 43
#define MAX2_CS 45
#define MAX2_CLK 47
Adafruit_MAX31855 thermocouple2(MAX2_CLK, MAX2_CS, MAX2_DO);
//sitting on top
#define MAX3_PWR 2 
#define MAX3_GND 3 
#define MAX3_DO 4
#define MAX3_CS 5
#define MAX3_CLK 6
Adafruit_MAX31855 thermocouple3(MAX3_CLK, MAX3_CS, MAX3_DO);
// You'll also need a chip-select pin, use any pin!
#define BMP183_CS   32
#define SENSORS_PRESSURE_SEALEVELHPA 1000
Adafruit_BMP183 bmp183 = Adafruit_BMP183(BMP183_CLK, BMP183_SDO, BMP183_SDI, BMP183_CS);
Adafruit_BMP085_Unified bmp180 = Adafruit_BMP085_Unified(10085);

#include "RTClib.h" //RTC
#define ECHO_TO_SD  1 // echo data to SDcard
#define PRINT_ALT   0 //print alt (can't if using processing)
uint32_t timer1 = millis(); //sd timer
#define GPSECHO  false //false = no echo to Serial, true = raw GPS sentences for debugging
#define LOG_FIXONLY false //false = always log, true = log only when GPS fix
//GPS + Logging Stuff
RTC_DS1307 RTC; // define the Real Time Clock object
const int chipSelect = 10;// for the GPSshield, use digital pin 10 for the SD CS line
File logfile;// the logging file
#define ledPin 13 //pin for GPS LED (wired for 13 on GPS shield)

HardwareSerial gpsSerial = Serial3;
Adafruit_GPS GPS(&Serial3);
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
const int NUMBER_OF_FIELDS = 6; // how many comma seperated fields we expect                                           
float rpy[NUMBER_OF_FIELDS];    // array holding values for all the fields
float yaw;float pitch;float roll;float rawX;float rawY;float rawZ;

float pdata0;float pdata1;float pdata2;float pdata3;float pdata4;float pdata5;float pdata6;float pdata7;float pdata8;

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
  
  Serial.begin(115200);  // init the Serial port to print the data to PC
  Serial2.begin(57600); // init the Serial2 port to get data from the IMU
  GPS_setup();
  delay(500);

  initIMU();
  bmp_setup();
  
  logfile.println( \
  "yaw, pitch, roll, rawX (accel), rawY, rawZ, " \
  "3P, 3T, 3A, 0P, 0T, 0A, " \
  "T1, T2, T3, " \
  "Time (HH:MM:SS), Date (MM/DD/YY)," \
  "GPS Fix, Fix Quality, Latitude, Longitude, " \
  "knots, altitude, # of satellite fixes");
  
  pinMode(MAX2_PWR, OUTPUT); //power thermocouples
  pinMode(MAX3_PWR, OUTPUT);
  pinMode(MAX3_GND, OUTPUT);
}

/************************************************************/
/*** Loop
/************************************************************/
void loop()
{
  Accel_loop();
  digitalWrite(MAX2_PWR, HIGH);
  digitalWrite(MAX3_PWR, HIGH);
  digitalWrite(MAX3_GND, LOW);
  bmp180_loop(); //I2C
  bmp183_loop(); //SPI
  max31855_loop(); //SPI
  GPS_loop();
  //Serial.print("---");Serial.print(pdata0);Serial.print("----");Serial.print(pdata1);Serial.print("---");Serial.print(pdata2);Serial.print("---|");
  //Serial.print("-");Serial.print(pdata3);Serial.print("------");Serial.print(pdata4);Serial.print("------");Serial.print(pdata5);Serial.print("---|");
  //Serial.print("---");Serial.print(pdata6);Serial.print("-");Serial.print(pdata7);Serial.print("-");Serial.print(pdata8);
  //Serial.println();
  //Serial.print(GPS.latitude, 4); Serial.print(GPS.lat);
  //Serial.print(", "); 
  //Serial.print(GPS.longitude, 4); Serial.print(GPS.lon);
  //Serial.print(",");
  //Serial.print(GPS.speed);
  //Serial.print(",");
  //Serial.print(GPS.altitude);Serial.print(",");
  //Serial.println((int)GPS.satellites);

  Serial.println();
  Serial.print(GPS.hour, DEC); Serial.print(':');
  Serial.print(GPS.minute, DEC); Serial.print(':');
  Serial.print(GPS.seconds, DEC); Serial.print('.');
  Serial.print(GPS.milliseconds); 
  
  if (millis() - timer1 > 100) { 
    timer1 = millis(); // reset the timer
    DateTime now;
    now = RTC.now();
    #if ECHO_TO_SD
      // log time
      logfile.print(yaw);
      logfile.print(',');
      logfile.print(pitch);
      logfile.print(',');
      logfile.print(roll);
      logfile.print(',');
      logfile.print(rawX);
      logfile.print(',');
      logfile.print(rawY);
      logfile.print(',');
      logfile.print(rawZ);
      logfile.print(',');
      logfile.print(pdata0);logfile.print(",");logfile.print(pdata1);logfile.print(",");logfile.print(pdata2);logfile.print(",");
      logfile.print(pdata3);logfile.print(",");logfile.print(pdata4);logfile.print(",");logfile.print(pdata5);logfile.print(",");
      logfile.print(pdata6);logfile.print(",");logfile.print(pdata7);logfile.print(",");logfile.print(pdata8);logfile.print(",");
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
}


