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
      if (assembler.consume(packet.getData(), packet.getLength())) {
        byte[] frameBytes = assembler.buildFrame();
        if (frameBytes != null && applyFrame(frameBytes)) {
          updated = true;
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
    assembler.reset();
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
  fill(0, 180);
  noStroke();
  rect(0, height - 60, width, 60);
  fill(255);
  textAlign(LEFT, TOP);
  text("Listening on " + bindAddress + ":" + port, 10, height - 55);
  text("Press [I] to set bind address, [P] to set port", 10, height - 35);
  text("Receiver stitches frame chunks together or bails fast", 10, height - 15);
  popStyle();
}

void dispose() {
  if (ds != null) {
    ds.close();
    ds = null;
  }
}
