import gab.opencv.*;
import processing.video.*;
import java.awt.*;

//movie stuff
Movie mov1;

//camera stuff
Capture video;
OpenCV opencv;
boolean autoLearn = true;
boolean applyDilate = false;
boolean applyErode = false;
boolean drawContours = false;
color maskTint = color(0, 255, 180, 180);
int lastCameraFrameMs = 0;

void setup() {
  size(720, 480);
  mov1 = new Movie(this, "Untitled_1.mov");

  video = new Capture(this, 720, 480);
  opencv = new OpenCV(this, 720, 480);

  opencv.startBackgroundSubtraction(5, 3, 0.5);

  video.start();

  mov1.loop();
  mov1.play();
}

void draw() {
  image(mov1, 0, 0, width, height);

  if (autoLearn) {
    opencv.updateBackground();
  }
  if (applyDilate) {
    opencv.dilate();
  }
  if (applyErode) {
    opencv.erode();
  }

  tint(maskTint);
  image(opencv.getOutput(), 0, 0, width, height);
  noTint();

  if (drawContours) {
    noFill();
    stroke(255, 0, 0);
    strokeWeight(3);
    for (Contour contour : opencv.findContours()) {
      contour.draw();
    }
  }

  drawHud();
}

void movieEvent(Movie m) {
  m.read();
}

void captureEvent(Capture c) {
  c.read();
  opencv.loadImage(c);
  lastCameraFrameMs = millis();
}

void keyPressed() {
  if (key == 'u' || key == 'U') {
    autoLearn = !autoLearn;
  } else if (key == 'd' || key == 'D') {
    applyDilate = !applyDilate;
  } else if (key == 'e' || key == 'E') {
    applyErode = !applyErode;
  } else if (key == 'c' || key == 'C') {
    drawContours = !drawContours;
  } else if (key == 'r' || key == 'R') {
    opencv.resetBackground();
  }
}

void drawHud() {
  pushStyle();
  fill(0, 180);
  noStroke();
  rect(0, height - 90, width, 90);
  fill(255);
  textAlign(LEFT, TOP);
  int idle = lastCameraFrameMs == 0 ? millis() : millis() - lastCameraFrameMs;
  String learnLabel = autoLearn ? "auto" : "hold";
  String dilateLabel = applyDilate ? "on" : "off";
  String erodeLabel = applyErode ? "on" : "off";
  String contourLabel = drawContours ? "on" : "off";
  text("OpenCV mask riding over mov1", 12, height - 85);
  text("[U] background: " + learnLabel + "  [D] dilate: " + dilateLabel + "  [E] erode: " + erodeLabel + "  [C] contours: " + contourLabel, 12, height - 65);
  text("[R] reset background  |  " + idle + " ms since camera frame", 12, height - 45);
  text("Tint = " + hex(maskTint), 12, height - 25);
  popStyle();
}
