# vidPlay

An OSC-responsive movie player: it listens for vibe levels from `vidControl` and adjusts playback speed accordingly.

## Intent
- Demonstrate how to receive OSC messages in Processing and map them to movie playback controls.
- Encourage modular design by pairing this sketch with an external controller (`vidControl` by default).
- Highlight how to handle missing assets and sanitize filenames.

## Ingredients
- **Libraries:** `processing.video`, `oscP5`, `netP5`.
- **Media:** Supply the movie referenced in `new Movie(this, "ROBOTECH_REMASTERED_VOL_1_? copy.m4v")`. Rename the file or update the string to something filesystem-friendly.
- **Network:** Listens on port `12000` for incoming OSC messages.

## Run it
1. Place your desired video file into the sketch’s `data/` folder and update the filename in `setup()` if needed.
2. Open `vidPlay.pde` in Processing with the Video and OSC libraries installed.
3. Run the sketch. By default it loops the movie.
4. Trigger OSC messages from `vidControl` (or another source) using address patterns `none`, `tiny`, `some`, and `lots`. Each message maps to a playback speed: reverse, slow, normal, and hype mode (1.85x).

## How it works
- `oscEvent(OscMessage theOscMessage)` uses `checkAddrPattern` to compare the incoming message with each expected route. When matched, it updates `newSpeed`.
- The `draw()` loop applies `mov.speed(newSpeed);` each frame and caches `oldSpeed` so unknown messages don’t crash playback—they simply reuse the previous speed.
- There’s no payload validation yet, so this is a good platform for adding safety checks or supporting continuous float parameters.

## Remix it
- Map OSC floats (`/speed`, `/scrub`) instead of discrete address patterns to gain finer control.
- Display on-screen feedback for the current speed and message source.
- Sync audio playback or route simultaneous OSC triggers to DMX/MIDI for multimedia shows.
