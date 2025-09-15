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
4. Add `video.start();` inside `setup()` before running—without it, the capture never feeds frames to OpenCV. Treat this as an intentional teaching moment.
5. Run the sketch. You’ll see the movie playing while any contours detected by OpenCV (once you uncomment that block) can be drawn over it.

## How it works
- `opencv.startBackgroundSubtraction(5, 3, 0.5);` initializes a Mixture of Gaussians background model with adjustable history, n-mixtures, and learning rate.
- Each `draw()` cycle calls `opencv.loadImage(video);`, which pulls the latest camera frame into the OpenCV buffer (assuming you started the capture and implement `captureEvent` or rely on lazy reads).
- The contour loop is commented out. Uncommenting it will iterate over detected motion blobs and outline them with `stroke(255, 0, 0);`.

## Remix it
- Replace the contour draw with `opencv.getOutput();` and alpha-blend the mask onto the movie for a proper composite.
- Experiment with `opencv.updateBackground();` toggled on/off to see how a static vs. adaptive background behaves.
- Route the contour count to OSC or MIDI to control other sketches.
