# videoFilters

A grab bag of webcam filter snippets for teaching pixel-level manipulation in Processing.

## Intent
- Show how to access and modify individual pixels from a `Capture` stream.
- Demonstrate simple effects: vertical flip, horizontal mirror, sepia toning, faux "Warhol" palette, and threshold mask.
- Encourage exploration of color spaces by flipping between RGB and HSB.

## Ingredients
- **Libraries:** `processing.video`.
- **Hardware:** Webcam.

## Run it
1. Open `videoFilters.pde` in Processing and make sure the Video library is installed.
2. Run the sketch and grant camera access. The default view is a raw passthrough.
3. Smash keys to swap filters:
   - `v` – vertical flip.
   - `m` – horizontal mirror.
   - `s` – sepia tint via manual channel offsets.
   - `f` – color posterization into four tone bands (like a lo-fi Instagram filter).
   - `y` – experimental threshold mask using HSB values.
   - Any other key – resets to the unfiltered feed.

## How it works
- The sketch loops through every pixel on each draw, pulling values with `cam.get(i, j)` and writing back with `set(...)`. It’s not optimized, which makes it handy for discussing performance trade-offs.
- Each filter manipulates RGB channels differently, showing how simple arithmetic can produce stylized looks.
- The `y` key toggles to HSB mode temporarily, illustrating how to juggle multiple color spaces in one frame.

## Remix it
- Replace the nested loops with `loadPixels()`/`updatePixels()` for faster operations and show the speed difference.
- Add keyboard commands to blend between filters instead of switching abruptly.
- Pipe the processed pixels into a `PGraphics` buffer so you can layer typography or UI on top.
