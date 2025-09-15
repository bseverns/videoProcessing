import processing.video.*;
import processing.serial.*;

int movTOTAL = 10; //set this to the total number of .mov files in library 

//Serial myPort;  // Create object from Serial class
//int val;

Movie mov;
String playSelection;

void setup() {
  frameRate(30);
  playSelection = "1.mov";
  size (720, 480);
  mov = new Movie(this, playSelection); //new video
  //  String portName = Serial.list()[0];
  //  myPort = new Serial(this, portName, 9600);
}

void draw() {
  /*
  if ( myPort.available() > 0) {  // If data is available,
   val = myPort.read();         // read it and store it in val
   }
   */
  background(0);
  videoplay();
}

void videoplay() {
  //If (val == 0) {
  mov.read();
  image(mov, 0, 0, width, height);

  if (mov.time() == mov.duration()) {
    videoSelect();
  }
} /*else { //if val is anything but 0
 run();
 }
 */

void videoSelect() {
  playSelection = nf(int(random(0, movTOTAL))) + ".mov";//randomized file selector
  mov = new Movie(this, playSelection); //new video
  mov.play(); //go!
  videoplay(); //update
}
/*
void runt() {
 playSelection = "finalRun.mov";//through the woods
 mov = new Movie(this, playSelection); //new video
 mov.play(); //go!
 videoplay(); //update
 }
 */
