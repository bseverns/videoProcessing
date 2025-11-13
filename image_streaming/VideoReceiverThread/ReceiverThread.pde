// Daniel Shiffman
// <http://www.shiffman.net>

// A Thread using receiving UDP

import java.net.*;
import java.io.*;
import java.awt.image.*;
import javax.imageio.*;
import java.nio.*;

class ReceiverThread extends Thread {

  static final int MAX_PACKET_SIZE = 60000;

  // Port we are receiving.
  int port = 9100;
  String bindAddress = "0.0.0.0";
  DatagramSocket ds;
  // A byte array to read into
  byte[] buffer = new byte[MAX_PACKET_SIZE];

  boolean running;    // Is the thread running?  Yes or no?
  boolean available;  // Is a fresh frame available?

  // Start with something
  PImage img;
  FrameAssembler assembler = new FrameAssembler();

  ReceiverThread (int w, int h, String bind, int listenPort) {
    img = createImage(w,h,RGB);
    running = false;
    available = true; // We start with "loading . . " being available
    bindAddress = bind;
    port = listenPort;
    configureSocket();
  }

  synchronized void configureSocket() {
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
      System.out.println("[Thread] Listening on " + bindAddress + ":" + port);
    } catch (SocketException e) {
      System.err.println("[Thread] Failed to bind to " + bindAddress + ":" + port);
      e.printStackTrace();
    }
  }

  synchronized void updateEndpoint(String bind, int listenPort) {
    bindAddress = bind;
    port = listenPort;
    configureSocket();
  }

  PImage getImage() {
    // We set available equal to false now that we've gotten the data
    available = false;
    return img;
  }

  boolean available() {
    return available;
  }

  // Overriding "start()"
  void start () {
    running = true;
    super.start();
  }

  // We must implement run, this gets triggered by start()
  void run () {
    DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
    while (running) {
      DatagramSocket socket = getSocket();
      if (socket == null) {
        delay(10);
        continue;
      }
      try {
        socket.receive(packet);
        if (assembler.consume(packet.getData(), packet.getLength())) {
          byte[] frameBytes = assembler.buildFrame();
          if (frameBytes != null) {
            applyFrame(frameBytes);
            available = true;
          }
        }
      }
      catch (SocketTimeoutException timeout) {
        if (assembler.hasExpired(250)) {
          assembler.reset();
        }
      }
      catch (SocketException se) {
        if (!running) {
          break;
        }
      }
      catch (IOException e) {
        e.printStackTrace();
      }
      finally {
        packet.setLength(buffer.length);
      }
    }
  }

  synchronized DatagramSocket getSocket() {
    return ds;
  }

  void applyFrame(byte[] frameBytes) {
    ByteArrayInputStream bais = new ByteArrayInputStream(frameBytes);
    try {
      BufferedImage bimg = ImageIO.read(bais);
      if (bimg == null) {
        return;
      }
      img.loadPixels();
      bimg.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
      img.updatePixels();
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }


  // Our method that quits the thread
  void quit() {
    System.out.println("Quitting.");
    running = false;  // Setting running to false ends the loop in run()
    assembler.reset();
    DatagramSocket socket = getSocket();
    if (socket != null) {
      socket.close();
    }
    // In case the thread is waiting. . .
    interrupt();
  }
}
