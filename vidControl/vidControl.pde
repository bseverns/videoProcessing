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

//OSC
OscP5 oscP5;
NetAddress myRemoteLocation;
//ports
int myListeningPort = 32000;
int myBroadcastPort = 12000;
String displayIP = "127.0.0.1";//this computer

float playStatus = 0.0;

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
  playStatus = 0.0;

  frameRate(4);
}

void draw() {
  if (video.available()) {

    video.read(); // Read a new video frame
    video.loadPixels(); // Make the pixels of video available
    println("one");
    image(video, 0, 0, 720, 480);//display the video for proper set up

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
   
    //////////////////////HERE/////////////////////////
    playStatus = map(presenceSum, 0, 99999999, 0, 20);
    println(playStatus);
    /*figure out the mapped value ranges for things*/

    if (playStatus <= 10.5) {
      OscMessage myMessage = new OscMessage("none");
      myMessage.add(1);
      //add display iP to oscp5.send msg
      oscP5.send(myMessage, myRemoteLocation);
      println("not much");
    } else if (playStatus <= 12.5) {
      OscMessage myMessage = new OscMessage("tiny");
      myMessage.add(2);
      oscP5.send(myMessage, myRemoteLocation);
      println("a bit");
    } else if (playStatus <= 13.5) {
      OscMessage myMessage = new OscMessage("some");
      myMessage.add(3);
      oscP5.send(myMessage, myRemoteLocation);
      println("decent");
    } else if (playStatus <= 14.5) {
      OscMessage myMessage = new OscMessage("lots");
      myMessage.add(4);
      oscP5.send(myMessage, myRemoteLocation);
      println("party");
    } else {
      println("errorrrorroroororrrorr");
    }
  }
}

void oscEvent(OscMessage theOscMessage) {
  /*print the address pattern and the typetag of the received OscMessage */
  print("### received and osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
