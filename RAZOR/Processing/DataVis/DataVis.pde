import processing.opengl.*;
import processing.serial.*;
import processing.video.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;

UnfoldingMap map;

Location locationCleve = new Location(41f, -81f);

float yaw = 0.0f;
float pitch = 0.0f;
float roll = 0.0f;
float yawOffset = 0.0f;
float theta;

PFont font;

Movie myMovie;
Table table;
TableRow row;
int fps = 30;

float rawX, rawY, rawZ;
float alt, pressure, temp;
float sats, knots;
float lat=-81.88;
float lon= 41.4;

void setup() {
  size(1280, 720, OPENGL);
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
  
  map = new UnfoldingMap(this);
  map.setTweening(true);
  map.zoomAndPanTo(new Location(41.40015f, -81.8756f), 13);
  MapUtils.createDefaultEventDispatcher(this, map);
}

void draw() {
   // Reset scene
  background(0);
  translate(-600,300,-500);
  map.draw();
  // Draws locations on screen positions according to their geo-locations.
  // Fixed-size marker
  locationCleve = new Location(lon, lat);
  ScreenPosition posCleve = map.getScreenPosition(locationCleve);
  translate(600,-300,500);
  lights();
  image(myMovie, 0, 0, 640, 360);
  if (frameCount%1==0){
    try{  
      row = table.getRow(frameCount);
      rawX = row.getFloat(" rawX (accel)");
      rawY = row.getFloat(" rawY");
      rawZ = row.getFloat(" rawZ");
      yaw = row.getFloat("yaw");
      pitch = row.getFloat(" pitch");
      roll = row.getFloat(" roll");
      alt = row.getFloat(" altitude");
      pressure = row.getFloat(" pressure");
      temp = row.getFloat(" temperature");
      knots = row.getFloat(" knots");
      lat = row.getFloat("LatReal");
      lon = row.getFloat("LonReal");
    } catch (ArrayIndexOutOfBoundsException exception) {
      //catchStatements
    } 
  }

  // Draw board
  pushMatrix();
  translate(4*width/5, height/2, -350);
  drawBoard();
  popMatrix();
  
  textFont(font, 20);
  fill(255);
  textAlign(LEFT);

  
  // Output info text
  //text("Point FTDI connector towards screen and press 'a' to align", 10, 25);

  // Output angles
  pushMatrix();
  translate(10, height - 10);
  textAlign(LEFT);
  text("Yaw: " + ((int) yaw), width-140, 300-height+(50*2));
  text("Pitch: " + ((int) pitch), width-140, 300-height+(50*1));
  text("Roll: " + ((int) roll), width-140, 300-height+(50*0));
  text("X: " + String.format("%1.2f",rawX/200), width-(150*3.2), 190-height); 
  text("Y: " + String.format("%1.2f",rawY/200), width-(150*4.3), 100-height);
  text("Z: " + String.format("%1.2f",rawZ/200), width-(150*3.45), 80-height);
  text("Raw acceleration (in g's)", width-(150*4),40-height);
  text("Altitude: " + String.format("%3.2f", alt) + " ft", width-275, 100-height+(50*2));
  text("Pressure: " + String.format("%3.2f", pressure) + " psi", width-275, 100-height+(50*1));
  text("Temp: " + String.format("%3.2f", temp) + " F", width-275, 100-height+(50*0));
  popMatrix();

  stroke(255, 0, 0);
  arrowLine(760, 160-rawZ/2, 760, 160, radians(30), 0, false);
  arrowLine(760-rawX/2, 160, 760, 160,radians(30), 0, false);
  arrowLine(760-(.25*rawY*sqrt(2)), 160-(.25*rawY*sqrt(2)), 760, 160, radians(30), 0, false);
  noStroke(); 
  
  translate(-600,300,-500);
  fill(100, 200, 0);
  ellipse(posCleve.x, posCleve.y, 20, 20);
  fill(0,100,0);
  text(String.format("%2.2f",knots*1.1507) + " mph", posCleve.x+15, posCleve.y-10);
  text(String.format("%2.2f",alt) + " ft", posCleve.x+15, posCleve.y+20);
  fill(255);
  translate(600,-300,500);
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


void arrowLine(float x0, float y0, float x1, float y1,
  float startAngle, float endAngle, boolean solid)
{
  line(x0, y0, x1, y1);
  if (startAngle != 0)
  {
    arrowhead(x0, y0, atan2(y1 - y0, x1 - x0), startAngle, solid);
  }
  if (endAngle != 0)
  {
    arrowhead(x1, y1, atan2(y0 - y1, x0 - x1), endAngle, solid);
  }
}
 
/*
 * Draws an arrow head at given location
 * x0 - arrow vertex x-coordinate
 * y0 - arrow vertex y-coordinate
 * lineAngle - angle of line leading to vertex (radians)
 * arrowAngle - angle between arrow and line (radians)
 * solid - true for a solid arrow, false for an "open" arrow
 */
void arrowhead(float x0, float y0, float lineAngle,
  float arrowAngle, boolean solid)
{
  float phi;
  float x2;
  float y2;
  float x3;
  float y3;
  final float SIZE = 8;
   
  x2 = x0 + SIZE * cos(lineAngle + arrowAngle);
  y2 = y0 + SIZE * sin(lineAngle + arrowAngle);
  x3 = x0 + SIZE * cos(lineAngle - arrowAngle);
  y3 = y0 + SIZE * sin(lineAngle - arrowAngle);
  if (solid)
  {
    triangle(x0, y0, x2, y2, x3, y3);
  }
  else
  {
    line(x0, y0, x2, y2);
    line(x0, y0, x3, y3);
  } 
}

