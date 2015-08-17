void altimeter_setup(){
  
  myPressure.begin(); // Get sensor online

  //Configure the sensor
  myPressure.setModeActive();
  myPressure.setModeBarometer(); // Measure altitude above sea level in meters
  //myPressure.setModeBarometer(); // Measure pressure in Pascals from 20 to 110 kPa
  myPressure.setOversampleRate(3); // Set Oversample to the recommended 128 (2^n)
  myPressure.enableEventFlags(); // Enable all three pressure and temp event flags
}

void tmp36_loop() //?
{
  //getting the voltage reading from the temperature sensor
  reading = analogRead(tmp36);
  // converting that reading to voltage, for 3.3v arduino use 3.3
  voltage = reading * aref_voltage / 1024;
  
  //converting from 10 mv per degree wit 500 mV offset
  //to degreesC ((voltage - 500mV) times 100) to degrees F (9/5 + 32) + 5 degree offset
  temperatureF = (((voltage - 0.5) * 100) * 9.0 / 5.0) + 37.0;
}

void altimeter_loop()
{
  //altitude = myPressure.readAltitude();
  pressure = myPressure.readPressure();
  //temperature = myPressure.readTempF();
  //Serial.println();
  #if PRINT_ALT
  Serial.print(altitude, 2);
  Serial.print(",");
  Serial.print(pressure/101325.0, 2);
  Serial.print(",");
  Serial.print(temperature, 2);
  Serial.println();
  #endif
  
}
