import processing.video.*;

import java.net.*;
import java.io.*;
import javax.imageio.*;
import java.awt.image.*;
import javax.swing.*;
import java.nio.*;

// Network configuration (editable at runtime)
String targetHost = "127.0.0.1";
int clientPort = 9100;
InetAddress targetAddress;

// Frame chunking configuration
final int HEADER_SIZE = 14;
final int MAX_PACKET_SIZE = 60000;
final int MAX_PAYLOAD = MAX_PACKET_SIZE - HEADER_SIZE;
int frameIdCounter = 0;

// This is our object that sends UDP out
DatagramSocket ds;
// Capture object
Capture cam;

void setup() {
  size(320,240);
  // Setting up the DatagramSocket, requires try/catch
  try {
    ds = new DatagramSocket();
  } catch (SocketException e) {
    e.printStackTrace();
  }
  // Initialize Camera
  cam = new Capture( this, width,height,30);
  cam.start();
  setTargetHost(targetHost);
}

void captureEvent( Capture c ) {
  c.read();
  // Whenever we get a new image, send it!
  broadcast(c);
}

void draw() {
  image(cam,0,0);
  drawOverlay();
}

void keyPressed() {
  if (key == 'i' || key == 'I') {
    promptForHost();
  } else if (key == 'p' || key == 'P') {
    promptForPort();
  }
}

void promptForHost() {
  String newHost = JOptionPane.showInputDialog(frame, "Target host/IP", targetHost);
  if (newHost != null && newHost.trim().length() > 0) {
    setTargetHost(newHost.trim());
  }
}

void promptForPort() {
  String response = JOptionPane.showInputDialog(frame, "Target port", str(clientPort));
  if (response != null) {
    try {
      int parsed = Integer.parseInt(response.trim());
      if (parsed > 0 && parsed <= 65535) {
        clientPort = parsed;
        System.out.println("Streaming to " + targetHost + ":" + clientPort);
      }
    } catch (NumberFormatException ex) {
      System.err.println("Invalid port: " + response);
    }
  }
}

void setTargetHost(String host) {
  try {
    targetAddress = InetAddress.getByName(host);
    targetHost = host;
    System.out.println("Streaming to " + targetHost + ":" + clientPort);
  } catch (UnknownHostException e) {
    System.err.println("Could not resolve host: " + host);
  }
}

void drawOverlay() {
  pushStyle();
  fill(0, 180);
  noStroke();
  rect(0, height - 60, width, 60);
  fill(255);
  textAlign(LEFT, TOP);
  text("Streaming to " + targetHost + ":" + clientPort, 10, height - 55);
  text("Press [I] to set host, [P] to set port", 10, height - 35);
  text("UDP chunks w/ frame headers keep things sane across machines", 10, height - 15);
  popStyle();
}

// Function to broadcast a PImage over UDP with chunking
void broadcast(PImage img) {

  // We need a buffered image to do the JPG encoding
  BufferedImage bimg = new BufferedImage( img.width,img.height, BufferedImage.TYPE_INT_RGB );

  // Transfer pixels from localFrame to the BufferedImage
  img.loadPixels();
  bimg.setRGB( 0, 0, img.width, img.height, img.pixels, 0, img.width);

  // Need these output streams to get image as bytes for UDP communication
  ByteArrayOutputStream baStream        = new ByteArrayOutputStream();
  BufferedOutputStream bos              = new BufferedOutputStream(baStream);

  // Turn the BufferedImage into a JPG and put it in the BufferedOutputStream
  // Requires try/catch
  try {
    ImageIO.write(bimg, "jpg", bos);
    bos.flush();
  }
  catch (IOException e) {
    e.printStackTrace();
  }

  // Get the byte array, which we will send out via UDP!
  byte[] frameBytes = baStream.toByteArray();
  int totalLength = frameBytes.length;
  int frameId = frameIdCounter++;
  int chunkCount = max(1, (int) ceil((float) totalLength / (float) MAX_PAYLOAD));

  if (targetAddress == null) {
    System.err.println("Target address not configured; skipping frame.");
    return;
  }

  println("Sending frame " + frameId + " as " + chunkCount + " chunk(s) -> " + totalLength + " bytes");

  for (int chunkIndex = 0; chunkIndex < chunkCount; chunkIndex++) {
    int offset = chunkIndex * MAX_PAYLOAD;
    int remaining = totalLength - offset;
    int payloadLength = min(remaining, MAX_PAYLOAD);

    ByteBuffer buffer = ByteBuffer.allocate(HEADER_SIZE + payloadLength);
    buffer.order(ByteOrder.BIG_ENDIAN);
    buffer.putInt(frameId);
    buffer.putInt(totalLength);
    buffer.putShort((short) chunkIndex);
    buffer.putShort((short) chunkCount);
    buffer.putShort((short) payloadLength);
    buffer.put(frameBytes, offset, payloadLength);

    byte[] packet = buffer.array();

    try {
      DatagramPacket datagram = new DatagramPacket(packet, packet.length, targetAddress, clientPort);
      ds.send(datagram);
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}
