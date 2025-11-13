import java.nio.*;

class FrameAssembler {
  static final int HEADER_SIZE = 14;

  private int currentFrameId = -1;
  private int totalLength = 0;
  private int chunkCount = 0;
  private byte[][] chunkData = new byte[0][];
  private int[] chunkLengths = new int[0];
  private boolean[] received = new boolean[0];
  private int receivedCount = 0;
  private int lastCompletedFrameId = -1;
  private long lastUpdateMs = 0;

  boolean consume(byte[] packet, int packetLength) {
    if (packetLength < HEADER_SIZE) {
      return false;
    }

    ByteBuffer buffer = ByteBuffer.wrap(packet, 0, packetLength);
    buffer.order(ByteOrder.BIG_ENDIAN);

    int frameId = buffer.getInt();
    int totalLen = buffer.getInt();
    int chunkIndex = buffer.getShort() & 0xffff;
    int chunks = buffer.getShort() & 0xffff;
    int payloadLength = buffer.getShort() & 0xffff;

    if (chunks == 0 || payloadLength > packetLength - HEADER_SIZE) {
      return false;
    }

    if (frameId < lastCompletedFrameId) {
      return false;
    }

    if (currentFrameId != frameId) {
      startFrame(frameId, totalLen, chunks);
    } else {
      if (totalLength != totalLen || chunkCount != chunks) {
        startFrame(frameId, totalLen, chunks);
      }
    }

    if (chunkIndex >= chunkCount) {
      return false;
    }

    if (!received[chunkIndex]) {
      byte[] payload = new byte[payloadLength];
      System.arraycopy(packet, HEADER_SIZE, payload, 0, payloadLength);
      chunkData[chunkIndex] = payload;
      chunkLengths[chunkIndex] = payloadLength;
      received[chunkIndex] = true;
      receivedCount++;
      lastUpdateMs = System.currentTimeMillis();
    }

    return receivedCount == chunkCount;
  }

  byte[] buildFrame() {
    if (receivedCount != chunkCount) {
      return null;
    }

    byte[] frame = new byte[totalLength];
    int offset = 0;

    for (int i = 0; i < chunkCount; i++) {
      byte[] chunk = chunkData[i];
      if (chunk == null) {
        return null;
      }
      int len = chunkLengths[i];
      if (offset + len > frame.length) {
        len = max(0, frame.length - offset);
      }
      System.arraycopy(chunk, 0, frame, offset, len);
      offset += len;
    }

    if (offset < frame.length) {
      byte[] trimmed = new byte[offset];
      System.arraycopy(frame, 0, trimmed, 0, offset);
      frame = trimmed;
    }

    lastCompletedFrameId = currentFrameId;
    reset();
    return frame;
  }

  boolean hasExpired(int timeoutMs) {
    return currentFrameId != -1 && (System.currentTimeMillis() - lastUpdateMs) > timeoutMs;
  }

  void reset() {
    currentFrameId = -1;
    totalLength = 0;
    chunkCount = 0;
    chunkData = new byte[0][];
    chunkLengths = new int[0];
    received = new boolean[0];
    receivedCount = 0;
  }

  private void startFrame(int frameId, int totalLen, int chunks) {
    currentFrameId = frameId;
    totalLength = totalLen;
    chunkCount = max(1, chunks);
    chunkData = new byte[chunkCount][];
    chunkLengths = new int[chunkCount];
    received = new boolean[chunkCount];
    receivedCount = 0;
    lastUpdateMs = System.currentTimeMillis();
  }
}
