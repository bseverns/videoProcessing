 //<>//
//libraries
import processing.video.*;
import oscP5.*;
import netP5.*;

//camera
Capture video;
int numPixels;
int[] backgroundPixels;
float presenceSum = 0.0;
float normalizedMotion = 0.0;
boolean backgroundReady = false;
boolean liveBackground = true;

//OSC
OscP5 oscP5;
NetAddress myRemoteLocation;
//ports
int myListeningPort = 32000;
int myBroadcastPort = 12000;
String displayIP = "127.0.0.1";//this computer

void setup() {
  size(720, 480);

  //video analysis stuff
  video = new Capture(this, 720, 480);
  println("video");
  numPixels = video.width * video.height;
  // Create array to store the background image
  backgroundPixels = new int[numPixels];
  // Make the pixels[] array available for direct manipulation
  video.start();
  video.loadPixels();


  //oscP5
  oscP5 = new OscP5(this, 32000);
  println("osc");
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  frameRate(4);
}

void draw() {
  if (video.available()) {

    video.read(); // Read a new video frame
    video.loadPixels(); // Make the pixels of video available
    println("one");
    image(video, 0, 0, 720, 480);//display the video for proper set up

    if (!backgroundReady) {
      arrayCopy(video.pixels, backgroundPixels);
      backgroundReady = true;
    }

    presenceSum = 0.0;

    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      // Fetch the current color in that location, and also the color
      // of the background in that spot
      color currColor = video.pixels[i];
      color bkgdColor = backgroundPixels[i];
      // Extract the red, green, and blue components of the current pixelÕs color
      int currR = (currColor >> 16) & 0xFF;
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract the red, green, and blue components of the background pixelÕs color
      int bkgdR = (bkgdColor >> 16) & 0xFF;
      int bkgdG = (bkgdColor >> 8) & 0xFF;
      int bkgdB = bkgdColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - bkgdR);
      int diffG = abs(currG - bkgdG);
      int diffB = abs(currB - bkgdB);

      presenceSum += (diffR + diffG + diffB);
    }

    // Normalize the total per-channel difference so downstream sketches can treat it as 0..1 motion energy.
    float maxPresence = max(1.0, numPixels * 255.0);
    normalizedMotion = presenceSum / maxPresence;
    normalizedMotion = constrain(normalizedMotion, 0.0, 1.0);

    OscMessage myMessage = new OscMessage("/motion");
    myMessage.add(normalizedMotion);
    oscP5.send(myMessage, myRemoteLocation);
    println("motion " + nf(normalizedMotion, 1, 4));

    if (liveBackground) {
      arrayCopy(video.pixels, backgroundPixels);
    }

    drawHud();
  }
}

void oscEvent(OscMessage theOscMessage) {
  /*print the address pattern and the typetag of the received OscMessage */
  print("### received and osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}

void keyPressed() {
  if (key == 'b' || key == 'B') {
    liveBackground = !liveBackground;
    if (!liveBackground) {
      if (video != null && video.pixels != null && video.pixels.length == numPixels) {
        arrayCopy(video.pixels, backgroundPixels);
        backgroundReady = true;
      }
    }
  }
}

void drawHud() {
  pushStyle();
  fill(0, 150);
  noStroke();
  rect(12, 12, 420, 120, 12);

  fill(255);
  textAlign(LEFT, TOP);
  textSize(14);
  String mode = liveBackground ? "LIVE" : "STATIC";
  String motionLabel = "motion:" + nf(normalizedMotion, 1, 4);
  text("/motion => " + motionLabel, 24, 24);
  text("Background mode: " + mode, 24, 48);
  text("Press 'b' to toggle live/static background", 24, 72);
  if (!liveBackground) {
    text("Press again after reframing to lock a new still", 24, 96);
  }
  popStyle();
}
