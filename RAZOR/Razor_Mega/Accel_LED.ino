void Accel_setup() {
  initIMU();
  pinMode(22, OUTPUT); //blink LED
  pinMode(23, OUTPUT); //blink LED
  pinMode(24, OUTPUT); //blink LED
  pinMode(25, OUTPUT); //blink LED
  pinMode(26, OUTPUT); //blink LED
  pinMode(27, OUTPUT); //blink LED
  
}

void Accel_loop(){
  //forward all IMU to serial
  int inByte = imuSerial.read();
  Serial.write(inByte);
  
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
    imuSerial.write("#f");

    /************************************************************/
    /*** Get the IMU values
    /************************************************************/
    // the current field being received
    int fieldIndex = 0;            
    // search the Serial Buffer as long as the header character is found
    boolean found_HeaderChar = imuSerial.find("#YPR=");
    if (found_HeaderChar)
    {
      // Get all 3 values (yaw, pitch, roll) from the Serial Buffer
      while(fieldIndex < NUMBER_OF_FIELDS)
      {
        rpy[fieldIndex++] = imuSerial.parseFloat();
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
      ////Serial.print(",");
      // print IMU values
      for(fieldIndex=0; fieldIndex < NUMBER_OF_FIELDS; fieldIndex++)
      {
        ////Serial.print(rpy[fieldIndex]);
        ////Serial.print(",");
        if (fieldIndex == 0){
          yaw = rpy[fieldIndex];
        }if  (fieldIndex == 1){
          pitch = rpy[fieldIndex];
        }if  (fieldIndex == 2){
          roll = rpy[fieldIndex];
        }
      }
      ////Serial.print("");
      //Convert body frame to inertial frame and find closest face
      float R[3][3];
      int led;
      R_b_to_i(yaw, pitch, roll, R);
      led = pick(R);
      ////Serial.print(led);
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
      
      if (altitude > -10 & pressure < 10000){ //stop reading if # are bogus
        altimeter_loop();
      }
      
      #if ECHO_TO_SD
        //SD logging
        DateTime now;
        now = RTC.now();
        // log time
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
        //Serial.println();
        logfile.print(',');;
        logfile.flush();
      #endif
  }
}
