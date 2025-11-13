import processing.video.*;

int startSECOND, startMINUTE, startTOTAL;
int stopSECOND, stopMINUTE, stopTOTAL;
int cm, cs;
int target_m = 0;
int target_s = 0;
boolean startcount = false;
boolean isPlaying = false;

Movie mov;

float rnd;
String stringNum = "00";

void setup() {
  size(640, 480);
  startcount = true;
  startSECOND=second();
  startMINUTE=minute();
  startTOTAL = startMINUTE*60 + startSECOND;
  setNextTarget();

  playClip(stringNum);
}

void draw() {
  background(0);
  calculate();

  if (shouldTrigger()) {
    triggerNextClip();
  }

  if (mov != null && isPlaying) {
    image(mov, 0, 0, width, height);
  }
}

boolean shouldTrigger() {
  return startcount && (cm > target_m || (cm == target_m && cs >= target_s));
}

void triggerNextClip() {
  stringNum = nf(int(random(100)), 2);
  playClip(stringNum);
  setNextTarget();
}

void playClip(String clipId) {
  if (mov != null) {
    mov.stop();
  }
  mov = new Movie(this, clipId + ".mov");
  mov.play();
  isPlaying = true;
}

void setNextTarget() {
  int deltaSeconds = int(random(1, 8 * 60 + 1));
  int totalSeconds = (cm * 60 + cs) + deltaSeconds;
  target_m = totalSeconds / 60;
  target_s = totalSeconds % 60;
}

void movieEvent(Movie m) {
  m.read();
}

void calculate()
{
  if (startcount)
  {
    stopMINUTE = minute();
    stopSECOND = second();

    stopTOTAL = stopMINUTE*60 + stopSECOND;

    int diff = stopTOTAL-startTOTAL;
    cm = diff/60;
    cs = diff - cm*60;
  }
}