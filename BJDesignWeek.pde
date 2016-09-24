float global_time = 0;

final color themeBlue = color(16, 51, 128, 255);
Particle[] p;
final int particleNumber = 3000;

final color bgColor = color(0);
PImage logo;
final float logoScale = 0.5;
final color logoBGColor = color(0, 0, 0, 255);

boolean free = true;
int sys_mode = 0;
int modeCD = 300;

final float pi = 3.1415926;
final float pi_2 = pi * 2;

float gravityCenterX;
float gravityCenterY;

void setup() {
  size(1920, 1080);
  println("Staring the program with resolution: ", width, "x", height);
  gravityCenterX = width / 2;
  gravityCenterY = height / 2;
  //
  println("Loading logo file");
  logo = loadImage("data/logo.png");
  //
  println("Initializing Particle Systems");
  p = new Particle[particleNumber];
  float logoWidth = logo.width * logoScale;
  float logoHeight = logo.height * logoScale;
  float offsetX = (width - logoWidth) / 2;
  float offsetY = (height - logoHeight) / 2;
  for (int i = 0; i < particleNumber; i+=1) {
    float xRoot, yRoot;
    while (true) {
      xRoot = random(logoWidth);
      yRoot = random(logoHeight);
      color selected = logo.get(int(xRoot / logoScale), int(yRoot / logoScale));
      if (alpha(selected) > 0) {
        break;
      }
    }
    p[i] = new Particle(xRoot + offsetX, yRoot + offsetY);
    //p[i] = new Particle(0, 0);
    p[i].noiseFieldId = float(i) / 100;
  }
  //
  background(255);
  frameRate(30);
}

void draw() {
  //background(0, 40);
  ringContraintR = (noise(0, global_time)) * width / 4;
  noStroke();
  fill(255, 30);
  rect(0, 0, width, height);
  //fill(color(255));
  //stroke(color(255));

  for (Particle particle : p) {
    particle.update();
    particle.debugOutput();
    particle.draw();
  }

  global_time += 0.01;
  if (modeCD == 1 && sys_mode == 0) {
      sys_mode = (sys_mode + 1) % 4;
  }
  if (modeCD > 0) {
    modeCD --;
  }
}

void mousePressed() {
  free = !free;
  sys_mode = (sys_mode + 1) % 4;
  if (sys_mode == 0) {
    modeCD = 150;
  } else if (sys_mode == 1) {
    modeCD = 0;
  } else {
    modeCD = 0;
  }
  println(sys_mode);
}