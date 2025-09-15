//video playback/background sub capture
//frame dif is mapped to value and used as controls for video playback
//motherfuckers can't stop me now

import processing.video.*;

int numPixels;
int[] backgroundPixels;
int presenceSum;
Capture video;
Movie mov1;

void setup() {
  size(640, 480);

video = new Capture (this, width, height);
  video.start();
  
  mov1 = new Movie(this, "Untitled_1.mov");

  numPixels = video.width * video.height;
  backgroundPixels = new int[numPixels];
  loadPixels();

  mov1.loop();
}

void draw() {
  if (video.available()) {
    video.read(); // Read a new video frame
    video.loadPixels(); // Make the pixels of video available
    // Difference between the current frame and the stored background
    presenceSum = 0;
    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      // Fetch the current color in that location, and also the color
      // of the background in that spot
      color currColor = video.pixels[i];
      color bkgdColor = backgroundPixels[i];
      // Extract the red, green, and blue components of the current pixel's color
      int currR = (currColor >> 16) & 0xFF;
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract the red, green, and blue components of the background pixel's color
      int bkgdR = (bkgdColor >> 16) & 0xFF;
      int bkgdG = (bkgdColor >> 8) & 0xFF;
      int bkgdB = bkgdColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - bkgdR);
      int diffG = abs(currG - bkgdG);
      int diffB = abs(currB - bkgdB);
      // Add these differences to the running tally
      presenceSum += diffR + diffG + diffB;
      // Render the difference image to the screen
      pixels[i] = color(diffR, diffG, diffB);
      // The following line does the same thing much faster, but is more technical
      //pixels[i] = 0xFF000000 | (diffR << 16) | (diffG << 8) | diffB;
      backgroundPixels[i] = currColor;
    }
   if (presenceSum > 0) {
      updatePixels(); // Notify that the pixels[] array has changed
    }
  }

  image(mov1, 0, 0);
  float newSpeed = map(presenceSum, 1000000, 99999999, -0.5, 2.5); 
  mov1.speed(newSpeed);
}

void movieEvent(Movie mov1) {
  mov1.read();
}
