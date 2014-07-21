void altimeter_setup(){
  
  myPressure.begin(); // Get sensor online

  //Configure the sensor
  myPressure.setModeAltimeter(); // Measure altitude above sea level in meters
  //myPressure.setModeBarometer(); // Measure pressure in Pascals from 20 to 110 kPa
  myPressure.setOversampleRate(7); // Set Oversample to the recommended 128 (2^n)
  myPressure.enableEventFlags(); // Enable all three pressure and temp event flags
}

void altimeter_loop()
{
  altitude = myPressure.readAltitude();
  pressure = myPressure.readPressure();
  temperature = myPressure.readTempF();
  
  //Serial.println();
  #if PRINT_ALT
  Serial.print(altitude, 2);
  Serial.print(",");
  Serial.print(pressure, 2);
  Serial.print(",");
  Serial.print(temperature, 2);
  Serial.println();
  #endif
  
}
