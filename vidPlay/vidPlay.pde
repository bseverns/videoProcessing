//control video based on a cv-udp

import processing.video.*;
import oscP5.*;
import netP5.*;

//video
Movie mov;
float newSpeed = 0;
float motionAmount = 0;

//OSC
OscP5 oscP5;
NetAddress myRemoteLocation;
//ports
int myListeningPort = 12000;
int myBroadcastPort = 32000;
String cameraIP = "127.0.0.1";//this computer

void setup() {
  size(720, 480);
  background(0);
  mov = new Movie(this, "ROBOTECH_REMASTERED_VOL_1_? copy.m4v");
  mov.loop();

  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 32000);
}

void movieEvent(Movie movie) {
  mov.read();
}

void draw() {
  mov.speed(newSpeed);
  image(mov, 0, 0);

  fill(0, 180);
  noStroke();
  rect(0, height - 40, width, 40);
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("motion: " + nf(motionAmount, 1, 3) + " speed: " + nf(newSpeed, 1, 3), 12, height - 20);
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/motion") == true && theOscMessage.arguments().length > 0) {
    motionAmount = theOscMessage.get(0).floatValue();
    motionAmount = constrain(motionAmount, 0.0, 1.0);
    // Ease the normalized motion value to favor slow changes before mapping to playback speed.
    float eased = pow(motionAmount, 1.5);
    newSpeed = lerp(-0.5, 2.0, eased);
    println("motion " + nf(motionAmount, 1, 3) + " -> speed " + nf(newSpeed, 1, 3));
  }
}
