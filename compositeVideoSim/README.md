# compositeVideoSim

Simulate the crunchy path an analog composite signal takes through VHS decks, complete with chroma bleed and scanlines.

## Intent
- Showcase how to port complex image-processing pipelines into Processing.
- Provide a guided tour through composite video theory: YIQ conversion, QAM modulation, noise injection, and scanline rendering.
- Offer a batch-processing hook for turning a whole folder of images into glitch art.

## Ingredients
- **Libraries:** Core Processing (no external dependencies).
- **Assets:** Supply the image you want to mangle and point the sketch at it via the `filename` and `fileext` variables. Default expects `test.jpg` in the sketch root (or inside `./` relative to the PDE).

## Run it
1. Place your source image alongside `compositeVideoSim.pde` (or inside a `foldername` you set in code).
2. Open the sketch in Processing and edit the config block near the top if you want to change `filename`, tweak noise levels, or enable/disable steps.
3. Run the sketch. Processing resizes the window to `max_display_size` and begins the 19-step signal simulation.
4. Press the **spacebar** to save the processed result. Hit `b` to trigger batch mode, which will churn through every image in `foldername`.

## How it works
- The `composite_layer` function converts RGB pixels to YIQ, runs them through chroma low-pass filters, packs them into a simulated composite waveform, then demodulates with optional VHS FM noise.
- Config flags like `composite_in_chroma_lowpass`, `vhs_svideo_out`, and `video_recombine` let you toggle sections without editing the core loop—great for teaching modular pipelines.
- `renderScanLines()` adds RGB scanlines if `scanlines_scale > 1`, reinforcing how analog displays interleaved color information.

## Remix it
- Feed the output back into the input for recursive degradation.
- Swap the noise models for your own custom functions to mimic camcorder glitches or broadcast interference.
- Pair the batch processor with a folder of webcam grabs to create a time-lapse of analog decay.
