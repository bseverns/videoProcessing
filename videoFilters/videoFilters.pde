import processing.video.*;

Capture cam;
char activeFilter = ' ';

void setup()
{
  size(640, 480);
  cam = new Capture(this, width, height);
  cam.start();
  smooth();
}

void draw() {
  if (cam.available()) {
    cam.read();
  }

  loadPixels();
  char filter = Character.toLowerCase(activeFilter);

  if (filter == 'v') {
    applyVerticalFlip();
  } else if (filter == 'm') {
    applyHorizontalMirror();
  } else if (filter == 's') {
    applySepia();
  } else if (filter == 'f') {
    applyPosterizeFourColor();
  } else if (filter == 'y') {
    applyHSBThreshold();
  } else {
    copyCurrentFrame();
  }

  updatePixels();
}

void keyPressed() {
  activeFilter = key;
}

void applyVerticalFlip() {
  cam.loadPixels();
  for (int y = 0; y < height; y++) {
    int flippedY = height - 1 - y;
    int destRow = flippedY * width;
    int srcRow = y * cam.width;
    for (int x = 0; x < width; x++) {
      pixels[destRow + x] = cam.pixels[srcRow + x];
    }
  }
}

void applyHorizontalMirror() {
  cam.loadPixels();
  for (int y = 0; y < height; y++) {
    int rowOffset = y * width;
    int srcRow = y * cam.width;
    for (int x = 0; x < width; x++) {
      int mirroredX = width - 1 - x;
      pixels[rowOffset + mirroredX] = cam.pixels[srcRow + x];
    }
  }
}

void applySepia() {
  cam.loadPixels();
  int sepiaAmount = 20;
  for (int y = 0; y < height; y++) {
    int rowOffset = y * width;
    int srcRow = y * cam.width;
    for (int x = 0; x < width; x++) {
      color px = cam.pixels[srcRow + x];
      float r = constrain(red(px) + (2 * sepiaAmount), 0, 255);
      float g = constrain(green(px) + sepiaAmount, 0, 255);
      float b = constrain(blue(px) - sepiaAmount, 0, 255);
      pixels[rowOffset + x] = color(r, g, b);
    }
  }
}

void applyPosterizeFourColor() {
  cam.loadPixels();
  for (int y = 0; y < height; y++) {
    int rowOffset = y * width;
    int srcRow = y * cam.width;
    for (int x = 0; x < width; x++) {
      color px = cam.pixels[srcRow + x];
      float r = red(px);
      float g = green(px);
      float b = blue(px);
      float sum = r + g + b;

      if (-1 < sum && sum < 182) {
        r = 0;
        g = 51;
        b = 76;
      } else if (181 < sum && sum < 364) {
        r = 217;
        g = 26;
        b = 33;
      } else if (363 < sum && sum < 546) {
        r = 112;
        g = 150;
        b = 158;
      } else if (545 < sum && sum < 766) {
        r = 252;
        g = 227;
        b = 166;
      }

      pixels[rowOffset + x] = color(r, g, b);
    }
  }
}

void applyHSBThreshold() {
  cam.loadPixels();
  colorMode(HSB, 255);
  for (int y = 0; y < height; y++) {
    int rowOffset = y * width;
    int srcRow = y * cam.width;
    for (int x = 0; x < width; x++) {
      color px = cam.pixels[srcRow + x];
      float r = red(px);
      float g = green(px);
      float b = blue(px);
      float alpha = 0;
      float chroma = (r + b + g) % 255;
      if (chroma < 40) {
        alpha = 0;
      }
      if (chroma > 39) {
        alpha = 255;
      }
      pixels[rowOffset + x] = color(chroma, chroma, chroma, alpha);
    }
  }
  colorMode(RGB, 255);
}

void copyCurrentFrame() {
  cam.loadPixels();
  arrayCopy(cam.pixels, pixels);
}
