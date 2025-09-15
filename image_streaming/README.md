# image_streaming

A trio of sketches that teach how to fling webcam frames across UDP—both in a single Processing sketch and with a dedicated receiver thread.

## Intent
- Demonstrate how to encode a `PImage` into JPEG bytes and ship it via UDP datagrams.
- Compare a simple blocking receive loop against a threaded receiver that decouples network I/O from rendering.
- Provide a jumping-off point for building networked video art installations or remote monitoring tools.

## Folder layout
```
image_streaming/
├── VideoSender/             # Captures webcam frames and broadcasts them
├── VideoReceiver/           # Minimal blocking UDP receiver
└── VideoReceiverThread/     # Receiver that runs networking on a separate thread
```

## Shared ingredients
- **Libraries:** `processing.video` (for capture) plus Java’s built-in `java.net`, `java.io`, and `javax.imageio` packages.
- **Hardware:** Webcam.
- **Network:** Default configuration sends to and listens on `localhost:9100`. Adjust IP/port if you want to go cross-machine.

## Run the demo (single machine)
1. Open `VideoSender/VideoSender.pde` in Processing, make sure the Video library is installed, and hit Run. The console will log the size of each outgoing datagram.
2. In a second Processing window, open either `VideoReceiver/VideoReceiver.pde` (simpler) or `VideoReceiverThread/VideoReceiverThread.pde` (threaded) and hit Run.
3. The receiver prints the byte count for each datagram, decodes the JPEG stream via `ImageIO.read`, and displays the frames.
4. Stop the sender or receiver to observe how blocking I/O behaves; the threaded version keeps rendering even if packets pause.

## Teaching highlights
- `broadcast(PImage img)` constructs a `BufferedImage`, encodes it as JPEG, then pushes the raw bytes into a `DatagramPacket`. Walk through each step to demystify bridging between Processing’s pixel arrays and Java’s image codecs.
- The basic receiver’s `checkForImage()` is intentionally blocking—great for demonstrating why UI threads should avoid long-running calls.
- `ReceiverThread` manages state with `available` flags so the main sketch can poll for new frames without stalling.

## Remix it
- Swap JPEG for PNG or raw RGB data to discuss compression trade-offs.
- Add rudimentary packet headers so you can drop frames gracefully when the network hiccups.
- Extend the thread to multicast frames to multiple viewers or to write incoming images to disk.
