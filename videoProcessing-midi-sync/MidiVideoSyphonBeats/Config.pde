// Configuration values that keep the sketch flexible without diving into the code.
// Tweak these for your room, controller, and video routing setup.

class MidiVideoConfig {
  // MIDI bus names (Processing + TheMidiBus must see these exact strings)
  String midiInputName = "IAC Driver Bus 1";
  String midiOutputName = ""; // optional echo, leave empty to disable

  // Video capture
  String preferredCamera = ""; // leave blank to auto-pick the first available camera
  int outputWidth = 1280;
  int outputHeight = 720;
  boolean mirrorCamera = true;

  // Visual treatment
  float beatFlashAmount = 0.35f;
  float chromaBleed = 0.12f;
  float feedbackMix = 0.18f;

  // Tempo smoothing (number of beats used when averaging BPM)
  int bpmSmoothingBeats = 4;
}

MidiVideoConfig CONFIG = new MidiVideoConfig();
