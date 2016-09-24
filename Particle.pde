final float airFrictionThreshold = 3;    // px per frame
final float defaultAcc = 0.1;
final float constantFriction = 0.2;
final float moveThreshold = 1e-5;  // Particle can only be considered as moving if its speed is bigger than this threshold 
float ringContraintR = 0;

final float ringSlowDown = 0.5;

class Particle {
  float x, y;  
  float vx, vy, v, ax, ay, a, dir;
  float forceAcc, frictionAcc;   // Motivate force and friction as accelaration direction
  float forceDir, frictionDir;
  float lineAngle;
  float lineLength;  // when the length of the line is zero, the particle will be drawn as a dot;
  float lineRotateSpeed;

  float xGoal, yGoal, disGoal;
  float vxGoal, vyGoal;

  float xRoot, yRoot;    // location for constructing for the image

  int mode = 0;   // reserved
  boolean moving = false;
  boolean arrived = false;
  boolean shrink = false;

  float mass = 10;

  float noiseFieldId = random(1000);

  Particle(float xRoot, float yRoot) {
    this.xRoot = xRoot;
    this.yRoot = yRoot;
    if (free) {
      this.x = random(width);
      this.y = random(height);
    } else {
      this.x = xRoot;
      this.y = yRoot;
    }
    this.forceDir = random(0, 2 * pi);
    this.forceAcc = 0.1;
    this.frictionAcc = 0.1;
    this.vx = 0;
    this.vy = 0;
    this.ax = defaultAcc * cos(forceAcc);
    this.ay = defaultAcc * sin(forceAcc);

    this.xGoal = width / 2;
    this.yGoal = height / 2;
  }

  void update() {
    v = sqrt(vx * vx + vy * vy);
    if (v <= moveThreshold) {
      moving = false;
      dir = 0;
    } else {
      moving = true;
      if (abs(vx) >= moveThreshold) {
        dir = atan(vy / vx);
        if (vx < 0) {
          dir += pi;
        }
      } else {
        if (vy > 0) {
          dir = pi / 2;
        } else {
          dir = - pi / 2;
        }
      }
    }
    //if (free) {
    //  //randomWalk();
    //  ring();
    //} else {
    //  //runToGoal();
    //  toRoot();
    //}
    if (sys_mode == 0) {
      randomWalk();
    } else if (sys_mode == 1) {
      mass = 10;
      shrink = false;
      ring();
    } else if (sys_mode == 2) {
      shrink = true;
      mass = 1;
      ring();
    } else {
      toRoot();
    }
    checkBorder();
  }

  void randomWalk() {
    forceDir = dirFromNoiseField();
    forceAcc = constantFriction * 3;
    applyAcce();
  }

  void ring() {
    //computeAcce();
    forceDir = dirFromNoiseField();
    forceAcc = constantFriction * 3;
    applyAcce();
    addGravity();
  }

  void addGravity() {
    float dx = (x - gravityCenterX) * ringSlowDown;
    float dy = (y - gravityCenterY) * ringSlowDown;
    float r = sqrt(dx * dx + dy * dy);
    float temp = abs(r - ringContraintR) / height / 2;

    dx += -temp * dx * 0.3;
    dy += -temp * dy * 0.3;

    if (shrink) {
      dx *= 0.98;
      dy *= 0.98;
    }

    x = gravityCenterX + dx / ringSlowDown;
    y = gravityCenterY + dy / ringSlowDown;
  }

  void runToGoal() {
    forceDir = dirTowardGoal();
    if (disGoal > 20) {
      forceAcc = constantFriction * 15;
    } else {
      forceAcc = constantFriction * 15 * disGoal / 20;
    }

    applyAcce();
  }

  void toRoot() {
    xGoal = xRoot;
    yGoal = yRoot;
    runToGoal();
  }

  void computeAcce() {
    computeFriction();

    ax = forceAcc * cos(forceDir) + frictionAcc * cos(frictionDir);
    ay = forceAcc * sin(forceDir) + frictionAcc * sin(frictionDir);
  }

  void applyAcce() {
    computeFriction();
    // combine the effect of force and friction
    ax = forceAcc * cos(forceDir) + frictionAcc * cos(frictionDir);
    ay = forceAcc * sin(forceDir) + frictionAcc * sin(frictionDir);

    vx += ax / mass;
    vy += ay / mass;

    x += vx;
    y += vy;
  }

  void computeFriction() {
    // the direction of the
    getFrictionDir();
    getFrictionStrength();
  }

  void getFrictionDir() {
    // get the direction of the friction
    if (moving) {
      frictionDir = dir + pi;
    } else {
      frictionDir = forceDir + pi;
    }
  }

  void getFrictionStrength() {
    if (moving) {
      frictionAcc = max(0, v - airFrictionThreshold) / 5 + constantFriction;
    } else {
      frictionAcc = min(forceAcc, constantFriction);
    }
  }

  float dirFromNoiseField() {
    return noise(noiseFieldId, global_time) * pi_2 * 3;
  }

  float dirTowardGoal() {
    float dx = xGoal - x;
    float dy = yGoal - y;
    disGoal = sqrt(dx * dx + dy * dy);
    float result = 0;
    if (dx != 0) {
      result = atan(dy / dx);
      if (dx < 0) {
        result += pi;
      }
    } else {
      if (dy > 0) {
        result = pi / 2;
      } else {
        result = - pi / 2;
      }
    }
    return result;
  }

  void checkBorder() {
    if (x < 0 || x > width || y < 0 || y > height) {
      x = random(width);
      y = random(height);
    }
  }

  void draw() {
    //ellipse(x, y, 10, 10);
    stroke(themeBlue);
    fill(themeBlue);
    //ellipse(x, y, 1, 1);
    if (v > 1) {
      line(x, y, x - vx * 2, y - vy * 2);
    } else {
      ellipse(x, y, 1, 1);
    }

    //stroke(color(255, 0, 0));
    //line(x, y, x + ax * 50, y + ay * 50);
    //stroke(color(0, 255, 0));
    //line(x, y, x + cos(forceDir) * 50, y + sin(forceDir) * 50);
  }

  void debugOutput() {
    //println(v, frictionAcc, dir, frictionDir, forceDir, ax, ay, vx, vy);
    //println(v);
    //println(forceDir);
  }
}