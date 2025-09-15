import gab.opencv.*;
import processing.video.*;
import java.awt.*;

//movie stuff
Movie mov1;

//camera stuff
Capture video;
OpenCV opencv;

void setup() {
  size(720, 480);
  mov1 = new Movie(this, "Untitled_1.mov");
  
  video = new Capture(this, 720, 480);
  opencv = new OpenCV(this, 720, 480);
  
  opencv.startBackgroundSubtraction(5, 3, 0.5);
  
  mov1.loop();
  mov1.play();
}

void draw() {
  image(mov1, 0, 0);  
  opencv.loadImage(video);
  
  //opencv.updateBackground();
  
  //opencv.dilate();
  //opencv.erode();

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);
//  for (Contour contour : opencv.findContours()) {
//    contour.draw();
//  }
}

void movieEvent(Movie m) {
  m.read();
}
