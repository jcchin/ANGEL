void bmp180_loop(long *pdata)
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
    if (temperature > 99){
      pdata[5] = temperature;
    }
    else
    {
      pdata[5] = 99;
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
