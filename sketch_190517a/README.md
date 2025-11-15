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
3. Fire up the sketch. `setup()` now kicks `mov.play()` immediately, so you should see video the moment the window appears—no more “why is this still frame blank?” angst.
4. Let the clip finish. As soon as `mov.time()` catches `mov.duration()`, `videoSelect()` spins the wheel, loads the next `Movie`, and playback continues without a hiccup.
5. Toss in a quick test clip (even a five-second color bar) to prove to yourself that playback jumps in immediately and keeps cycling.

## How it works
- `playSelection` stores the filename. `videoSelect()` rebuilds the `Movie` object with a new random index using `nf(int(random(0, movTOTAL)))`.
- Commented serial code shows how you could read bytes from `Serial` to trigger alternate playlists (e.g., `run()` vs. random mode).
- The sketch now leans on Processing’s `movieEvent(Movie m)` callback to call `m.read()` only when fresh frames arrive, keeping playback smooth without burning cycles.

## Remix it
- Remix the `movieEvent(Movie m)` callback to inject glitch filters, OSC triggers, or other decoding hijinks before the frame hits the screen.
- Replace the random selection with weighted choices or a Markov chain for curated playlists.
- Display on-screen UI showing which clip is playing and how much time remains.
