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
4. Wave around. The sketch maps `presenceSum` (sum of RGB differences across the frame) into four ranges and sends OSC messages labelled `none`, `tiny`, `some`, or `lots`. It also spits out a normalized `/motion` float in the payload so downstream tools can dance along a continuous 0–1 curve—check the HUD overlay in `vidPlay` to watch that value breathe.

## How it works
- Each frame, `presenceSum` accumulates the absolute difference between the current frame and the last stored `backgroundPixels`. Because the code updates `backgroundPixels[i] = currColor;` each iteration, it effectively measures per-frame change rather than difference from a static background.
- The `map()` call squeezes `presenceSum` into 0–20. That value selects which OSC message to fire; the payload is a simple integer (`1`–`4`) *and* the same measurement normalized to a 0–1 float published under `/motion`.
- `frameRate(4);` throttles processing to 4 fps so receivers aren’t flooded; you still get a live-but-chill motion feed.

## Remix it
- Capture a clean background image by pressing a key, then compare future frames against that snapshot for more stable results.
- Remix the `/motion` float before sending—try exponential curves, smoothing filters, or separate bands for each region of the frame.
- Chain in OpenCV for blob detection so you only react to specific regions of the frame.
