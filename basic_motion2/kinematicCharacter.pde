class Character {
  // velocity and position vector
  PVector vel, pos;
  
  // various kinematic variables and values 
  float maxSpeed, orient, angVel, rSat, rCir, velOrientation, orientSteps;
  
  /** 
   * character constructor
   */
  Character ( float xpos, float ypos, float maxSp, float radiusSat, float orientation, float oSteps) {
    // create and set position and velocity vectors
    pos = new PVector(xpos, ypos);
    vel = new PVector(0,0);
    
    // set radius of satisfaction
    rSat = radiusSat;
        
    // set max speed
    maxSpeed = maxSp;
    
    // set initial orientation
    orient = orientation;
    
    // set initial angular velocity
    angVel = 0;
    
    // set intial velocity orientation
    velOrientation = 0;
    
    // set number of steps it takes to completely orient character in direction of velocity
    orientSteps = oSteps;
  }
  
  /**
   * update position and orientation
   */
  void update() {
    pos.add(vel);
    orient += angVel;
  }
  
  /**
   * seeks target
   * sets linear velocity in direction of target
   * returns (0,1,2) = (stopped, arriving, moving at max speed)
   */
  int seek(PVector target) {
    int phase = 0;
    target.sub(pos); // get direction
    float distance = target.mag(); // get distance
    
    if (distance < rSat) { // character is in radius of satisfaction
      vel.mult(0); // set velocity to zero
      phase = 0;
    } else if (distance > maxSpeed) { // character is farther than one time step at max speed away
      vel.set(target); // set velocity in direction of target
      vel.normalize(); // normalize velocity to unit length
      vel.mult(maxSpeed); // set velocity to max speed length
      phase = 2;
    } else { // character is within one time step of target
      vel.set(target); // set velocity in direction of target
      vel.normalize(); // normalize velocity to unit length
      vel.mult(distance); // set velocity to distance to target length
      phase = 1;
    }
    return phase;
  } 
  
  
  float mapToRange(float rotation) {
    float r = rotation % (2*PI);
    if (abs(r) <= PI) { 
      return r;
    } else if ( r > PI) {
      return r-2*PI;
    } else {
      return r+2*PI;
    }
  }
  
  /**
   * change angular velocity to change orientation of character in direction of linear velocity
   */
  void fixOrientation() {
    float tempOrientation = atan2(vel.y, vel.x);
    
    tempOrientation = mapToRange(tempOrientation);
    
    
    
    if (abs(tempOrientation - velOrientation) > .0001) { // if calculated orientation is, for all intents and purposes, not equal to velocity orientation 
      velOrientation = tempOrientation; // set velocity orientation to new calculated orientation
      angVel = (velOrientation - orient); // set angular velocity to (velocity orientation - character orientation) to determine how much change in orientation is necessary
      angVel = mapToRange(angVel);
      angVel /= orientSteps; // divide the amount of change necessary by the number of steps desired to make that change
    }
    
    orient = mapToRange(orient);
    
    if (abs(velOrientation - orient) < .0001) { // if velocity orientation and character orientation are, for all intents and purposes, equal
      angVel = 0.0; // set angular velocity to 0
    }
  }
}
