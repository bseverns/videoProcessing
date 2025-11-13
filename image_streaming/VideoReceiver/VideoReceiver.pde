import java.net.*;
import java.io.*;
import java.awt.image.*;
import javax.imageio.*;
import javax.swing.*;

// Bind configuration (editable at runtime)
String bindAddress = "0.0.0.0";
int port = 9100;

DatagramSocket ds;
final int MAX_PACKET_SIZE = 60000;
byte[] buffer = new byte[MAX_PACKET_SIZE];
FrameAssembler assembler = new FrameAssembler();

PImage video;

// Telemetry
int framesCompleted = 0;
int framesDropped = 0;
int lastFrameId = -1;
int buildingFrameId = -1;
int currentExpectedChunks = 0;
int currentReceivedChunks = 0;
int lastCompletedChunks = 0;
float lastAssemblyMs = 0;
long lastFrameTimestampMs = 0;
String lastDropReason = "";

void setup() {
  size(400,300);
  openSocket();
  video = createImage(320,240,RGB);
}

void draw() {
  checkForImage();

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
    promptForBindAddress();
  }
}

void promptForPort() {
  String response = JOptionPane.showInputDialog(frame, "Listen port", str(port));
  if (response != null) {
    try {
      int parsed = Integer.parseInt(response.trim());
      if (parsed > 0 && parsed <= 65535) {
        port = parsed;
        openSocket();
      }
    } catch (NumberFormatException ex) {
      System.err.println("Invalid port: " + response);
    }
  }
}

void promptForBindAddress() {
  String response = JOptionPane.showInputDialog(frame, "Bind address (0.0.0.0 for all)", bindAddress);
  if (response != null && response.trim().length() > 0) {
    bindAddress = response.trim();
    openSocket();
  }
}

void openSocket() {
  if (ds != null) {
    ds.close();
    ds = null;
  }
  try {
    if (bindAddress.equals("0.0.0.0")) {
      ds = new DatagramSocket(port);
    } else {
      ds = new DatagramSocket(new InetSocketAddress(bindAddress, port));
    }
    ds.setSoTimeout(50);
    System.out.println("Listening on " + bindAddress + ":" + port);
  } catch (SocketException e) {
    System.err.println("Failed to bind to " + bindAddress + ":" + port);
    e.printStackTrace();
  }
}

void checkForImage() {
  if (ds == null) {
    return;
  }

  DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
  boolean updated = false;

  while (true) {
    try {
      ds.receive(packet);
      boolean complete = assembler.consume(packet.getData(), packet.getLength());
      currentExpectedChunks = assembler.getExpectedChunkCount();
      currentReceivedChunks = assembler.getReceivedChunkCount();
      buildingFrameId = assembler.getCurrentFrameId();

      if (complete) {
        byte[] frameBytes = assembler.buildFrame();
        if (frameBytes != null && applyFrame(frameBytes)) {
          updated = true;
          framesCompleted++;
          lastFrameId = assembler.getLastCompletedFrameId();
          lastCompletedChunks = assembler.getLastCompletedChunkCount();
          lastAssemblyMs = assembler.getLastAssemblyDurationMs();
          lastFrameTimestampMs = System.currentTimeMillis();
          buildingFrameId = -1;
          currentExpectedChunks = 0;
          currentReceivedChunks = 0;
          lastDropReason = "";
        }
      }
    } catch (SocketTimeoutException timeout) {
      break;
    } catch (IOException e) {
      e.printStackTrace();
      break;
    } finally {
      packet.setLength(buffer.length);
    }
  }

  if (!updated && assembler.hasExpired(250)) {
    int abandonedFrame = assembler.getCurrentFrameId();
    String reason = "Timed out waiting for frame";
    if (abandonedFrame != -1) {
      reason += " " + abandonedFrame;
    }
    noteFrameDrop(reason);
    assembler.reset();
    buildingFrameId = -1;
    currentExpectedChunks = 0;
    currentReceivedChunks = 0;
  }
}

boolean applyFrame(byte[] frameBytes) {
  ByteArrayInputStream bais = new ByteArrayInputStream(frameBytes);
  try {
    BufferedImage img = ImageIO.read(bais);
    if (img == null) {
      return false;
    }
    video.loadPixels();
    img.getRGB(0, 0, video.width, video.height, video.pixels, 0, video.width);
    video.updatePixels();
    return true;
  } catch (Exception e) {
    e.printStackTrace();
  }
  return false;
}

void drawOverlay() {
  pushStyle();
  fill(0, 200);
  noStroke();
  rect(0, height - 100, width, 100);
  fill(255);
  textAlign(LEFT, TOP);
  float dropPct = (framesCompleted + framesDropped) == 0 ? 0 : (100.0 * framesDropped) / (framesCompleted + framesDropped);
  int idleMs = lastFrameTimestampMs == 0 ? (int)millis() : (int)(System.currentTimeMillis() - lastFrameTimestampMs);
  String progressLine = (buildingFrameId != -1 && currentExpectedChunks > 0)
    ? "Building frame " + buildingFrameId + ": " + currentReceivedChunks + "/" + currentExpectedChunks + " chunks"
    : "Idle (" + idleMs + " ms since last frame)";
  String lastFrameLine = (framesCompleted > 0)
    ? "Last frame " + lastFrameId + " took " + nf(lastAssemblyMs, 0, 1) + " ms across " + lastCompletedChunks + " chunks"
    : "Waiting for first complete frame";
  text("Listening on " + bindAddress + ":" + port, 10, height - 95);
  text("Frames ok " + framesCompleted + " | dropped " + framesDropped + " (" + nf(dropPct, 0, 1) + "%)", 10, height - 75);
  text(lastFrameLine, 10, height - 55);
  text(progressLine, 10, height - 35);
  String hint = "Press [I] to bind, [P] to set port";
  if (lastDropReason != null && lastDropReason.length() > 0) {
    hint += " | Last drop: " + lastDropReason;
  }
  text(hint, 10, height - 15);
  popStyle();
}

void dispose() {
  if (ds != null) {
    ds.close();
    ds = null;
  }
}

void noteFrameDrop(String reason) {
  framesDropped++;
  lastDropReason = reason;
}
