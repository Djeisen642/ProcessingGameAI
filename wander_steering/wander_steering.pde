Character c;

int wSize;

float rCir; // radius of the circle

void setup() {
  wSize = 900; // set size
  size(wSize, wSize); // set window size
  rCir = wSize/25; // set radius
   //(xpos, ypos, radius, rotationSatisfaction, rotationDeceleration, maxVelocity, 
      // maxAcceleration, maxRotation, maxAngular, maxTime, orientation, wanderRate, option)
   c = new Character(height/2, width/2, rCir, 2*PI/180, 30*PI/180, 100, 90, 3*PI/4, PI, .01, 0, .15, false);
  
}

void draw() {
  background(255);
  // draw boundaries
  line (rCir, rCir, rCir, height-rCir);
  line (rCir, rCir, width-rCir, rCir);
  line (width-rCir, rCir, width-rCir, height-rCir);
  line (rCir, height-rCir, width-rCir, width-rCir);
  c.drawCharacter(); 
}
