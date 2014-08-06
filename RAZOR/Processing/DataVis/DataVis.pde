import processing.opengl.*;
import processing.serial.*;
import processing.video.*;

float yaw = 0.0f;
float pitch = 0.0f;
float roll = 0.0f;
float yawOffset = 0.0f;

PFont font;

Movie myMovie;
Table table;
TableRow row;
int fps = 30;

float rawX, rawY, rawZ;
//float yaw, pitch roll;

void setup() {
  size(2000, 800, OPENGL);
  background(0);
  smooth();
  noStroke();
  frameRate(30);
  myMovie = new Movie(this, "/Users/jeffchin/Desktop/gopro.mp4");
  myMovie.loop();
  table = loadTable("/Users/jeffchin/Desktop/GPS006.CSV", "header");
  println(table.getRowCount() + " total rows in table"); 
  
  // Load font
  font = loadFont("Univers-66.vlw");
  textFont(font);
}

void draw() {
   // Reset scene
  background(0);
  lights();
  image(myMovie, 0, 0, 640, 400);
  if (frameCount%6==0){  
    row = table.getRow(frameCount);
    rawX = row.getFloat(" rawX (accel)");
    rawY = row.getFloat(" rawY");
    rawZ = row.getFloat(" rawZ");
    yaw = row.getFloat("yaw");
    pitch = row.getFloat(" pitch");
    roll = row.getFloat(" roll");
  
    fill(0);
    rect(600, 500, 160, 80);
    fill(50);
    text("rawX " + Float.toString(rawX), 600, 500, 160, 80);  // Text wraps within text box
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

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
  
}

float readFloat(Serial s) {
  // Convert from little endian (Razor) to big endian (Java) and interpret as float
  return Float.intBitsToFloat(s.read() + (s.read() << 8) + (s.read() << 16) + (s.read() << 24));
}

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
