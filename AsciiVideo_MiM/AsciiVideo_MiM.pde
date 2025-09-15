/**
 * ASCII Video
 * by Ben Fry. 
 *
 * 
 * Text characters have been used to represent images since the earliest computers.
 * This sketch is a simple homage that re-interprets live video as ASCII text.
 * See the keyPressed function for more options, like changing the font size.
 */

import processing.video.*;


//reset the timer on/off
boolean reset = false;

//timer things
int actualSecs; //actual seconds elapsed since start
int actualMins; //actual minutes elapsed since start
int startSec = 0; //used to reset seconds shown on screen to 0
int startMin = 0; //used to reset minutes shown on screen to 0
int cSecs; //seconds will be 0-60
int cMins=0; //minutes will be reset at 5
int restartSecs=0; //number of seconds elapsed at last click or 60 sec interval
int restartMins=0; //number of seconds ellapsed at most recent minute or click

Capture video;
boolean cheatScreen;

// All ASCII characters, sorted according to their visual density
String letterOrder =
" .`-_':,;^=+/\"|)\\<>)$$%x*#$${*}I?!***{}[]7zjLu" +
"nT#JCwfy325Fp6mqSghVd4EgXPGZbYkOA&8U$@&*#!^4=\0Q";
char[] letters;

float[] bright;
char[] chars;

PFont font;
float fontSize = 1.5;


void setup() {
  size(640, 480);

  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, 160, 120);

  // Start capturing the images from the camera
  video.start();  

  int count = video.width * video.height;
  //println(count);

  font = loadFont("Moospaced-48.vlw");

  // for the 256 levels of brightness, distribute the letters across
  // the an array of 256 elements to use for the lookup
  letters = new char[256];
  for (int i = 0; i < 256; i++) {
    int index = int(map(i, 0, 256, 0, letterOrder.length()));
    letters[i] = letterOrder.charAt(index);
  }

  // current characters for each position in the video
  chars = new char[count];

  // current brightness for each point
  bright = new float[count];
  for (int i = 0; i < count; i++) {
    // set each brightness at the midpoint to start
    bright[i] = 128;
  }
}


void captureEvent(Capture c) {
  c.read();
}


void draw() {
  //start timer
  actualSecs = millis()/1000; //convert milliseconds to seconds, store values.
  actualMins = millis() /1000 / 60; //convert milliseconds to minutes, store values.
  cSecs = actualSecs - restartSecs; //seconds to be tracked in the artificial stopwatch
  cMins = actualMins - restartMins; //minutes to be tracked in the artificial stopwatch

  background(0);

  pushMatrix();

  float hgap = width / float(video.width);
  float vgap = height / float(video.height);

  scale(max(hgap, vgap) * fontSize);
  textFont(font, fontSize);

  int index = 0;
  video.loadPixels();
  for (int y = 1; y < video.height; y++) {

    // Move down for next line
    translate(0, 1.0 / fontSize);

    pushMatrix();
    for (int x = 0; x < video.width; x++) {
      int pixelColor = video.pixels[index];
      // Faster method of calculating r, g, b than red(), green(), blue() 
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;

      // Another option would be to properly calculate brightness as luminance:
      // luminance = 0.3*red + 0.59*green + 0.11*blue
      // Or you could instead red + green + blue, and make the the values[] array
      // 256*3 elements long instead of just 256.
      int pixelBright = max(r, g, b);

      // The 0.1 value is used to damp the changes so that letters flicker less
      float diff = pixelBright - bright[index];
      bright[index] += diff * 0.1;

      fill(pixelColor);
      int num = int(bright[index]);
      text(letters[num], 0, 0);

      // Move to the next pixel
      index++;

      // Move over for next character
      translate(1.0 / fontSize, 0);
    }
    popMatrix();
  }
  popMatrix();

  if (cheatScreen) {
    //image(video, 0, height - video.height);
    // set() is faster than image() when drawing untransformed images
    set(0, height - video.height, video);
  }

  if (actualSecs % 60 == 0) {
    restartSecs = actualSecs;
  }
  if ((cMins == 1)) { 
    saveFrame("########.jpg");
    reset = true;
  }
  if (reset = true) {
    restartSecs = actualSecs;
    cSecs = startSec;
    restartMins = actualMins;
    cMins = restartMins;
    reset = false;
  }
}


/**
 * Handle key presses:
 * 'c' toggles the cheat screen that shows the original image in the corner
 * 'g' grabs an image and saves the frame to a tiff image
 * 'f' and 'F' increase and decrease the font size
 */
void keyPressed() {
  switch (key) {
  case 'g': 
    saveFrame(); 
    break;
  case 'c': 
    cheatScreen = !cheatScreen; 
    break;
  case 'f': 
    fontSize *= 1.1; 
    break;
  case 'F': 
    fontSize *= 0.9; 
    break;
  }
}
