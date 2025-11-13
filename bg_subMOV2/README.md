# bg_subMOV2

A background-subtraction experiment that layers OpenCV motion masks over a looping movie.

## Intent
- Introduce the OpenCV for Processing bindings and their background subtraction helper.
- Combine live camera analysis with pre-recorded footage for quick compositing tricks.
- Highlight the importance of starting captures and handling asynchronous video events.

## Ingredients
- **Libraries:** `processing.video`, `gab.opencv` (a.k.a. OpenCV for Processing).
- **Hardware:** Webcam.
- **Media:** Provide `data/Untitled_1.mov` or edit the movie filename.

## Run it
1. Install the OpenCV for Processing library (search for "OpenCV" inside the Contribution Manager).
2. Copy your target movie into `data/Untitled_1.mov` or tweak the constructor.
3. Open `bg_subMOV2.pde` in Processing.
4. Run the sketch. You’ll see the movie looping with a cyan-tinted motion mask on top. Tap `U` to let the background model keep learning, `D`/`E` to try dilation or erosion, `C` to drop contour outlines back in, and `R` to reset the learned background.

## How it works
- `opencv.startBackgroundSubtraction(5, 3, 0.5);` initializes a Mixture of Gaussians background model with adjustable history length, mixture count, and learning rate.
- Each `captureEvent` pushes the newest camera frame into OpenCV, then `draw()` optionally calls `updateBackground()`, `dilate()`, and `erode()` based on your key toggles.
- The grayscale foreground mask from `opencv.getOutput()` is tinted and alpha-blended onto the movie so you can see motion energy without leaving Processing’s 2D renderer.
- Hit `C` if you still want to see the raw contour outlines; the HUD at the bottom keeps track of every toggle plus how stale the camera feed is.

## Remix it
- Swap the tint colour in `maskTint` to explore different composite moods (magenta ghosts? acid green silhouettes?).
- Toggle `updateBackground()` mid-performance to contrast a locked-in plate against a constantly adapting model.
- Route the contour count to OSC or MIDI to control other sketches.
