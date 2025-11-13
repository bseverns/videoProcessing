# videoRNDM

Prototype timer that randomly drops surprise video clips once the clock hits a target minute/second.

## Intent
- Practice tracking elapsed time in Processing using `millis()`-adjacent helpers (`second()`, `minute()`).
- Explore random scheduling: pick a future timestamp and trigger media when the clock catches up.
- Encourage learners to reason about initialization order and null checks.

## Ingredients
- **Libraries:** `processing.video`.
- **Media:** Provide a set of numbered clips (`00.mov`, `01.mov`, etc.) inside a `data/` folder. The sketch bootstraps with clip `00.mov` and then chases fresh surprises.

## Run it
1. Drop the clips into the `data/` folder. The sketch expects zero-padded filenames because the randomizer uses `nf(int(random(100)), 2)`.
2. Run the sketch. `setup()` locks the window to `size(640, 480)`, grabs the current time, primes the first playback, and schedules a future trigger.
3. When the clock blows past that trigger, the sketch picks another clip name, spins up a new `Movie`, and queues another timestamp so the party keeps rolling.

## How it works
- `startTOTAL` and `stopTOTAL` convert minutes/seconds into a single second count so you can measure differences easily.
- `calculate()` updates the current minute (`cm`) and second (`cs`) offset from the start.
- When the current offset passes the random target, the sketch chooses a new random filename with `nf(int(random(100)), 2)`, swaps to a fresh `Movie`, and schedules the next surprise.

## Remix it
- Replace the time-based trigger with keyboard input, OSC messages, or sensor data.
- Store multiple target timestamps and trigger a queue of clips throughout a performance.
- Add on-screen text showing the countdown to the next clip so the audience can anticipate the glitch.
