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

void bmp_setup()
{
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
    Serial.print("Ooops, no BMP180 detected ... Check your wiring or I2C ADDR!");
    while(1);
  }else{
  /* Display some basic information on this sensor */
    displaySensorDetails();
  }
  Serial.println();
  Serial.println("----BMP183----------|----BMP180----------|-1Wi(DS)-|--SPI_K--|---A_K--|");
  Serial.println("--Press--Temp--Alt--|-Press---Temp---Alt--|--Temp--|--Temp---|--Temp--|"); 
  
}

void bmp180_loop(float *pdata)
{
    /* Get a new sensor event */ 
  sensors_event_t event;
  bmp180.getEvent(&event);
 
  /* Display the results (barometric pressure is measure in hPa) */
  if (event.pressure)
  {
    /* Display atmospheric pressue in hPa */
    /*Serial.print("180 Pressure:    ");
    Serial.print(event.pressure);
    Serial.println(" hPa");
    */
    pdata[3] = event.pressure;
    /* Calculating altitude with reasonable accuracy requires pressure    *
     * sea level pressure for your position at the moment the data is     *
     * converted, as well as the ambient temperature in degress           *
     * celcius.  If you don't have these values, a 'generic' value of     *
     * 1013.25 hPa can be used (defined as SENSORS_PRESSURE_SEALEVELHPA   *
     * in sensors.h), but this isn't ideal and will give variable         *
     * results from one day to the next.                                  *
     *                                                                    *
     * You can usually find the current SLP value by looking at weather   *
     * websites or from environmental information centers near any major  *
     * airport.                                                           *
     *                                                                    *
     * For example, for Paris, France you can check the current mean      *
     * pressure and sea level at: http://bit.ly/16Au8ol                   */
     
    /* First we get the current temperature from the BMP085 */
    float temperature;
    bmp180.getTemperature(&temperature);
    /*Serial.print("Temperature: ");
    Serial.print(temperature);
    Serial.println(" C");
    */
    if (temperature < 99){
      pdata[4] = temperature;
    }
    else
    {
      pdata[4] = 99;
    }
    /* Then convert the atmospheric pressure, and SLP to altitude         */
    /* Update this next line with the current SLP for better results      */
    float seaLevelPressure = SENSORS_PRESSURE_SEALEVELHPA;
    /*Serial.print("Altitude:    "); 
    Serial.print(bmp180.pressureToAltitude(seaLevelPressure,
                                        event.pressure)); 
    Serial.println(" m");
    Serial.println("");
    */
    
    pdata[5] = bmp180.pressureToAltitude(seaLevelPressure,event.pressure);
  }
  else
  {
    Serial.println("Sensor error");
  }
}
