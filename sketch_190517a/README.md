# sketch_190517a

A random video jukebox that hints at how to integrate serial sensors for playlist control.

## Intent
- Demonstrate movie playback in Processing and how to cycle through a folder of clips.
- Show where you’d plug in serial data (e.g., Arduino) to trigger different playback logic.
- Encourage learners to think about file naming, duration checks, and playlist state.

## Ingredients
- **Libraries:** `processing.video` (required), `processing.serial` (currently commented out but ready if you need it).
- **Media:** Populate the `data/` folder with clips named `0.mov`, `1.mov`, … up to `movTOTAL - 1`. The default `movTOTAL` is `10`.

## Run it
1. Add your clips to the `data/` folder using the numbering scheme above.
2. Open `sketch_190517a.pde` in Processing and confirm the Video library is installed.
3. In `setup()`, either call `mov.play();` after constructing the `Movie`, or change `mov = new Movie(...);` to `mov.loop();` so the first selection actually starts. The code currently forgets to start playback—a perfect debugging exercise.
4. Run the sketch. When a movie reaches the end (`mov.time() == mov.duration()`), `videoSelect()` picks another random file.

## How it works
- `playSelection` stores the filename. `videoSelect()` rebuilds the `Movie` object with a new random index using `nf(int(random(0, movTOTAL)))`.
- Commented serial code shows how you could read bytes from `Serial` to trigger alternate playlists (e.g., `run()` vs. random mode).
- Because `mov.read()` is called every frame without checking `movieEvent`, this sketch pushes you to learn about proper movie event handling.

## Remix it
- Implement `movieEvent(Movie m)` to keep the decoder happy, then gate playback on serial data or OSC.
- Replace the random selection with weighted choices or a Markov chain for curated playlists.
- Display on-screen UI showing which clip is playing and how much time remains.
