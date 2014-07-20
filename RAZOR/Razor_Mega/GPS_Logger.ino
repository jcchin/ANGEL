 
void GPS_setup() { 
  
  Serial.println("\r\nUltimate GPSlogger Shield");
  pinMode(ledPin, OUTPUT);

  GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCGGA); // uncomment to turn on RMC (recommended minimum) and GGA (fix data) including altitude
  // GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCONLY); // uncomment to turn on only the "minimum recommended" data
  // For logging data, we don't suggest using anything but either RMC only or RMC+GGA
  // to keep the log files at a reasonable size
  GPS.sendCommand(PMTK_SET_NMEA_UPDATE_5HZ);   //// Set the update rate: 1 or 5 Hz
  GPS.sendCommand(PGCMD_NOANTENNA);// Turn off updates on antenna status, if the firmware permits it
  
  #if ECHO_TO_SD
    // initialize the SD card
    Serial.println("Initializing SD card...");
    // make sure that the default chip select pin is set to
    // output, even if you don't use it:
    pinMode(10, OUTPUT);
    
    // see if the card is present and can be initialized:
    if (!SD.begin(10, 11, 12, 13)) {
      Serial.println("Card failed, or not present");
      uint8_t i = 2;
      error(i);
    }
    
    char filename[15];
    strcpy(filename, "GPS000.CSV");
    for (uint16_t i = 0; i < 1000; i++) { //go up to GPS999.CSV
      filename[3] = '0' + i/100;
      filename[4] = '0' + (i/10)%10;
      filename[5] = '0' + i%10;
      // create if does not exist, do not open existing, write, sync after write
      if (! SD.exists(filename)) { // only open a new file if it doesn't exist
        logfile = SD.open(filename, FILE_WRITE); 
        break;
      }
    }
    if(! logfile ) {
      Serial.print("Couldnt create "); Serial.println(filename);
      error(3);
    }
    Serial.print("Writing to "); Serial.println(filename);
  #endif  //ECHO_TO_SD 
    
  Serial.println("Ready!");
} //end GPS_setup()

void GPS_loop() {
  char c = GPS.read();
  if (GPSECHO)//GPSECHO
     if (c)   Serial.print(c);

  // if a sentence is received, we can check the checksum, parse it...
  if (GPS.newNMEAreceived()) {
    // a tricky thing here is if we print the NMEA sentence, or data
    // we end up not listening and catching other sentences! 
    // so be very wary if using OUTPUT_ALLDATA and trying to print out data
    //Serial.println(GPS.lastNMEA());   // this also sets the newNMEAreceived() flag to false
        
    if (!GPS.parse(GPS.lastNMEA()))   // this also sets the newNMEAreceived() flag to false
      return;  // we can fail to parse a sentence in which case we should just wait for another
    
    // Sentence parsed! 
    Serial.println("OK");
    if (LOG_FIXONLY && !GPS.fix) {
        Serial.print("No Fix");
        return;
    }

    // Rad. lets log it!
    Serial.println("Log");
    
    //char *altptr;
    //sprintf(altptr, ", %f", GPS.altitude);
    char *lastNMEA = GPS.lastNMEA();
    *stringptr = *lastNMEA;
    
    //char *totalLine = (char *)malloc(strlen(altptr) + strlen(stringptr) + 1);
    //if (totalLine != NULL)
    //{
    //   strcpy(totalLine, altptr);
    //   strcat(totalLine, stringptr);
    //}
    
  } //end GPS.newNMEAreceived()
}

// read a Hex value and return the decimal equivalent
uint8_t parseHex(char c) {
  if (c < '0')
    return 0;
  if (c <= '9')
    return c - '0';
  if (c < 'A')
    return 0;
  if (c <= 'F')
    return (c - 'A')+10;
}

// blink out an error code
void error(uint8_t errno) {
/*
  if (SD.errorCode()) {
    putstring("SD error: ");
    Serial.print(card.errorCode(), HEX);
    Serial.print(',');
    Serial.println(card.errorData(), HEX);
  }
  */
  //Serial.print("error: ");
  Serial.println(errno);
  while(1) {
    uint8_t i;
    for (i=0; i<errno; i++) {
      digitalWrite(ledPin, HIGH);
      delay(100);
      digitalWrite(ledPin, LOW);
      delay(100);
    }
    for (i=errno; i<10; i++) {
      delay(200);
    }
  }
}
