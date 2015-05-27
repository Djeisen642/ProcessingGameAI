/******************************************************************************
 * basic_motion
 * moves a character at the perimeter of a window 
 * by: Jason Suttles
 ******************************************************************************/

Character c; // character

ArrayList<PVector> targets; // list of targets

int wSize; // size of the window

float rCir; // radius of the circle

void setup() {
  wSize = 900; // set size
  size(wSize, wSize); // set window size
  rCir = wSize/25; // set radius
  // create new character ( xpos, ypos, maxSp, radius, radiusSat, orientation, oSteps)
  c = new Character(rCir*1.5, wSize-rCir*1.5, 150, rCir, 2, 0, 0.35);
  targets = new ArrayList<PVector>(); // initialize targets
  targets.add(new PVector(rCir*1.5, rCir*1.5));
  targets.add(new PVector(width - rCir*1.5, rCir*1.5));
  targets.add(new PVector(width - rCir*1.5, height - rCir*1.5));
  targets.add(new PVector(rCir*1.5, height - rCir*1.5));
}

void draw() {
  background(255); // white background
  
  fill(255); // white target points
  for (int i = 0; i < targets.size(); i++) {
    ellipse(targets.get(i).x, targets.get(i).y, rCir/2, rCir/2);
  }
  c.drawCharacter(); //draw character
  updateKinematics(); // update kinematic behavior
}

/** 
 * calls character AI implementation
 */
void updateKinematics() {
  if (targets.size() > 0 ) { // if there are targets
    int result = c.kinematicSeekLinear(targets.get(0)); //seek that target
    
    if ( result == 0) { // if the character is at the target, result equals 0
      targets.remove(0); // if the character has arrived at the target, remove the target from the list
    } else {
      c.kinematicOrient(); // orient the character to velocity
    }

  } else { // else there are no targets
    noLoop(); // stop looping through draw()
  }
}
