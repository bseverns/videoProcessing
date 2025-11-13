/**
 * MidiVideoSyphonBeats
 * --------------------
 * Beat-reactive video manipulator that listens to a MIDI clock, mangles a live
 * camera feed, and punts the resulting frames over Syphon for downstream VJ rigs.
 *
 * Requires:
 *   - Processing 3.x (P3D renderer recommended)
 *   - TheMidiBus library for MIDI I/O
 *   - Syphon for Processing (https://github.com/Syphon/Processing)
 *   - processing.video for grabbing a camera feed (or swap in a Movie/Spout/etc.)
 *
 * Drop a Config.pde next to this file to set port names + defaults.
 */

import processing.video.*;
import codeanticode.syphon.*;
import themidibus.*;
import java.util.ArrayDeque;

// Config lives in Config.pde and is loaded automatically by Processing
// -> see MidiVideoConfig in that file for all tweakable knobs.

Capture camera;
PGraphics canvas;
PGraphics feedbackBuffer;
SyphonServer syphon;
MidiBus midi;
PFont hudFont;

float bpm = 0;
float instantaneousBpm = 0;
float averageTickInterval = 0;

boolean playing = false;
int clockCount = 0;
int beatCount = 0;

float flashAmount = 0;
float beatPhase = 0;

ArrayDeque<Float> beatIntervals = new ArrayDeque<Float>();
long lastClockMillis = 0;
long lastBeatMillis = 0;

void settings() {
  // Default size; we resize in setup once CONFIG has been constructed.
  size(1280, 720, P3D);
}

void setup() {
  surface.setTitle("MidiVideoSyphonBeats");
  surface.setResizable(true);
  surface.setSize(CONFIG.outputWidth, CONFIG.outputHeight);

  canvas = createGraphics(CONFIG.outputWidth, CONFIG.outputHeight, P3D);
  feedbackBuffer = createGraphics(CONFIG.outputWidth, CONFIG.outputHeight, P3D);
  hudFont = createFont("Inconsolata", 22);

  initCamera();
  initMidi();
  initSyphon();
}

void draw() {
  updateFlash();

  canvas.beginDraw();
  canvas.background(5);

  drawFeedbackLayer();
  drawCameraLayer();
  applyChromaticAberration(CONFIG.chromaBleed);
  applyBeatFlash(CONFIG.beatFlashAmount);
  drawHud();

  canvas.endDraw();

  updateFeedbackBuffer();

  image(canvas, 0, 0, width, height);
  if (syphon != null) {
    syphon.sendImage(canvas);
  }
}

// ---------------------------------------------------------------------------
// Initialisation helpers

void initCamera() {
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("No cameras detected. We'll fake it with generated visuals.");
    camera = null;
    return;
  }

  String targetCamera = CONFIG.preferredCamera;
  if (targetCamera != null && targetCamera.trim().length() > 0) {
    for (String cam : cameras) {
      if (cam.contains(targetCamera)) {
        targetCamera = cam;
        break;
      }
    }
  } else {
    targetCamera = cameras[0];
  }

  println("Using camera: " + targetCamera);
  camera = new Capture(this, targetCamera);
  camera.start();
}

void initMidi() {
  MidiBus.list();
  midi = new MidiBus(this, CONFIG.midiInputName, CONFIG.midiOutputName);
}

void initSyphon() {
  try {
    syphon = new SyphonServer(this, "MidiVideoSyphonBeats");
  } catch (Exception err) {
    println("Syphon not available: " + err.getMessage());
    syphon = null;
  }
}

// ---------------------------------------------------------------------------
// Rendering helpers

void drawCameraLayer() {
  if (camera != null) {
    if (camera.available()) {
      camera.read();
    }
    canvas.pushMatrix();
    if (CONFIG.mirrorCamera) {
      canvas.translate(canvas.width, 0);
      canvas.scale(-1, 1);
    }
    canvas.image(camera, 0, 0, canvas.width, canvas.height);
    canvas.popMatrix();
  } else {
    // Fake a feed so the shader stack has something to chew on
    canvas.pushStyle();
    canvas.noFill();
    canvas.strokeWeight(3);
    float t = millis() * 0.001f;
    for (int i = 0; i < 16; i++) {
      float phase = t * (i + 1) * 0.5f + beatPhase * TWO_PI;
      float radius = canvas.width * (0.05f + 0.04f * i);
      canvas.stroke(120 + 8 * i, 255, 200 + 3 * i, 180);
      canvas.ellipse(canvas.width / 2, canvas.height / 2, radius + 40 * sin(phase), radius + 40 * cos(phase));
    }
    canvas.popStyle();
  }
}

void drawFeedbackLayer() {
  canvas.pushStyle();
  canvas.tint(255, 255, 255, constrain(CONFIG.feedbackMix, 0, 1) * 255);
  canvas.image(feedbackBuffer, 0, 0, canvas.width, canvas.height);
  canvas.popStyle();
}

void applyChromaticAberration(float amount) {
  if (amount <= 0) {
    return;
  }
  PImage snapshot = canvas.get();
  canvas.pushStyle();
  canvas.blendMode(ADD);
  float offset = amount * 20;
  canvas.tint(255, 80, 80, 160);
  canvas.image(snapshot, offset, 0);
  canvas.tint(80, 255, 120, 140);
  canvas.image(snapshot, -offset, 0);
  canvas.tint(80, 120, 255, 120);
  canvas.image(snapshot, 0, offset * 0.5f);
  canvas.popStyle();
}

void applyBeatFlash(float amount) {
  if (flashAmount <= 0) {
    return;
  }
  float alpha = constrain(flashAmount * amount * 255, 0, 255);
  canvas.pushStyle();
  canvas.noStroke();
  canvas.fill(255, alpha);
  canvas.rect(0, 0, canvas.width, canvas.height);
  canvas.popStyle();
}

void drawHud() {
  canvas.pushStyle();
  if (hudFont == null) {
    hudFont = createFont("Inconsolata", 22);
  }
  canvas.textFont(hudFont);
  canvas.fill(255);
  canvas.textAlign(LEFT, TOP);
  canvas.text(String.format("BPM %.2f", bpm), 20, 20);
  canvas.text("Beats " + beatCount, 20, 50);
  canvas.text("Clock ticks " + clockCount, 20, 80);
  canvas.text("Transport " + (playing ? "RUN" : "STOP"), 20, 110);
  canvas.popStyle();
}

void updateFeedbackBuffer() {
  feedbackBuffer.beginDraw();
  feedbackBuffer.clear();
  feedbackBuffer.image(canvas, 0, 0);
  feedbackBuffer.endDraw();
}

void updateFlash() {
  flashAmount = max(0, flashAmount - 0.05f);
  float beatInMs = averageTickInterval * 24.0;
  if (beatInMs > 0) {
    float sinceBeat = millis() - lastBeatMillis;
    beatPhase = constrain(sinceBeat / beatInMs, 0, 1);
  }
}

// ---------------------------------------------------------------------------
// MIDI plumbing

void clock() {
  long now = millis();
  if (lastClockMillis != 0) {
    float interval = now - lastClockMillis;
    if (interval > 0) {
      instantaneousBpm = 60000.0 / (interval * 24.0);
      if (bpm == 0) {
        bpm = instantaneousBpm;
      } else {
        float alpha = 1.0 / max(1, CONFIG.bpmSmoothingBeats * 24);
        bpm = lerp(bpm, instantaneousBpm, alpha * 12); // weight a few clocks at a time
      }
      if (averageTickInterval == 0) {
        averageTickInterval = interval;
      } else {
        averageTickInterval = lerp(averageTickInterval, interval, 0.1f);
      }
    }
  }
  lastClockMillis = now;

  clockCount++;
  if (clockCount % 24 == 0) {
    beatCount++;
    flashAmount = 1;
    registerBeat(now);
  }
}

void registerBeat(long timestamp) {
  if (lastBeatMillis != 0) {
    float delta = timestamp - lastBeatMillis;
    beatIntervals.add(delta);
    while (beatIntervals.size() > max(1, CONFIG.bpmSmoothingBeats)) {
      beatIntervals.removeFirst();
    }

    float avg = 0;
    for (float val : beatIntervals) {
      avg += val;
    }
    avg /= beatIntervals.size();
    float tickInterval = avg / 24.0;
    if (tickInterval > 0) {
      averageTickInterval = tickInterval;
      bpm = 60000.0 / avg;
    }
  }
  lastBeatMillis = timestamp;
}

void start() {
  println("MIDI START");
  playing = true;
  flashAmount = 1;
}

void stop() {
  println("MIDI STOP");
  playing = false;
}

void continue_() {
  println("MIDI CONTINUE");
  playing = true;
}

void noteOn(int channel, int pitch, int velocity) {
  println(String.format("noteOn ch:%d pitch:%d vel:%d", channel, pitch, velocity));
}

void controllerChange(int channel, int number, int value) {
  println(String.format("CC ch:%d cc:%d value:%d", channel, number, value));
}

void keyPressed() {
  if (key == ' ') {
    playing = !playing;
    println("Toggle transport -> " + (playing ? "RUN" : "STOP"));
  } else if (key == 'f') {
    flashAmount = 1;
  } else if (key == 'c') {
    resetClock();
  }
}

void resetClock() {
  clockCount = 0;
  beatCount = 0;
  bpm = 0;
  instantaneousBpm = 0;
  averageTickInterval = 0;
  beatIntervals.clear();
  lastClockMillis = 0;
  lastBeatMillis = 0;
}
