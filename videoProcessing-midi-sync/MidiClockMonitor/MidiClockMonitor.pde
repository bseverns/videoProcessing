/**
 * MidiClockMonitor
 * -----------------
 * Lightweight Processing sketch for keeping an eye on an incoming MIDI clock.
 *
 * Built around TheMidiBus library: https://www.smallbutdigital.com/themidibus.php
 * Drop this folder into your Processing sketchbook, install TheMidiBus, and
 * tweak the port names below so they match your rig.
 */

import themidibus.*;
import java.util.ArrayList;

MidiBus bus;

// -- Config -----------------------------------------------------------------
String midiInputName = "IAC Driver Bus 1";  // change to match your clock source
String midiOutputName = "";                 // optional: echo messages back out

float bpm = 0;
float instantaneousBpm = 0;
float bpmSmoothing = 0.2; // closer to 1 = faster reaction, closer to 0 = slower

int clockTicks = 0;       // counts incoming MIDI clock ticks (24 per beat)
int beatCounter = 0;

boolean playing = false;
boolean showDebug = true;

long lastClockMillis = 0;
long lastBeatMillis = 0;

ArrayList<Float> beatIntervals = new ArrayList<Float>();
int maxLoggedBeats = 8;

void setup() {
  size(480, 320);
  surface.setTitle("MIDI Clock Monitor");
  frameRate(60);
  textFont(createFont("Inconsolata", 16));

  MidiBus.list();
  bus = new MidiBus(this, midiInputName, midiOutputName);
}

void draw() {
  background(10);

  fill(255);
  textAlign(LEFT, TOP);
  text("Clock ticks: " + clockTicks, 20, 20);
  text("Beats: " + beatCounter, 20, 44);
  text(String.format("BPM (smoothed): %.2f", bpm), 20, 68);
  text(String.format("BPM (inst): %.2f", instantaneousBpm), 20, 92);
  text("Transport: " + (playing ? "RUN" : "STOP"), 20, 116);

  drawBeatMeter(20, 160, width - 40, 40);

  if (showDebug) {
    drawTimeline(20, 220, width - 40, 70);
  }
}

void drawBeatMeter(float x, float y, float w, float h) {
  noFill();
  stroke(255);
  rect(x, y, w, h);

  if (playing) {
    float phase = (clockTicks % 24) / 24.0;
    float beatWidth = w * phase;
    noStroke();
    fill(0, 200, 255);
    rect(x, y, beatWidth, h);
  }
}

void drawTimeline(float x, float y, float w, float h) {
  fill(180);
  text("Last beat intervals (ms):", x, y);

  float barWidth = w / max(1, beatIntervals.size());
  int i = 0;
  for (float interval : beatIntervals) {
    float mapped = map(interval, 400, 800, 0, h - 20);
    float barHeight = constrain(mapped, 1, h - 20);
    fill(255, 80, 0);
    rect(x + i * barWidth, y + h - barHeight, barWidth - 4, barHeight);
    ++i;
  }
}

// -- MIDI callbacks ----------------------------------------------------------

void clock() {
  long now = millis();
  if (lastClockMillis != 0) {
    float intervalMs = now - lastClockMillis;
    if (intervalMs > 0) {
      float tickBpm = 60000.0 / (intervalMs * 24.0);
      instantaneousBpm = tickBpm;
      if (bpm == 0) {
        bpm = tickBpm;
      } else {
        bpm = lerp(bpm, tickBpm, bpmSmoothing);
      }
    }
  }
  lastClockMillis = now;

  clockTicks++;
  if (clockTicks % 24 == 0) {
    beatCounter++;
    long beatNow = millis();
    if (lastBeatMillis > 0) {
      float beatInterval = beatNow - lastBeatMillis;
      beatIntervals.add(beatInterval);
      while (beatIntervals.size() > maxLoggedBeats) {
        beatIntervals.remove(0);
      }
    }
    lastBeatMillis = beatNow;
  }
}

void start() {
  playing = true;
  println("MIDI START received");
}

void stop() {
  playing = false;
  println("MIDI STOP received");
}

void continue_() {
  playing = true;
  println("MIDI CONTINUE received");
}

void rawMidi(byte[] data) {
  if (data.length == 3) {
    int status = data[0] & 0xFF;
    int data1 = data[1] & 0xFF;
    int data2 = data[2] & 0xFF;
    println(String.format("MIDI %02X %02X %02X", status, data1, data2));
  }
}

void keyPressed() {
  if (key == 'd' || key == 'D') {
    showDebug = !showDebug;
  } else if (key == 'r' || key == 'R') {
    resetCounters();
  }
}

void resetCounters() {
  clockTicks = 0;
  beatCounter = 0;
  bpm = 0;
  instantaneousBpm = 0;
  beatIntervals.clear();
  lastClockMillis = 0;
  lastBeatMillis = 0;
}
