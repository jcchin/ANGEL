#include <SPI.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP183.h>

// For hardware SPI:
// Connect SCK to SPI Clock, SDO to SPI MISO, and SDI to SPI MOSI
// See  http://arduino.cc/en/Reference/SPI for your Arduino's SPI pins!
// On UNO, Clock is #13, SDO/MISO is #12 and SDI/MOSI is #11

// You can also use software SPI and define your own pins!
#define BMP183_CLK  13
#define BMP183_SDO  12  // AKA MISO
#define BMP183_SDI  11  // AKA MOSI

// You'll also need a chip-select pin, use any pin!
#define BMP183_CS   10

#define SENSORS_PRESSURE_SEALEVELHPA 1000

// initialize with hardware SPI
//Adafruit_BMP183 bmp = Adafruit_BMP183(BMP183_CS);
// or initialize with software SPI and use any 4 pins
Adafruit_BMP183 bmp183 = Adafruit_BMP183(BMP183_CLK, BMP183_SDO, BMP183_SDI, BMP183_CS);
/**************************************************************************/
/***** DS18B20 One-Wire Setup *******/
#include <OneWire.h>

// OneWire DS18S20, DS18B20, DS1822 Temperature Example
//
// http://www.pjrc.com/teensy/td_libs_OneWire.html
//
// The DallasTemperature library can do all this work for you!
// http://milesburton.com/Dallas_Temperature_Control_Library

OneWire  ds(8);  // on pin 10 (a 4.7K resistor is necessary)

/**************************************************************************/
/***** MAX31855 SPI K-thermo Setup *******/
#include "Adafruit_MAX31855.h"
// Example creating a thermocouple instance with software SPI on any three
// digital IO pins.
#define DO   3
#define CS   4
#define CLK  5
Adafruit_MAX31855 thermocouple(CLK, CS, DO);

/**************************************************************************/
/***** BMP180 Setup *******/
#include <Wire.h>
#include <Adafruit_BMP085_U.h>

/* This driver uses the Adafruit unified sensor library (Adafruit_Sensor),
   which provides a common 'type' for sensor data and some helper functions.
   
   To use this driver you will also need to download the Adafruit_Sensor
   library and include it in your libraries folder.

   You should also assign a unique ID to this sensor for use with
   the Adafruit Sensor API so that you can identify this particular
   sensor in any data logs, etc.  To assign a unique ID, simply
   provide an appropriate value in the constructor below (12345
   is used by default in this example).
   
   Connections
   ===========
   Connect SCL to analog 5
   Connect SDA to analog 4
   Connect VDD to 3.3V DC
   Connect GROUND to common ground
    
   History
   =======
   2013/JUN/17  - Updated altitude calculations (KTOWN)
   2013/FEB/13  - First version (KTOWN)
*/
   
Adafruit_BMP085_Unified bmp180 = Adafruit_BMP085_Unified(10085);
/**************************************************************************/
/*
    Displays some basic information on this sensor from the unified
    sensor API sensor_t type (see Adafruit_Sensor for more information)
*/
/**************************************************************************/
void displaySensorDetails(void)
{
  sensor_t sensor;
  bmp180.getSensor(&sensor);
  Serial.println("------------------------------------");
  Serial.print  ("Sensor:       "); Serial.println(sensor.name);
  Serial.print  ("Driver Ver:   "); Serial.println(sensor.version);
  Serial.print  ("Unique ID:    "); Serial.println(sensor.sensor_id);
  Serial.print  ("Max Value:    "); Serial.print(sensor.max_value); Serial.println(" hPa");
  Serial.print  ("Min Value:    "); Serial.print(sensor.min_value); Serial.println(" hPa");
  Serial.print  ("Resolution:   "); Serial.print(sensor.resolution); Serial.println(" hPa");  
  Serial.println("------------------------------------");
  Serial.println("");
  delay(500);
}
/**************************************************************************/
/*
    Arduino setup function (automatically called at startup)
*/
/**************************************************************************/
void setup(void) 
{
  Serial.begin(9600);
  Serial.println("BMP183 and BMP180 Pressure Sensor Test"); Serial.println("");
  
  /* Initialise the sensor */
  if(!bmp183.begin())
  {
    /* There was a problem detecting the BMP183 ... check your connections */
    Serial.print("Ooops, no BMP183 detected ... Check your wiring!");
    while(1);
  }
  if(!bmp180.begin())
  {
    /* There was a problem detecting the BMP085 ... check your connections */
    Serial.print("Ooops, no BMP085 detected ... Check your wiring or I2C ADDR!");
    while(1);
  }else{
  /* Display some basic information on this sensor */
    displaySensorDetails();
  }
}

/**************************************************************************/
/*
    Arduino loop function, called once 'setup' is complete (your own code
    should go here)
*/
/**************************************************************************/
void loop(void) 
{
    bmp183_loop(); //SPI
    bmp180_loop(); //I2C
    DS18B20_loop(); //1-wire waterproof temp
    max31855_loop(); //SPI thermocouple
    AD8495_loop(); //Analog thermocouple
    Serial.println("----------------");
    delay(1000);
    
}
