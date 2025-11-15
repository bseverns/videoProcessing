# AsciiVideo_MiM

Render your face as a stream of punky ASCII glyphs and learn how to wrangle pixel brightness into characters.

## Intent
- Explore how to capture live webcam frames in Processing and map brightness to text characters.
- Demonstrate smoothing techniques so the glyph grid doesn’t flicker itself into chaos.
- Provide a ready-made bug hunt (`if (reset = true)` anyone?) to talk about assignment vs. comparison in conditionals.

## Ingredients
- **Libraries:** `processing.video`.
- **Hardware:** Any webcam recognized by Processing.
- **Assets:** The `data/` folder includes `Monospaced-48.vlw` and `UniversLTStd-Light-48.vlw`. The sketch now loads `Monospaced-48.vlw` directly so first-run font errors are a ghost of workshops past.

## Run it
1. Open `AsciiVideo_MiM.pde` in Processing.
2. Confirm the **Video** library is installed and grant webcam access when prompted.
3. Hit Run and watch the glyphs stream in real time. Every minute the sketch now **actually** drops a `saveFrame()` thanks to the fixed `if (reset) { ... }` block, so you can teach boolean comparisons without sacrificing the auto-save demo.

## How it works
- `Capture video = new Capture(this, 160, 120);` grabs a low-res feed to keep the ASCII grid manageable.
- The `letterOrder` string sorts characters from light to dense. During `setup()` the sketch maps each 0–255 brightness level to the appropriate char.
- Each frame, `pixelBright` takes the max RGB component, `bright[index]` smooths the change with a 0.1 lerp, and the character is drawn with the original pixel color for extra flair.
- The timing block at the end shows how to track elapsed minutes and seconds—while also illustrating why `==` matters.

## Remix it
- Swap in a custom font (drop a `.vlw` in `data/` and change `loadFont`).
- Replace `max(r, g, b)` with a proper luma calculation (`0.2126*r + 0.7152*g + 0.0722*b`) and compare the results.
- Extend the timer logic—now that `reset` behaves, wire in a keyboard shortcut or motion trigger for manual capture bursts.

## What changed and why
- The minute-save routine no longer self-sabotages: `if (reset = true)` became a proper boolean guard so the reset logic waits for the flag and then clears it. That keeps the timer honest and the minute snapshots spaced out the way the syllabus promises.
- `loadFont("Monospaced-48.vlw")` points straight at an existing asset, so students don't have to spelunk for a typo before they even see a pixel. Call it quality-of-life punk rock.
