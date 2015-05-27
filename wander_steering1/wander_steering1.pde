/******************************************************************************
 * wander_steering
 * moves a character in a random direction
 * by: Jason Suttles
 ******************************************************************************/

// list of past positions for breadcrumbs
FloatList oldX;
FloatList oldY;

// kinematic character
Character c; 
Character c2;

// radius of the character circle
float rCir;

// size of the window
int wSize;

// time since last breadcrumb
int breadcrumbTime;

/**
 * setup window, character, lists, list of targets, framerate
 */
void setup() {
  // set window size
  wSize = 640;
  size(wSize, wSize);
  
  // set radius of the character circle
  rCir = 20;
  
  // create new character ( xpos(pixels), ypos(pixels), maxVelocity(pixels/second), maxAcceleration(pixels/second/second), 
  //  maxRotation(radians/second), maxAngular(radians/second/second), maxTime(seconds), orientation(radians))
  c = new Character(height/2, width/2, 2, 2, 45*PI/180, 90*PI/180, 1, 0);
  
  
  // create list of past positions
  oldX = new FloatList();
  oldY = new FloatList();
      
  breadcrumbTime = millis();
}

void draw() {
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
  if(millis() - breadcrumbTime > 300) { // update velocity and orientation every 200 milliseconds; leave a bread crumb
    breadCrumbs();
  }
  
  for (int i = 0; i < oldX.size(); i++) { // create bread crumbs that are a quarter the size of the character
    ellipse(oldX.get(i), oldY.get(i), rCir/4, rCir/4);
  }
}

/** 
 * calls character AI implementation
 */
void updateSteering() {
  c.changeOrientation(); 
}

void breadCrumbs() {
  // every 200 milliseconds add the position to the list of past positions
  oldX.append(c.pos.x);
  oldY.append(c.pos.y);
  
  // if there are more than 10 positions remove the oldest one
  if (oldX.size() > 10) {
    oldX.remove(0);
    oldY.remove(0);
  
  }
  breadcrumbTime = millis();
}
