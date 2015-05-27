class Character {
  // velocity and position vector
  PVector vel, pos;
  
  // various kinematic variables and values 
  float maxSpeed, orient, angVel, rSat, velOrientation, orientSteps, lastUpdate;
  
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
    
    lastUpdate = millis();
  }
  
  /**
   * update position and orientation
   */
  void update() {
    PVector temp = new PVector(0,0);
    temp.set(vel);
    temp.mult((millis() - lastUpdate)/1000); // multiply velocity by time to get distance
    pos.add(temp);
      
    if (abs(velOrientation - orient) < .01) { // if velocity orientation and character orientation are, for all intents and purposes, equal
      angVel = 0.0; // set angular velocity to 0
    } else {
      orient += angVel; // change orientation
      orient = mapToRange(orient);
    }
    //println("orient = " + orient + " , angVel =  " + angVel);
    
    lastUpdate = millis();
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
    } else {//if (distance > maxSpeed){ // character is farther than one velocity update at max speed away
      vel.set(target); // set velocity in direction of target
      vel.normalize(); // normalize velocity to unit length
      vel.mult(maxSpeed); // set velocity to max speed length
      //println("velocity: x = " + vel.x + " , y = " + vel.y + " , time = " + millis());
      //println();
      phase = 2;
    } 
    return phase;
  } 
  
  /**
   * fix rotation so that it is between [PI, -PI]
   */
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
    float tempOrient = vel.heading(); // find orientation of velocity
    if (abs(tempOrient - velOrientation) > 0.001) { // if it's different than the last
      velOrientation = tempOrient; // set it as the new orientation
      angVel = velOrientation - orient; // calculate the change necessary 
      angVel = mapToRange(angVel);
      angVel /= orientSteps; // divide total by number of steps
    }
  }
}
