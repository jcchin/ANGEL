
//I2C
#include <Wire.h>

//SD libraries
#include <SD.h>
#include <SPI.h>
#include "RTClib.h" //RTC
#define ECHO_TO_SD   1 // echo data to SDcard
#define PRINT_ALT 0//print alt (can't if using processing)
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

/************************************************************/
/*** Setup
/************************************************************/
void setup()
{
  Wire.begin();        // Join i2c bus
  Serial.begin(57600);  // init the Serial port to print the data to PC
  Serial3.begin(57600); // init the Serial3 port to get data from the IMU
  delay(500);
  initIMU();
  
  pinMode(7, OUTPUT); //blink LED
  pinMode(6, OUTPUT); //blink LED
  pinMode(5, OUTPUT); //blink LED
  pinMode(4, OUTPUT); //blink LED
  pinMode(3, OUTPUT); //blink LED
  pinMode(2, OUTPUT); //blink LED
  
  myPressure.begin(); // Get sensor online

  //Configure the sensor
  myPressure.setModeAltimeter(); // Measure altitude above sea level in meters
  //myPressure.setModeBarometer(); // Measure pressure in Pascals from 20 to 110 kPa
  myPressure.setOversampleRate(7); // Set Oversample to the recommended 128
  myPressure.enableEventFlags(); // Enable all three pressure and temp event flags
  // initialize the SD card
  Serial.print("Initializing SD card...");
  // make sure that the default chip select pin is set to
  // output, even if you don't use it:
  #if ECHO_TO_SD
    pinMode(10, OUTPUT);
    // see if the card is present and can be initialized:
    if (!SD.begin(10, 11, 12, 13)) {
      error("Card failed, or not present");
    }
    Serial.println("card initialized.");
    
    // create a new file
    char filename[] = "LOGGER00.CSV";
    for (uint8_t i = 0; i < 100; i++) {
      filename[6] = i/10 + '0';
      filename[7] = i%10 + '0';
      if (! SD.exists(filename)) {
        // only open a new file if it doesn't exist
        logfile = SD.open(filename, FILE_WRITE); 
        break;  // leave the loop!
      }
    }
    
    if (! logfile) {
      error("couldnt create file");
    }
    
    Serial.print("Logging to: ");
    Serial.println(filename);
  
    // connect to RTC
    Wire.begin();  
    if (!RTC.begin()) {
    logfile.println("RTC failed");
    }
  #endif  //ECHO_TO_SD 
}

/************************************************************/
/*** Loop
/************************************************************/
void loop()
{
  //forward all IMU to serial
  int inByte = Serial3.read();
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
    Serial3.write("#f");

    /************************************************************/
    /*** Get the IMU values
    /************************************************************/
    // the current field being received
    int fieldIndex = 0;            
    // search the Serial Buffer as long as the header character is found
    boolean found_HeaderChar = Serial3.find("#YPR=");
    if (found_HeaderChar)
    {
      // Get all 3 values (yaw, pitch, roll) from the Serial Buffer
      while(fieldIndex < NUMBER_OF_FIELDS)
      {
        rpy[fieldIndex++] = Serial3.parseFloat();
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
      (led==0) ? digitalWrite(7, HIGH) : digitalWrite(7, LOW);
      (led==1) ? digitalWrite(6, HIGH) : digitalWrite(6, LOW);
      (led==2) ? digitalWrite(5, HIGH) : digitalWrite(5, LOW);
      (led==3) ? digitalWrite(4, HIGH) : digitalWrite(4, LOW);
      (led==4) ? digitalWrite(3, HIGH) : digitalWrite(3, LOW);
      (led==5) ? digitalWrite(2, HIGH) : digitalWrite(2, LOW);
        
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

//SD error handling
void error(char *str)
{
  Serial.print("error: ");
  Serial.println(str);
  // red LED indicates error
  //digitalWrite(redLEDpin, HIGH);
  while(1);
}

/********************************/
/*** Initialize Functions
/********************************/
void initIMU()
{
  // Output angles in TEXT format & Turn off continuous streaming output & Disable error message output
  Serial3.write("#ot#o0#oe0");
  Serial3.flush();
}

/********************************/
/*** Hard Coded Matrix Math Functions
/********************************/

void dot3(float R[][3], float a[3], float b[3]) //hardcoded dot product for [3x3].[3x1]=[3x1]
{
  for (int c=0; c<3; c++)
  {
    float op = 0;
    for (int z=0; z<3; z++){
      op+=R[c][z]*a[z];
    }
    b[c] = op;
  }
}

float dot1(float a[3], float b[3]) //hardcoded dot product for [1x3].[3x1]=[1x1]
{
  float op = 0;
  for (int z=0; z<3; z++){
    op+=a[z]*b[z];
  }
  return op;
}

void R_b_to_i(float phi, float theta, float psi, float R[][3]){
  //Convert from body coodrinates to inertial coordinates
  //http://www.chrobotics.com/library/understanding-euler-angles
    phi *= PI/180; //convert from deg to radians
    theta *= PI/180;
    psi *= PI/180;
    //float R[3][3];
    R[0][0] = cos(psi)*cos(theta);
    R[0][1] = cos(psi)*sin(phi)*sin(theta) - cos(phi)*sin(psi);
    R[0][2] = sin(phi)*sin(psi)+cos(phi)*cos(psi)*sin(theta);
    R[1][0] = cos(theta)*sin(psi);
    R[1][1] = cos(phi)*cos(psi)+sin(phi)*sin(psi)*sin(theta);
    R[1][2] = cos(phi)*sin(psi)*sin(theta) - cos(psi)*sin(phi);
    R[2][0] = -sin(theta);
    R[2][1] = cos(theta)*sin(phi);
    R[2][2] = cos(phi)*cos(theta);
}

int pick(float R[][3])
{
  float a1[3] = {0, 0, 1};
  float a2[3] = {0, 1, 0};
  float a3[3] = {1, 0, 0};
  float a4[3] = {0, 0, -1};
  float a5[3] = {0, -1, 0};
  float a6[3] = {-1, 0, 0};
  float d1, d2, d3, d4, d5, d6;
  
  d1 = convert(R, a1);
  d2 = convert(R, a2);
  d3 = convert(R, a3);
  d4 = convert(R, a4);
  d5 = convert(R, a5);
  d6 = convert(R, a6);
  
  return minI(d1, d2, d3, d4, d5, d6); 
}

float convert(float R[][3], float a[3]) 
//converts body frame to inertial frame,
//then calculates angle between [0,0,1] on the intertial frame with inputted axis from the input
//RM [3x3] dot [0,0,1] -->  N'[3x1] dot a[3x1] --> inverse cos --> convert to degrees
{
  float ref[] = {0, 0, 1};
  float b[3];
  float c;
  dot3(R,ref,b); //returns b [3x1]
  c = dot1(b,a); //returns foo [1x1]
  return acos(c)*180/PI;
}

int minI(float d1, float d2, float d3, float d4, float d5, float d6) //find the index of the minimum
{
  float array[] = {d1, d2, d3, d4, d5, d6};
  int index = 0;
  float mini = array[0];
  for (int z=1; z<=5; z++){
    if (mini > array[z]){
      mini = array[z];
      index = z;
    }
  }
  return index;
}
