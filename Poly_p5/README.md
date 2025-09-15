# Poly_p5

An audio-reactive polygon riot that teaches how to tap the microphone with Minim and animate geometry based on amplitude.

## Intent
- Show how to use the Minim library for live audio input inside Processing.
- Demonstrate polar coordinate drawing and iterative transforms to generate layered polygons.
- Encourage experimentation with thresholds that keep visuals calm when the room is quiet and explosive when the beat drops.

## Ingredients
- **Libraries:** `ddf.minim` (installed via Processing’s Contribution Manager).
- **Hardware:** Microphone or line-in source.
- **Optional assets:** None—this one thrives on live sound.

## Run it
1. Open `Poly_p5.pde` in Processing and make sure the Minim library is available.
2. Plug in a mic, audio interface, or loopback and grant input permissions if your OS nags you.
3. Hit Run and make some noise. The background hue and polygon count will start mutating whenever `in.left.level()` jumps above ~0.01 (scaled to `var > 10`).
4. Smash the `S` key whenever you want to `saveFrame()` a still.

## How it works
- `Minim minim = new Minim(this);` plus `getLineIn()` grabs stereo input; only the left channel drives `var` for simplicity.
- When `var` crosses `10`, the sketch randomizes the polygon side count (`sides`) and background hue, then animates nested shapes via rotation (`rot`) and translation (`tran`).
- The `move()` function maps accumulated distance (`dis`) into rotation, creating a slow spin even when the audio chills out.
- `bow()` alternates fill and stroke colors per layer, teaching how modulo checks create visual rhythm.

## Remix it
- Swap `in.left.level()` for an FFT spectrum and map bass/mids/highs to different behaviors.
- Animate the `strokeWeight` or `colorMode` based on BPM detection for extra chaos.
- Route OSC or MIDI data instead of audio to turn the polygon dance into a controller visualizer.
