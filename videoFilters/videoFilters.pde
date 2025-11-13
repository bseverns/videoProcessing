import processing.video.*;

Capture cam;
boolean useLegacyMode = false;
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

  if (useLegacyMode) {
    drawLegacyFilters();
    return;
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
  if (key == 'd' || key == 'D') {
    useLegacyMode = !useLegacyMode;
  } else {
    activeFilter = key;
  }
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

void drawLegacyFilters() {
  char filter = Character.toLowerCase(activeFilter);
  if (filter == 'v') {
    for (int y = 0; y < height; y = y + 1) {
      for (int X = 0; X < width; X = X + 1) {
        color px = cam.get(X, y);
        float r = red(px);
        float g = green(px);
        float b = blue(px);
        color c = color(r, g, b);
        set(X, height - y, c);
      }
    }
  } else if (filter == 'm') {
    for (int i = 0; i < width; i = i + 1) {
      for (int j = 0; j < height; j = j + 1) {
        color px = cam.get(i, j);
        float r = red(px);
        float g = green(px);
        float b = blue(px);
        color c = color(r, g, b);
        set(width - i, j, c);
      }
    }
  } else if (filter == 's') {
    for (int i = 0; i < width; i = i + 1) {
      for (int j = 0; j < height; j = j + 1) {
        int sepiaAmount = 20;
        color px = cam.get(i, j);
        float r = red(px) + (2 * sepiaAmount);
        float g = green(px) + sepiaAmount;
        float b = blue(px) - sepiaAmount;
        color c = color(r, g, b);
        set(i, j, c);
      }
    }
  } else if (filter == 'f') {
    for (int i = 0; i < width; i = i + 1) {
      for (int j = 0; j < height; j = j + 1) {
        color px = cam.get(i, j);
        float r = red(px);
        float g = green(px);
        float b = blue(px);
        float s = r + g + b;

        if (-1 < s && s < 182) {
          r = 0;
          g = 51;
          b = 76;
        }
        if (181 < s && s < 364) {
          r = 217;
          g = 26;
          b = 33;
        }
        if (363 < s && s < 546) {
          r = 112;
          g = 150;
          b = 158;
        }
        if (545 < s && s < 766) {
          r = 252;
          g = 227;
          b = 166;
        }
        colorMode(RGB);
        color c = color(r, g, b);
        set(i, j, c);
      }
    }
  } else if (filter == 'y') {
    for (int i = 0; i < width; i = i + 1) {
      for (int j = 0; j < height; j = j + 1) {
        color px = cam.get(i, j);
        float r = red(px);
        float g = green(px);
        float b = blue(px);
        float T = 0;
        float C = (r + b + g) % 255;
        if (C < 40) {
          T = 0;
        }
        if (C > 39) {
          T = 255;
        }
        colorMode(HSB);
        color c = color(C, C, C, T);
        set(i, j, c);
        colorMode(RGB);
      }
    }
  } else {
    for (int i = 0; i < width; i = i + 1) {
      for (int j = 0; j < height; j = j + 1) {
        color px = cam.get(i, j);
        float r = red(px);
        float g = green(px);
        float b = blue(px);
        color c = color(r, g, b);
        set(i, j, c);
      }
    }
  }
}
