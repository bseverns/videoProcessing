# videoRNDM

Prototype timer that randomly drops surprise video clips once the clock hits a target minute/second.

## Intent
- Practice tracking elapsed time in Processing using `millis()`-adjacent helpers (`second()`, `minute()`).
- Explore random scheduling: pick a future timestamp and trigger media when the clock catches up.
- Encourage learners to reason about initialization order and null checks.

## Ingredients
- **Libraries:** `processing.video`.
- **Media:** Provide a set of numbered clips (`00.mov`, `01.mov`, etc.) and set `stringNum` to a valid base name before `setup()` runs.

## Run it
1. Decide which clip should play first and set `stringNum = "00";` (for example) near the top of the sketch. Without this, `new Movie(this, stringNum+".mov")` will throw a null pointer.
2. Drop the clips into the `data/` folder. The sketch expects zero-padded filenames when you call `nf(int(random(100)))`.
3. Run the sketch. It captures the start time, picks `target_m` and `target_s`, and waits until the clock matches. Once triggered, it loads a new random clip and displays it.

## How it works
- `startTOTAL` and `stopTOTAL` convert minutes/seconds into a single second count so you can measure differences easily.
- `calculate()` updates the current minute (`cm`) and second (`cs`) offset from the start.
- When the current offset matches the random target, the sketch chooses a new random filename with `nf(int(random(100)))` and plays it. This is deliberately sparse so you can expand the scheduler logic.

## Remix it
- Replace the time-based trigger with keyboard input, OSC messages, or sensor data.
- Store multiple target timestamps and trigger a queue of clips throughout a performance.
- Add on-screen text showing the countdown to the next clip so the audience can anticipate the glitch.
