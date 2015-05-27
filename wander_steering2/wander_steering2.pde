/******************************************************************************
 * wander_steering
 * moves a character towards a random location in the window
 * by: Jason Suttles
 ******************************************************************************/

// list of past positions for breadcrumbs
FloatList oldX;
FloatList oldY;

// list of targets
FloatList targetX;
FloatList targetY;

// kinematic character
Character c; 

// radius of the character circle
float rCir;

// size of the window
int wSize;

// time since last breadcrumb
int breadcrumbTime;
int newTarget;

/**
 * setup window, character, lists, list of targets, framerate
 */
void setup() {
  // set window size
  wSize = 640;
  size(wSize, wSize);
  
  // set radius of the character circle
  rCir = 20;
  
  // create new character ( xpos(pixels), ypos(pixels), radiusSat(pixels), radiusDecel(pixels), maxVelocity(pixels/second), maxAcceleration(pixels/second/second), 
  //  maxRotation(radians/second), maxAngular(radians/second/second), rotSatisfaction(radians), rotDeceleration(radians), maxTime(seconds), orientation(radians))
  c = new Character(height/2, width/2, 2, 150, 150, 100, 120*PI/180, 120*PI/180, 5*PI/180, 45*PI/180, .1, 0);
  
  
  // create list of past positions
  oldX = new FloatList();
  oldY = new FloatList();
  
  // create target list
  targetX = new FloatList();
  targetY = new FloatList();
    
  breadcrumbTime = millis();
  newTarget = millis();
}

void draw() {
  if( millis() - newTarget > 1000) {
    if (targetX.size() > 0) {
      targetX.remove(0);
      targetY.remove(0);
    }
    targetX.append(random(width));
    targetY.append(random(height));
    newTarget = millis();
  }
  // clear the window
  background(204);
  c.update(); // update the character's position and orientation
  
  // color everything black
  fill(0);
  
  // create the character circle
  ellipse(c.pos.x, c.pos.y, rCir, rCir);
  
  pushMatrix(); // create scope to to rotate only the triangle around the center of the character
  translate(c.pos.x,c.pos.y); // move the triangle to the character's position
  rotate(c.orient); // rotate the triangle to the character's current orientation
  triangle(4*rCir/20, 9*rCir/20, 4*rCir/20, -9*rCir/20, 20*rCir/20, 0); // create the character triangle
  popMatrix(); // close scope
  updateSteering();
  if(millis() - breadcrumbTime > 200) { // update velocity and orientation every 200 milliseconds; leave a bread crumb
    breadCrumbs();
  }
  
  for (int i = 0; i < oldX.size(); i++) { // create bread crumbs that are a quarter the size of the character
    ellipse(oldX.get(i), oldY.get(i), rCir/4, rCir/4);
  }
}

/** 
 * creates bread crumbs to show where the character has been
 * calls character AI implementation
 */
void updateSteering() {
  if (targetX.size() > 0 && targetY.size() > 0) { // if there are targets
    PVector target = new PVector(targetX.get(0), targetY.get(0)); // create a PVector
    int result = c.seek(target); //seek that target
    
    if ( result == 0) { // if the character is at the target, result equals 0
      targetX.remove(0); // if the character has arrived at the target, remove the target from the list
      targetY.remove(0);
    } else {
      c.fixOrientation(); // determine how to fix the character's orientation
    }
  } 
}

void breadCrumbs() {
  oldX.append(c.pos.x);
  oldY.append(c.pos.y);
  
  // if there are more than 10 positions remove the oldest one
  if (oldX.size() > 10) {
    oldX.remove(0);
    oldY.remove(0);
  
  }
  breadcrumbTime = millis();
}
