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
4. Trigger `/motion` floats from `vidControl` (or another source). The HUD strip at the bottom prints the live normalized value and the resulting speed so you can sanity-check the stream in real time.

## How it works
- `oscEvent(OscMessage theOscMessage)` now looks for `/motion`, clamps the float payload into 0–1, eases it with `pow(value, 1.5)`, then maps that eased value through `lerp(-0.5, 2.0, eased)` so chill moments coast in reverse and big spikes rocket forward.
- The `draw()` loop applies `mov.speed(newSpeed);` each frame and paints a semi-transparent HUD so you can debug what OSC is doing without tailing the console.
- There’s no payload validation yet beyond the clamp, so this is a good platform for adding safety checks or supporting additional continuous parameters.

## Remix it
- Fork the easing curve: try `pow(value, 0.8)` for punchier attacks or cascade a low-pass filter before mapping speed.
- Expand the HUD with color ramps, meters, or debug text so performers can read the room from across the stage.
- Sync audio playback or route simultaneous OSC triggers to DMX/MIDI for multimedia shows.
