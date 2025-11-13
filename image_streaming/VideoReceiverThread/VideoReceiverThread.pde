// Daniel Shiffman
// <http://www.shiffman.net>

// A Thread using receiving UDP to receive images

import javax.swing.*;

PImage video;
ReceiverThread thread;
String bindAddress = "0.0.0.0";
int listenPort = 9100;

void setup() {
  size(400,300);
  video = createImage(320,240,RGB);
  thread = new ReceiverThread(video.width,video.height, bindAddress, listenPort);
  thread.start();
}

 void draw() {
  if (thread != null && thread.available()) {
    video = thread.getImage();
  }

  // Draw the image
  background(0);
  imageMode(CENTER);
  image(video,width/2,height/2);
  drawOverlay();
}

void keyPressed() {
  if (key == 'p' || key == 'P') {
    promptForPort();
  } else if (key == 'i' || key == 'I') {
    promptForBind();
  }
}

void promptForPort() {
  String response = JOptionPane.showInputDialog(frame, "Listen port", str(listenPort));
  if (response != null) {
    try {
      int parsed = Integer.parseInt(response.trim());
      if (parsed > 0 && parsed <= 65535) {
        listenPort = parsed;
        if (thread != null) {
          thread.updateEndpoint(bindAddress, listenPort);
        }
      }
    } catch (NumberFormatException ex) {
      System.err.println("Invalid port: " + response);
    }
  }
}

void promptForBind() {
  String response = JOptionPane.showInputDialog(frame, "Bind address (0.0.0.0 for all)", bindAddress);
  if (response != null && response.trim().length() > 0) {
    bindAddress = response.trim();
    if (thread != null) {
      thread.updateEndpoint(bindAddress, listenPort);
    }
  }
}

void drawOverlay() {
  pushStyle();
  fill(0, 180);
  noStroke();
  rect(0, height - 60, width, 60);
  fill(255);
  textAlign(LEFT, TOP);
  text("Threaded rx on " + bindAddress + ":" + listenPort, 10, height - 55);
  text("Press [I] to bind, [P] to pick a port", 10, height - 35);
  text("Thread drops zombie frames instead of freezing", 10, height - 15);
  popStyle();
}

void dispose() {
  if (thread != null) {
    thread.quit();
    thread = null;
  }
}
