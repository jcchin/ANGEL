import processing.opengl.*;
import processing.serial.*;
import processing.video.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.Google;
import controlP5.*;

ControlP5 cp5;
CheckBox checkbox;

UnfoldingMap map;
Location locationCleve = new Location(41f, -81f);
Location locationFremont = new Location(41f, -83f); //starting location
Location locationCurr = locationFremont; //current loc

float yaw = 0.0f;
float pitch = 0.0f;
float roll = 0.0f;
float yawOffset = 0.0f;
float theta;
int[] numbers = new int[600];

PFont font;

Movie myMovie;
Table table;
TableRow row;
int fps = 30;

float rawX, rawY, rawZ;
float alt, pressure, temp;
float sats, knots, fix;
float lat=-81.88;
float lon= 41.4;
int frameJump; //current frame
int numRows; //number of csv rows

void setup() {
  size(1260, 800, OPENGL);
  background(0);
  smooth();
  noStroke();
  frameRate(30);
  cp5 = new ControlP5(this);
  
  myMovie = new Movie(this, "../data/Flight1Combo854_480p.mp4"); //Combo854_480p
  myMovie.speed(2);
  myMovie.loop();
  table = loadTable("../data/cleanedData/GPScombined.csv", "header");
  numRows = table.getRowCount();
  println(numRows + " total rows in table"); 
  
  // Load font
  font = loadFont("Univers-66.vlw");
  textFont(font);
  
  map = new UnfoldingMap(this, new Google.GoogleMapProvider());
  map.setTweening(true);
  //map.zoomAndPanTo(new Location(41.40015f, -81.8756f), 16);
  //map.zoomAndPanTo(new Location(41.40015f, -81.8756f), 12);
  map.zoomAndPanTo(new Location(41.459f, -83.2f), 15);
  //map.panTo(8000,-5000);//hack, hardcoded to mastick
  map.panTo(4300,5700); //+ right, + down, hardcoded to Fremont Airport
  MapUtils.createDefaultEventDispatcher(this, map);

  //jump ahead buttons
  cp5.addButton("Launch")
     //.setValue(0)
     .setPosition(675,485)
     .setSize(25,25)
     ;   
  cp5.addButton("Burst")
     //.setValue(0)
     .setPosition(1000,485)
     .setSize(25,25)
     ;
  cp5.addButton("Descent")
     //.setValue(0)
     .setPosition(1150,485)
     .setSize(25,25)
     ;
  cp5.addButton("Landing")
     //.setValue(0)
     .setPosition(1200,485)
     .setSize(25,25)
     ;
  //playblack slider
  cp5.addSlider("slider")
     .setPosition(675,520)
     .setSize(550,20)
     .setRange(0,numRows)
     .setValue(0)
     ;
  checkbox = cp5.addCheckBox("checkBox") //pause button
                .setPosition(650, 555)
                .setColorForeground(color(120))
                .setColorActive(color(255))
                .setColorLabel(color(255))
                .setSize(20, 20)
                .addItem("pause", 0)
                ;
  
  // reposition the Label for controller 'slider'
  cp5.getController("slider").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("slider").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  frameJump = 0;
  
}

void draw() {
  
   // Reset scene
  background(0);
  translate(-600,300,-500);
  map.draw();
  // Draws locations on screen positions according to their geo-locations.
  // Fixed-size marker
  locationCurr = new Location(lon, lat);
  ScreenPosition posCleve = map.getScreenPosition(locationCurr);
  translate(600,-300,500);
  lights();
  image(myMovie, 0, 0, 854, 480);
  /*
  if (millis() > 2000){ // wait before starting video
    myMovie.loop();
  }
  */
  frameJump++;
  //cameraPan(frameJump);
  if (frameJump%4==0){
    try{  
      row = table.getRow(frameJump);
      cp5.controller("slider").setValue(frameJump);
      rawX = row.getFloat(" rawX (accel)");
      rawY = row.getFloat(" rawY");
      rawZ = row.getFloat(" rawZ");
      yaw = row.getFloat("yaw");
      pitch = row.getFloat(" pitch");
      roll = row.getFloat(" roll");
      alt = row.getFloat(" altitude");
      //pressure = row.getFloat(" pressure");
      temp = row.getFloat(" tmp36");
      knots = row.getFloat(" knots");
      lat = row.getFloat("LatReal");
      lon = row.getFloat("LonReal");
      sats = row.getFloat(" # of satellite fixes");
      fix = row.getFloat("GPS Fix");
    } catch (ArrayIndexOutOfBoundsException exception) {
      //catchStatements
    } 
  }

  // Draw board
  pushMatrix();
  translate(width, 3*height/7, -550);
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
  fill(90,90,255);
  text("Yaw: " + ((int) yaw), width-140, 300-height+(50*2));
  text("Pitch: " + ((int) pitch), width-140, 300-height+(50*1));
  text("Roll: " + ((int) roll), width-140, 300-height+(50*0));
  fill(255,0,0);
  text("X: " + String.format("%1.2f",rawX/230), width-(150*2), 180-height); 
  text("Y: " + String.format("%1.2f",rawY/230), width-(150*2.8), 130-height);
  text("Z: " + String.format("%1.2f",rawZ/230 -1), width-(150*2.4), 80-height);
  text("Raw accel (in g's)", width-(150*2.9),40-height);
  fill(255);
  text("Altitude: " + String.format("%3.2f", alt*3.28084) + " ft", width-225, 100-height+(40*1));
  text("Speed: " + String.format("%3.2f", knots * 1.15078) + " mph", width - 225, 100- height+(40*0));
  //text("Pressure: " + String.format("%3.2f", pressure) + " psi", width-250, 100-height+(50*1));
  text("Temp: " + String.format("%3.2f", temp-24) + " F", width-225, 100-height+(40*-1));
  text("GPS: " + String.format("%2.0f", sats) + " sats locked", width-225, 100-height+(40*2));
  popMatrix();
  
  fill(10,150,20);
  rect(675,513,550,5); //green zones
  fill(200,10,10);
  rect(675 + (550*.286),513,(550*.251),5); //red zones
  rect(675 + (550*.76995),513,(550*.1056),5);
  if(fix > 0){
    stroke(90,90,255);
    line(950,155,950,100); //z axis
    line(950,155, 1005, 155); // x axis
    line(950,155,950-25,155-25); // y axis
    stroke(255, 0, 0);
    arrowLine(950, 155-(rawZ-230), 950, 155, radians(30), 0, false);
    arrowLine(950-rawX/4, 155, 950, 155,radians(30), 0, false);
    arrowLine(950-(.125*rawY*sqrt(2)), 155-(.25*rawY*sqrt(2)), 950, 155, radians(30), 0, false);
  
  }else if(alt < 10){ //block out invalid data
    fill(0);
    rect(800,0,1000,500);
    fill(255); 
    text("No Data :(", width - 300, 300);
  }
  fill(255,0,0);
  noStroke();
  
  translate(-600,300,-500);
  if(fix > 0){
    fill(100, 200, 0);
    ellipse(posCleve.x, posCleve.y, 20, 20);
    fill(0,100,0);
    text(String.format("%2.2f",knots*1.1507) + " mph", posCleve.x+15, posCleve.y-10);
    text(String.format("%2.2f",alt*3.28084) + " ft", posCleve.x+15, posCleve.y+20);
  }else{
    fill(250, 0, 0);
    ellipse(posCleve.x, posCleve.y, 20, 20);
    text("??", posCleve.x+15, posCleve.y-10);
  }
  fill(255);
  translate(600,-300,500);
  
  movingGraph();
  
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
  fill(255, 0 , 0);
  box(150, 100, 200);
  fill(10,10,10);
  box(23,23,201);
  translate(20,40,0);
  fill(255);
  box(10,10,400); //antenna
  translate(-20,-45,0);
  // Forward-arrow
  pushMatrix();
  translate(0, 25, -100);
  scale(0.5f, 0.2f, 0.25f);
  fill(90, 90, 255);
  drawArrow(.75f, 1.f);
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
void slider(float newFrame) {
  //println("a slider event. setting background to "+theColor);
  frameJump = round(newFrame);
  if (cp5.controller("slider").isMouseOver() && cp5.controller("slider").isMousePressed()){
    myMovie.jump(myMovie.duration()*frameJump/numRows);
  }
  
}
void checkBox(float[] a) { //pause button
  if (a[0] == 1.0){
    noLoop();
    myMovie.pause();
  }else{
    loop();
    myMovie.play();
  }
}

void zoomOut(int theValue) {
  map.zoom(-1);
  map.panTo(3000,500);
}

void Launch(){
   frameJump = 1; 
   myMovie.jump(0);
   map.zoomAndPanTo(new Location(41.459f, -83.2f), 15);
   map.panTo(1200,4300); //+ right, + down, hardcoded to Fremont Airport
}

void Burst() {
  frameJump = 42100;
  myMovie.jump(myMovie.duration()*0.669);
  map.zoomAndPanTo(new Location(41.15f, -82.9f), 10);
}

void Descent(){
  frameJump = 58100;
  myMovie.jump(myMovie.duration()*frameJump/numRows);
  map.zoomAndPanTo(new Location(40.8767f, -82.449f), 13);
  
}

void Landing() {
  frameJump = 65500;
  myMovie.jump(myMovie.duration()*0.99);
  map.zoomAndPanTo(new Location(40.85f, -82.41f), 16);
  map.panTo(50,-85); //+ right, + down, hardcoded to landing site
}

void cameraPan(int frameNum) { //pan camera based on location
  if (frameNum < 1000){
    
  } else if (frameNum > 1000 && frameNum < 10000){
    //map.zoomAndPanTo(new Location(41.3352f, -83.1662f), 12);
  } else if (frameNum > 10000 && frameNum < 40000){
    //map.zoomAndPanTo(new Location(41.3352f, -83.1662f), 9);
  } else if (frameNum > 40000 && frameNum < 60000){
    
  } else if (frameNum > 60000){
    
  }
}

void movingGraph(){
  //altitude moving graph
  stroke(255);
  fill(0);
  for(int i = 1; i<numbers.length;i++){
    numbers[i-1] = numbers[i];
  }
  numbers[numbers.length-1]=round((alt/27000)*200);
  
  beginShape();
  for(int i = 0; i<numbers.length;i++){
    vertex(i+650,750-numbers[i]);
  }
  endShape();
  noStroke();
  fill(255);
}
