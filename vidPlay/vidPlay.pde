//control video based on a cv-udp

import processing.video.*;
import oscP5.*;
import netP5.*;

//video
Movie mov;
float newSpeed = 0;
float oldSpeed;

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
  oldSpeed = newSpeed;
}

void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("none")==true) {
    println("none");
    int msgVal = 1;
    if (msgVal == 1) {
      newSpeed = -0.5;
    }
  } else if (theOscMessage.checkAddrPattern ("tiny")==true) {
    println("tine");
    int msgVal = 2;
    if (msgVal == 2) {
      newSpeed = 0.25;
    }
  } else if (theOscMessage.checkAddrPattern ("some")==true) {
    println("some");
    int msgVal = 3;
    if (msgVal == 3) {
      newSpeed = 1;
    }
  } else if (theOscMessage.checkAddrPattern ("lots")==true) {
    println("lots");
    int msgVal = 4;
    if (msgVal == 4) {
      newSpeed = 1.85;
    }
  } else {
    println("nothingnew");
    newSpeed = oldSpeed;
  }
}
