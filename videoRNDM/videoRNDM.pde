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
String stringNum;

void setup() {
  startcount = true;
  startSECOND=second();
  startMINUTE=minute();
  startTOTAL = startMINUTE*60 + startSECOND;
  target_m = int(random(0, 8));
  target_s = int(random(0, 59));

  mov = new Movie(this, stringNum+".mov");
  mov.play();
}

void draw() {

  if (target_m == cm) {
    if (target_s == cs) {
      stringNum = nf(int(random(100)));

      image(mov, 0, 0, width, height);
    }
  }
  calculate();
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