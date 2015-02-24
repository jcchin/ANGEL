void AD8495_loop(void) //analog thermocouple
{
  int sensorValue = analogRead(A8);
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  float voltage = sensorValue * (5.0 / 1023.0);
  float temp = (voltage - 1.25)/0.005;
  // print out the value you read:
  Serial.print("analog voltage: ");
  Serial.println(temp);
}
