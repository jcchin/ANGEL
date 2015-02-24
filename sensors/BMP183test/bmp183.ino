void bmp183_loop(void)
{
  /* Display atmospheric pressue in Pascals */
    Serial.print("183 Pressure:    ");
    Serial.print(bmp183.getPressure());
    Serial.print(" Pascals / ");
    Serial.print(bmp183.getPressure() / 100);
    Serial.println(" millibar (hPa)");

    /* First we get the current temperature from the BMP085 */
    float temperature;
    temperature = bmp183.getTemperature();
    Serial.print("Temperature: ");
    Serial.print(temperature);
    Serial.println(" C");
    
    /* Calculating altitude with reasonable accuracy requires pressure    *
     * sea level pressure for your position at the moment the data is     *
     * converted. If you don't have these values, a 'generic' value of    *
     * 1013.25 mbar can be used (defined as SENSORS_PRESSURE_SEALEVELHPA  *
     * in sensors.h), but this isn't ideal and will give variable         *
     * results from one day to the next.                                  *
     *                                                                    *
     * You can usually find the current SLP value by looking at weather   *
     * websites or from environmental information centers near any major  *
     * airport.                                                           *
     *                                                                    *
     * For example, for Paris, France you can check the current mean      *
     * pressure and sea level at: http://bit.ly/16Au8ol                   */
     

    /* Then convert the atmospheric pressure, SLP and temp to altitude    */
    /* Update this next line with the current SLP for better results      */
    float seaLevelPressure = SENSORS_PRESSURE_SEALEVELHPA; // should be ~1000
    Serial.print("Sea level pressure: "); 
    Serial.print(SENSORS_PRESSURE_SEALEVELHPA);
    Serial.println(" millibar/hPa");
    
    Serial.print("Altitude:    "); 
    Serial.print(bmp183.getAltitude(seaLevelPressure)); 
    Serial.println(" m");
    Serial.println("");

  
}
