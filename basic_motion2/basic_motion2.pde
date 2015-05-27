/******************************************************************************
 * basic_motion
 * moves a character at the perimeter of a 640 by 640 window 
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

/**
 * setup window, character, lists, list of targets, framerate
 */
void setup() {
  // set window size
  wSize = 640;
  size(wSize, wSize);
  
  // set radius of the character circle
  rCir = 20;
  
  // create new character (xpos, ypos, maxSp, radiusSat, orientation, oSteps)
  c = new Character(rCir*1.5, wSize-rCir*1.5, 10, 2, 0, 3);
  
  
  // create list of past positions
  oldX = new FloatList();
  oldY = new FloatList();
  
  // create target list
  targetX = new FloatList();
  targetY = new FloatList();
  
  // add targets to list
  targetX.append(rCir*1.5);
  targetY.append(rCir*1.5);
  targetX.append(wSize-rCir*1.5);
  targetY.append(rCir*1.5);
  targetX.append(wSize-rCir*1.5);
  targetY.append(wSize-rCir*1.5);
  targetX.append(rCir*1.5);
  targetY.append(wSize-rCir*1.5);
  
  // set framerate
  frameRate(30);
}

void draw() {
  // clear the window
  background(204);
  
  // every 5 frames add the position to the list of past positions
  if (frameCount % 5 == 0 ) {
    oldX.append(c.pos.x);
    oldY.append(c.pos.y);
    
    // if there are more than 10 positions remove the oldest one
    if (oldX.size() > 10) {
      oldX.remove(0);
      oldY.remove(0);
    }
  }
  
  // color everything black
  fill(0);
  
  // create the character circle
  ellipse(c.pos.x, c.pos.y, rCir, rCir);
  
  pushMatrix(); // create scope to to rotate only the triangle around the center of the character
  translate(c.pos.x,c.pos.y); // move the triangle to the character's position
  rotate(c.orient); // rotate the triangle to the character's current orientation
  triangle(4*rCir/20, 9*rCir/20, 4*rCir/20, -9*rCir/20, 20*rCir/20, 0); // create the character triangle
  popMatrix(); // close scope
  
  breadCrumbs();
}

/** 
 * creates bread crumbs to show where the character has been
 * calls character updates
 */
void breadCrumbs() {
  if (targetX.size() > 0 && targetY.size() > 0) { // if there are targets
  
    PVector target = new PVector(targetX.get(0), targetY.get(0)); // create a PVector
    int result = c.seek(target); //seek that target
    
    if ( result == 0) { // if the character is at the target, result equals 0
      targetX.remove(0); // if the character has arrived at the target, remove the target from the list
      targetY.remove(0);
    } else { // if the character is no at the target
      c.fixOrientation(); // determine how to fix the character's orientation 
      c.update(); // update the character's position and orientation
    }
    
    for (int i = 0; i < oldX.size(); i++) { // create bread crumbs that are a quarter the size of the character
      ellipse(oldX.get(i), oldY.get(i), rCir/4, rCir/4);
    }

  } else { // else there are no targets
  
    for (int i = 0; i < oldX.size(); i++) { // create bread crumbs
      ellipse(oldX.get(i), oldY.get(i), rCir/4, rCir/4);
    }
    
    noLoop(); // stop looping through draw()
  }
}



