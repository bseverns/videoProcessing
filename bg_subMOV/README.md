# bg_subMOV

Teach background subtraction by hijacking a webcam feed to control the playback speed of a movie file.

## Intent
- Illustrate pixel-by-pixel frame differencing with arrays you manage yourself.
- Connect computer-vision output to something tangible—in this case the playback speed of `Untitled_1.mov`.
- Provide a sandbox for experimenting with thresholds and mapping ranges.

## Ingredients
- **Libraries:** `processing.video`.
- **Hardware:** Webcam.
- **Media:** Place a video named `Untitled_1.mov` inside the sketch’s `data/` folder.

## Run it
1. Copy your clip into `data/Untitled_1.mov` (or update the filename in the code).
2. Open `bg_subMOV.pde` in Processing with the Video library installed.
3. Hit Run. The background starts empty; as soon as the first frame arrives the sketch stores it in `backgroundPixels`.
4. Move in front of the camera to bump `presenceSum`. That sum gets mapped to `mov1.speed(newSpeed)` between `-0.5` (rewind) and `2.5` (fast forward).

## How it works
- The loop over `numPixels` computes absolute differences between the current and stored background RGB values, accumulating them into `presenceSum` while also writing a visualization of the difference into the sketch window.
- `backgroundPixels[i] = currColor;` effectively turns this into a *running frame difference* instead of a true static background. Discuss why the motion trail fades quickly and how you might capture a static background snapshot instead.
- After the pixels update, the movie is drawn and its speed is remapped by `map(presenceSum, 1000000, 99999999, -0.5, 2.5);`. Those bounds are intentionally huge, which is a great prompt to talk about calibration.

## Remix it
- Replace `map(...)` with `constrain()` + normalized values to make the controls more predictable.
- Store a rolling average of `presenceSum` to smooth out jitters.
- Use OSC or MIDI instead of direct video playback so motion controls external instruments.
