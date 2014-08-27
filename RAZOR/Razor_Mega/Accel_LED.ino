void Accel_setup() {
  initIMU();
  pinMode(L0, OUTPUT); //blink LED
  pinMode(L1, OUTPUT); //blink LED
  pinMode(L2, OUTPUT); //blink LED
  pinMode(L3, OUTPUT); //blink LED
  pinMode(L4, OUTPUT); //blink LED
  pinMode(L5, OUTPUT); //blink LED
  
}

void Accel_loop(){
  //forward all IMU to serial
  int inByte = imuSerial.read();
  //Serial.write(inByte);
  
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
      Serial.print(",");
      // print IMU values
      for(fieldIndex=0; fieldIndex < NUMBER_OF_FIELDS; fieldIndex++)
      {
        if (fieldIndex < 3){
          Serial.print(rpy[fieldIndex]);
          Serial.print(",");
         }
        if (fieldIndex == 0){
          yaw = rpy[fieldIndex];
        }if  (fieldIndex == 1){
          pitch = rpy[fieldIndex];
        }if  (fieldIndex == 2){
          roll = rpy[fieldIndex];
        }if  (fieldIndex == 3){
          rawX = rpy[fieldIndex];
        }if  (fieldIndex == 4){
          rawY = rpy[fieldIndex];
        }if  (fieldIndex == 5){
          rawZ = rpy[fieldIndex];
        }
      }
      Serial.println();
      int led;
      
      led = rawPick(rawX, rawY, rawZ);
      
      //Convert body frame to inertial frame and find closest face
      //float R[3][3];
      //R_b_to_i(yaw, pitch, roll, R);
      //led = pick(R);
      
      ////Serial.print(led);
      (led==5) ? digitalWrite(L0, HIGH) : digitalWrite(L0, LOW);//tilt forward
      (led==1) ? digitalWrite(L1, HIGH) : digitalWrite(L1, LOW);
      (led==2) ? digitalWrite(L2, HIGH) : digitalWrite(L2, LOW);
      (led==3) ? digitalWrite(L3, HIGH) : digitalWrite(L3, LOW); //tilt left
      (led==4) ? digitalWrite(L4, HIGH) : digitalWrite(L4, LOW); //default
      (led==0) ? digitalWrite(L5, HIGH) : digitalWrite(L5, LOW);
        
      }else{
        r1 = false; r2 = false; r3 = false; r4 = false; r5 = false; r6 = false;
      }
      
      timer = millis();
      
     //#if PRINT_ALT 
     //   if (pressure > -900){ //stop reading if # are bogus
     //     altimeter_loop();
     //   }
     //#endif
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
        logfile.print(rawX);
        logfile.print(',');
        logfile.print(rawY);
        logfile.print(',');
        logfile.print(rawZ);
        logfile.print(',');
        //logfile.print(altitude);
        //logfile.print(',');
        //logfile.print(pressure);
        //logfile.print(',');
        //logfile.print(temperature);
        //logfile.print(',');
        logfile.print(temperatureF); //tmp36
        //Serial.println();
        logfile.print(',');;
        logfile.flush();
      #endif
  }
}
