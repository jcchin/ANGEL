/********************************/
/*** Initialize Functions
/********************************/

void initIMU()
{
  // Output angles in TEXT format & Turn off continuous streaming output & Disable error message output
  Serial2.write("#ot#o0#oe0");
  Serial2.flush();
}

void Accel_loop()
{
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
    boolean found_HeaderChar = Serial2.find("YPR=");

    if (found_HeaderChar)
    {
      // Get all 6 values (yaw, pitch, roll, accelX,Y,Z) from the Serial Buffer
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
      //Serial.print(",");
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
      //Serial.println();
      //Serial.println(yaw);
    }

    timer = millis();
  }
}
