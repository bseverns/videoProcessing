# videoProcessing Lab Manual

Welcome to the scrappy classroom where every Processing sketch is an excuse to bend light, sound, and network packets until they dance. This repo corrals a bunch of video-centric experiments so you can study how they tick, remix them for your own projects, or just vibe with the glitch.

## Why this collection exists
Each folder holds a Processing sketch that targets a specific idea: ASCII camera feeds, OSC-controlled playback, UDP streaming, VHS simulation, and more. The code might be rough around the edges (some sketches are straight-up works in progress), but that's exactly why it's useful as a teaching tool. You get to see the decisions, the mistakes, and the hacks all laid bare.

## Gear up: environment and libraries
1. **Install Processing 3.5.x or Processing 4.x.** These sketches were authored in the classic PDE and expect the Java mode runtime.
2. **Add the following libraries through the Processing Contribution Manager unless noted otherwise:**
   - **Video** – core webcam/movie playback for most sketches.
   - **Minim** – audio input for `Poly_p5`.
   - **oscP5** and **netP5** – OSC networking in `vidControl` and `vidPlay`.
   - **OpenCV for Processing** (by Greg Borenstein) – computer-vision helpers in `bg_subMOV2`.
   - The remaining imports rely on the Java standard library (`java.net`, `java.io`, `javax.imageio`) and ship with Processing; no extra installation needed.
3. **Hardware checklist:**
   - A webcam that Processing can see.
   - A microphone or line-in source if you want to drive the audio-reactive sketches.
   - Speakers or headphones if you're vibing with Minim.
4. **Media assets:** drop any required `.mov`, `.mp4`, or `.jpg` files into the sketch’s `data` folder (create it when missing). The table below calls out the filenames each sketch is expecting right now.

## Running the sketches
1. Launch Processing and open the folder of the sketch you want (`File → Open...` and pick the `.pde`).
2. Confirm the library imports at the top of the sketch match the libraries you have installed.
3. Make sure any referenced media files exist inside a `data` subfolder next to the `.pde`.
4. Hit the **Run** button. If the console screams about missing files or libraries, fix those first—debugging is part of the lesson.

## Sketch roster at a glance
| Folder | Theme | Key Libraries | Media + Setup Notes |
| --- | --- | --- | --- |
| `AsciiVideo_MiM` | Live webcam feed rendered as ASCII glyphs with a timer that tries to auto-save frames. | `processing.video` | Uses the bundled `Moospaced-48` font files. Webcam required. The auto-save logic currently resets every frame—great bug-hunting fodder. |
| `Poly_p5` | Audio-reactive polygon swarm that rotates and morphs with input amplitude. | `ddf.minim` | Needs a microphone/line-in. Press `S` to save a frame when the visuals slap. |
| `bg_subMOV` | Background subtraction on the webcam to drive the playback speed of `Untitled_1.mov`. | `processing.video` | Place `Untitled_1.mov` in `data/`. Movement near the camera maps to movie speed (including reverse). |
| `bg_subMOV2` | OpenCV-powered background subtraction composited on top of a looping movie. | `processing.video`, `OpenCV for Processing` | Drop `Untitled_1.mov` into `data/`. Keys `U`/`D`/`E`/`C` flip background learning, morphology, and contour overlays while a tinted motion mask rides over the footage. |
| `compositeVideoSim` | Port of Jonathan Campbell’s composite-video simulator for analog VHS grime. | (core Processing only) | Set `filename`/`fileext` to a real image in `data/` before running. Heavy on image processing, so be patient. |
| `image_streaming` | UDP-based video streaming between Processing sketches (sender + two receiver flavors). | `processing.video` | Run `VideoSender` and either receiver. Watch the HUD for live packet assembly stats, drop counts, and idle time while you tune ports/IPs (default `localhost:9100`). |
| `sketch_190517a` | Randomized movie playlist with (commented) serial hooks for external triggers. | `processing.video` | Populate `data/` with numbered clips like `0.mov`…`9.mov`. The playlist loops when each movie ends. |
| `vidControl` | Webcam motion detector that reports a normalized `/motion` float about how rowdy the scene is. | `processing.video`, `oscP5`, `netP5` | Streams 0–1 motion values at ~4 fps to `127.0.0.1:12000`. Pair with `vidPlay`’s HUD to calibrate thresholds. |
| `vidPlay` | OSC-controlled movie playback that responds to the vibe levels from `vidControl`. | `processing.video`, `oscP5`, `netP5` | Supply the referenced video file (currently `ROBOTECH_REMASTERED_VOL_1_? copy.m4v`) in `data/`. It now listens for the `/motion` float and displays speed + raw value in the bottom HUD. |
| `videoFilters` | Keyboard-driven webcam filters for mirroring, sepia, posterization, and threshold effects. | `processing.video` | Use keys `v`, `m`, `s`, `f`, `y` to switch looks. Any other key resets to the raw feed. |
| `videoRNDM` | Prototype for scheduling surprise video clips based on elapsed time. | `processing.video` | Ships with a default clip ID (`00.mov`), auto-schedules new triggers, and swaps to fresh movies as the timer advances. Drop your numbered clips in `data/`. |

## Media file expectations
| Sketch | Current filename(s) referenced in code | What to do |
| --- | --- | --- |
| `bg_subMOV`, `bg_subMOV2` | `Untitled_1.mov` | Replace with your own clip but keep the filename or update the code. Drop it inside each sketch’s `data/` folder. |
| `vidPlay` | `ROBOTECH_REMASTERED_VOL_1_? copy.m4v` | Rename your target file to something sane and edit the `new Movie` call to match. |
| `sketch_190517a` | `0.mov` … `9.mov` (driven by `movTOTAL`) | Provide numbered clips or tweak the selector logic. |
| `videoRNDM` | `stringNum + ".mov"` (starts at `00.mov`) | Provide zero-padded clips (e.g. `00.mov`, `01.mov`). The sketch randomizes the next filename each time a trigger fires. |
| `compositeVideoSim` | Image file defined by `filename`/`fileext` | Drop an image into the sketch folder and update the variables. |

## How to contribute or extend
- Clone the repo, branch locally (or live dangerously on `main`), and add your own sketch folders with their own README.
- Document what you learn. The imperfections in these sketches are features when you explain *why* they behave that way.
- If you fix a bug, call it out loudly so future readers know what changed and why.

Now go make the pixels scream.
