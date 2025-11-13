# videoProcessing-midi-sync

Processing sketches for live video processing with MIDI clock sync, beat-quantized effects, and Syphon output. The real PDEs are back in the repo, tuned for tinkering and ready to be mangled.

## Included sketches

| Sketch | What it does | Key libraries |
| ------ | ------------- | -------------- |
| `MidiClockMonitor` | Watches a MIDI clock, smooths the BPM, and draws a visual metronome for testing sync. | [TheMidiBus](https://www.smallbutdigital.com/themidibus.php) |
| `MidiVideoSyphonBeats` | Captures a camera, reacts to the incoming clock, and spits the output over Syphon with feedback + flashes. | TheMidiBus, [Syphon for Processing](https://github.com/Syphon/Processing), `processing.video` |

Each folder is a straight-up Processing sketch. Drop the folder inside your Processing sketchbook directory or open the PDE file in place with Processing 3.x.

## Install once, jam forever

1. Install Processing 3.x with the P3D renderer available.
2. In Processing's **Sketch → Import Library → Add Library...**, grab **TheMidiBus** and **Syphon for Processing**. The `processing.video` core library ships with Processing, but enable it if you're on a custom build.
3. Plug in a MIDI clock source (hardware or a loopback device like IAC/loopMIDI). Update the `midiInputName` strings in the PDEs to match the ports you actually see in the console.
4. Fire up the sketches:
   - `MidiClockMonitor` is a warm-up utility. Watch the BPM smoothing, tap `d` to toggle debug bars, and `r` to clear history.
   - `MidiVideoSyphonBeats` is the performance patch. By default it auto-selects the first camera and mirrors it. Space toggles the transport visualisation, `f` forces a flash, and `c` clears the tempo memory. Adjust `Config.pde` to pick cameras, tweak beat flashes, or dial the feedback loop hotter.

## Patch notes & philosophy

- The code is annotated but not over-explained. Treat it like a studio notebook: read the comments, then poke at the knobs.
- No Syphon on your machine? The sketch fails gracefully and keeps drawing to the Processing window so you can still iterate.
- The feedback buffer is intentionally lo-fi. Crank `CONFIG.feedbackMix` for smeary echoes or drop it to zero for crisp output.
- `MidiVideoSyphonBeats` prints every CC/note it hears. Map those to real effects when you're ready to go deeper.

Pull requests with field notes, MIDI mappings, or screenshots of the rig mid-chaos are very welcome. Stay scrappy, keep the signal loud, and leave breadcrumbs for the next hacker digging through your notebooks.
