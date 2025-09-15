import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.spi.*;

Minim minim;
AudioInput in;

float num = 21, sides = 3, bck = int(random(255));
float tran, rot, dis;
float vm  = 1, vd = 1;
boolean play = true;
float var;

void setup() {
  size(400, 359);
  colorMode(HSB, 360, 100, 100);
  frameRate(20);

  minim = new Minim(this);
  in = minim.getLineIn();
}

void draw() {
  var = in.left.level() * 1000;
  println(var);
  background(bck, 20, 100);
  if (var > 10) {
    bck = noise(bck)+bck;
    sides = sides + round(random(-6, 3));
    if (sides < 1) {
      sides = 2;
    } 
    polygonDance();
  } else {
    sides = 1;
    polygonDance();
  }
}

void polygonDance() {
  pushMatrix();
  translate(width/2, height/2);
  for (float i = num; i > 0; i--) { 
    rotate(radians(rot));
    bow(int(i));
    strokeWeight(map(i, 1, num, 2, 5));
    polygon(tran, 0, map(i, 1, num, 15, 150), sides);
  }
  popMatrix();  
  move();
}

void move() {
  rot  = map(dis, 0, 240*12, 0, 360);
  tran = tran + vm;
  dis  = dis + random(vd);
  if (tran == 240 || tran == 0)
    vm = vm * -1;
  if (dis == 240*12)
    vd = vd * -1;
}

void polygon(float x0, float y0, float r, float n) {
  beginShape();
  for (float i = 0; i <= n; i ++) {
    float  x = r*cos(2*PI*i/n - PI/2) + x0;
    float  y = r*sin(2*PI*i/n - PI/2) + y0;
    vertex(x, y);
  }
  endShape(CLOSE);
}

void bow(float i) {
  if (i % 2 == 0) {
    fill(bck, 100, 100);
    stroke(0, 0, 100);
  } else {
    fill(0, 0, 100);
    stroke(bck, 100, 100);
  }
}
void keyPressed() {
  if (key == 's' || key == 'S') saveFrame();
}