# AsciiVideo_MiM

Render your face as a stream of punky ASCII glyphs and learn how to wrangle pixel brightness into characters.

## Intent
- Explore how to capture live webcam frames in Processing and map brightness to text characters.
- Demonstrate smoothing techniques so the glyph grid doesn’t flicker itself into chaos.
- Provide a ready-made bug hunt (`if (reset = true)` anyone?) to talk about assignment vs. comparison in conditionals.

## Ingredients
- **Libraries:** `processing.video`.
- **Hardware:** Any webcam recognized by Processing.
- **Assets:** The `data/` folder includes `Monospaced-48.vlw` and `UniversLTStd-Light-48.vlw`. The code currently calls `loadFont("Moospaced-48.vlw")`, so rename the file or update the line to make them match—another sneaky teachable bug.

## Run it
1. Open `AsciiVideo_MiM.pde` in Processing.
2. Confirm the **Video** library is installed and grant webcam access when prompted.
3. Hit Run and watch the glyphs stream in real time. Every minute the sketch *tries* to `saveFrame()`—because of the `if (reset = true)` typo the timer resets constantly, so use it to discuss debugging instead of relying on it.

## How it works
- `Capture video = new Capture(this, 160, 120);` grabs a low-res feed to keep the ASCII grid manageable.
- The `letterOrder` string sorts characters from light to dense. During `setup()` the sketch maps each 0–255 brightness level to the appropriate char.
- Each frame, `pixelBright` takes the max RGB component, `bright[index]` smooths the change with a 0.1 lerp, and the character is drawn with the original pixel color for extra flair.
- The timing block at the end shows how to track elapsed minutes and seconds—while also illustrating why `==` matters.

## Remix it
- Swap in a custom font (drop a `.vlw` in `data/` and change `loadFont`).
- Replace `max(r, g, b)` with a proper luma calculation (`0.2126*r + 0.7152*g + 0.0722*b`) and compare the results.
- Fix the timer bug and make the auto-save trigger on a keyboard shortcut or motion detection.
