# vidControl

Motion-driven OSC controller: watch the webcam for movement and shout OSC messages based on how wild things get.

## Intent
- Teach manual frame differencing and accumulation to quantify scene activity.
- Demonstrate how to send OSC messages from Processing using `oscP5`/`netP5`.
- Pair with `vidPlay` (or any OSC-aware app) to build interactive installations.

## Ingredients
- **Libraries:** `processing.video`, `oscP5`, `netP5`.
- **Hardware:** Webcam.
- **Network:** Sends to `127.0.0.1` on port `12000` by default. Adjust `myRemoteLocation` if your receiver lives elsewhere.

## Run it
1. Install `oscP5` and `netP5` via the Contribution Manager (they ship together).
2. Open `vidControl.pde` in Processing, confirm the Video library is available, and place a receiver sketch/app on port `12000`.
3. Hit Run. The webcam feed displays in the window to help with framing.
4. Wave around. The sketch normalizes `presenceSum` (sum of RGB differences across the frame) into a single `/motion` float between 0 and 1 at roughly 4 fps. Pair it with `vidPlay` to see the value and mapped playback speed in that sketch’s HUD. Smash the `b` key to flip between a constantly-refreshing background and a frozen snapshot.

## Controls
- **`b`** – Toggle `liveBackground`. When live, the background continuously tracks the current frame so `/motion` reflects immediate twitchiness. When static, the sketch freezes the current video into `backgroundPixels` and compares all future frames against that still, turning `/motion` into a detector for anything that breaks the tableau.

## How it works
- Each frame, `presenceSum` accumulates the absolute difference between the current frame and the last stored `backgroundPixels`. When `liveBackground` is true, the array is refreshed with the most recent pixels after calculating motion, so you’re tracking frame-to-frame jitter. Flip `liveBackground` off and the array stays locked, so `/motion` reports how rudely the scene diverges from your captured still.
- `presenceSum` is clamped against the theoretical max difference (`numPixels * 255`) so the `/motion` float stays inside 0–1 even if you blast the camera with light.
- `frameRate(4);` throttles processing so receivers aren’t flooded; you still get a live-but-chill motion feed with plenty of time to react on stage.

## Remix it
- Use the built-in `b` toggle to freeze a clean background image, then compare future frames against that snapshot for more stable results—or wire up your own shortcut if you need multiple presets.
- Remix the `/motion` float before sending—try exponential curves, smoothing filters, or separate bands for each region of the frame.
- Chain in OpenCV for blob detection so you only react to specific regions of the frame.
