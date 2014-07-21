import processing.opengl.*;
import processing.serial.*;

final static int SERIAL_PORT_NUM = 5;
final static int SERIAL_PORT_BAUD_RATE = 115200;

float yaw = 0.0f;
float pitch = 0.0f;
float roll = 0.0f;
float yawOffset = 0.0f;

PFont font;
Serial serial;

boolean synched = false;

void drawArrow(float headWidthFactor, float headLengthFactor) {
  float headWidth = headWidthFactor * 200.0f;
  float headLength = headLengthFactor * 200.0f;
  pushMatrix();
  // Draw base
  translate(0, 0, -100);
  box(100, 100, 200);
  // Draw pointer
  translate(-headWidth/2, -50, -100);
  beginShape(QUAD_STRIP);
    vertex(0, 0 ,0);
    vertex(0, 100, 0);
    vertex(headWidth, 0 ,0);
    vertex(headWidth, 100, 0);
    vertex(headWidth/2, 0, -headLength);
    vertex(headWidth/2, 100, -headLength);
    vertex(0, 0 ,0);
    vertex(0, 100, 0);
  endShape();
  beginShape(TRIANGLES);
    vertex(0, 0, 0);
    vertex(headWidth, 0, 0);
    vertex(headWidth/2, 0, -headLength);
    vertex(0, 100, 0);
    vertex(headWidth, 100, 0);
    vertex(headWidth/2, 100, -headLength);
  endShape();
  popMatrix();
}

void drawBoard() {
  pushMatrix();
  rotateY(-radians(yaw - yawOffset));
  rotateX(-radians(pitch));
  rotateZ(radians(roll)); 
  // Board body
  fill(255, 0, 0);
  box(250, 50, 400);
  // Forward-arrow
  pushMatrix();
  translate(0, 0, -200);
  scale(0.5f, 0.2f, 0.25f);
  fill(0, 255, 0);
  drawArrow(1.0f, 2.0f);
  popMatrix();
  popMatrix();
}

// Skip incoming serial stream data until token is found
boolean readToken(Serial serial, String token) {
  // Wait until enough bytes are available
  if (serial.available() < token.length())
    return false;
  // Check if incoming bytes match token
  for (int i = 0; i < token.length(); i++) {
    if (serial.read() != token.charAt(i))
      return false;
  } 
  return true;
}

// Global setup
void setup() {
  // Setup graphics
  size(640, 480, OPENGL);
  smooth();
  noStroke();
  frameRate(50);
  
  // Load font
  font = loadFont("Univers-66.vlw");
  textFont(font);
  
  // Setup serial port I/O
  println("AVAILABLE SERIAL PORTS:");
  println(Serial.list());
  String portName = Serial.list()[SERIAL_PORT_NUM];
  println();
  println("HAVE A LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
  println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
  serial = new Serial(this, portName, SERIAL_PORT_BAUD_RATE);
}

void setupRazor() {
  println("Trying to setup and synch Razor...");
  // On Mac OSX and Linux (Windows too?) the board will do a reset when we connect, which is really bad.
  // See "Automatic (Software) Reset" on http://www.arduino.cc/en/Main/ArduinoBoardProMini
  // So we have to wait until the bootloader is finished and the Razor firmware can receive commands.
  // To prevent this, disconnect/cut/unplug the DTR line going to the board. This also has the advantage,
  // that the angles you receive are stable right from the beginning. 
  delay(3000);  // 3 seconds should be enough
}

float readFloat(Serial s) {
  // Convert from little endian (Razor) to big endian (Java) and interpret as float
  return Float.intBitsToFloat(s.read() + (s.read() << 8) + (s.read() << 16) + (s.read() << 24));
}

void draw() {
   // Reset scene
  background(0);
  lights();
  while (serial.available() > 0) {
    String inBuffer =  serial.readString();   
    String[] list;
    if (inBuffer != null) {
      println(inBuffer);
      list = split(inBuffer, ",");
      if(list.length == 5){
        yaw = Float.parseFloat(list[1]);
        pitch = Float.parseFloat(list[2]);
        roll = Float.parseFloat(list[3]);
      }
    }
  }

  // Draw board
  pushMatrix();
  translate(width/2, height/2, -350);
  drawBoard();
  popMatrix();
  
  textFont(font, 20);
  fill(255);
  textAlign(LEFT);

  // Output info text
  text("Point FTDI connector towards screen and press 'a' to align", 10, 25);

  // Output angles
  pushMatrix();
  translate(10, height - 10);
  textAlign(LEFT);
  text("Yaw: " + ((int) yaw), 0, 0);
  text("Pitch: " + ((int) pitch), 150, 0);
  text("Roll: " + ((int) roll), 300, 0);
  popMatrix();
}

void keyPressed() {
  switch (key) {
    case '0':  // Turn Razor's continuous output stream off
      serial.write("#o0");
      break;
    case '1':  // Turn Razor's continuous output stream on
      serial.write("#o1");
      break;
    case 'f':  // Request one single yaw/pitch/roll frame from Razor (use when continuous streaming is off)
      serial.write("#f");
      break;
    case 'a':  // Align screen with Razor
      yawOffset = yaw;
  }
}



