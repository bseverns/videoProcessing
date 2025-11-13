// Daniel Shiffman
// <http://www.shiffman.net>

// A Thread using receiving UDP to receive images

import javax.swing.*;

PImage video;
ReceiverThread thread;
String bindAddress = "0.0.0.0";
int listenPort = 9100;
ReceiverStats stats = new ReceiverStats();

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
  if (thread != null) {
    stats = thread.snapshot();
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
  fill(0, 200);
  noStroke();
  rect(0, height - 100, width, 100);
  fill(255);
  textAlign(LEFT, TOP);
  float dropPct = (stats.framesCompleted + stats.framesDropped) == 0 ? 0 : (100.0 * stats.framesDropped) / (stats.framesCompleted + stats.framesDropped);
  int idleMs = stats.lastFrameTimestampMs == 0 ? (int)millis() : (int)(System.currentTimeMillis() - stats.lastFrameTimestampMs);
  String progressLine = (stats.buildingFrameId != -1 && stats.currentExpectedChunks > 0)
    ? "Building frame " + stats.buildingFrameId + ": " + stats.currentReceivedChunks + "/" + stats.currentExpectedChunks + " chunks"
    : "Idle (" + idleMs + " ms since last frame)";
  String lastFrameLine = (stats.framesCompleted > 0)
    ? "Last frame " + stats.lastFrameId + " took " + nf(stats.lastAssemblyMs, 0, 1) + " ms across " + stats.lastCompletedChunks + " chunks"
    : "Waiting for first complete frame";
  text("Threaded rx on " + bindAddress + ":" + listenPort, 10, height - 95);
  text("Frames ok " + stats.framesCompleted + " | dropped " + stats.framesDropped + " (" + nf(dropPct, 0, 1) + "%)", 10, height - 75);
  text(lastFrameLine, 10, height - 55);
  text(progressLine, 10, height - 35);
  String hint = "Press [I] to bind, [P] to pick a port";
  if (stats.lastDropReason != null && stats.lastDropReason.length() > 0) {
    hint += " | Last drop: " + stats.lastDropReason;
  }
  text(hint, 10, height - 15);
  popStyle();
}

void dispose() {
  if (thread != null) {
    thread.quit();
    thread = null;
  }
}
