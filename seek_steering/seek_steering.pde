Character c;

ArrayList<PVector> targets;

int wSize;

float rCir;

boolean noTargets;

void setup() {
  wSize = 900;
  size(wSize, wSize);
  rCir = 20;
  //(xpos, ypos, radius, radiusSatisfaction, radiusDeceleration, rotationSatisfaction, rotationDeceleration, maxVelocity, 
      //maxAcceleration, maxRotation, maxAngular, maxTime, orientation)
  c = new Character(height/2, width/2, rCir, 10, 140, 2*PI/180, 30*PI/180, 150, 90, 3*PI/4, PI, .1, 0);
  targets = new ArrayList<PVector>();
  noTargets = true;
}

void draw() {
  background(255);
  
  fill(255);
  for (int i = 0; i < targets.size(); i++) {
    ellipse(targets.get(i).x, targets.get(i).y, rCir/2, rCir/2);
  }
  
  if (noTargets) {
    c.lastUpdate = millis();
    noTargets = false;
  }
  c.drawCharacter(); 
  updateSteering();
}

/** 
 * calls character AI implementation
 */
void updateSteering() {
  if (targets.size() > 0 ) { // if there are targets
    int result = c.steeringSeekLinear(targets.get(0)); //seek that target
    
    if ( result == 0) { // if the character is at the target, result equals 0
      targets.remove(0); // if the character has arrived at the target, remove the target from the list
    } else {
      c.steeringSeekAngular(); // determine how to fix the character's orientation
    }

  } else { // else there are no targets
    noTargets = true;
    c.vel.mult(0);
    c.accel.mult(0);
    noLoop(); // stop looping through draw()
  }
}

/**
 * adds the location at which the mouse was clicked to the list of targets
 * restarts the draw() loop
 */
void mousePressed() {
  targets.add(new PVector(mouseX, mouseY));
  loop();
}
