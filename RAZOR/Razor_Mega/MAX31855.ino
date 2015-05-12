void max31855_loop(){


    //Serial.print("Internal Temp1 = ");
    //Serial.println(thermocouple1.readInternal());

    double c = thermocouple1.readCelsius();
    if (isnan(c)) {
      Serial.println("Something wrong with thermocouple1!");
    } else {
      Serial.print("C1 = "); 
      Serial.println(c);
    }
    
    //Serial.print("Internal Temp2 = ");
    //Serial.println(thermocouple2.readInternal());

    double c2 = thermocouple2.readCelsius();
    if (isnan(c2)) {
      Serial.println("Something wrong with thermocouple2!");
    } else {
      Serial.print("C2 = "); 
      Serial.println(c2);
    }
    
    //Serial.print("Internal Temp3 = ");
    //Serial.println(thermocouple3.readInternal());

    double c3 = thermocouple3.readCelsius();
    if (isnan(c3)) {
      Serial.println("Something wrong with thermocouple3!");
    } else {
      Serial.print("C3 = "); 
      Serial.println(c3);
    }


}
