void max31855_loop(long *pdata)
{
  /*Serial.println();
  Serial.print("Internal Temp = ");
  Serial.println(thermocouple.readInternal());
*/
  double c = thermocouple.readCelsius();
  if (isnan(c)) {
    Serial.println("Something wrong with thermocouple!");
  } else {
    //Serial.print("C = "); 
    //Serial.println(c);
    pdata[7]=c;
  }
}
