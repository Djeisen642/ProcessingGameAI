class Character {
  // vectors
  PVector accel, vel, pos;
  
  // max linear
  float maxAccel, maxVel, maxT;
  
  // orientation
  float orient, velOrient, orientSteps, angVel, angAccel, maxRot, maxAng;
  boolean oriented;
  
  // radius of satisfaction, deceleration
  float rSat, rDecel;
  
  // range of satisfaction, deceleration
  float rotSat, rotDecel;
  
  float lastUpdate;
  
  /**
   * character constructor
   */
  Character ( float xpos, float ypos, float radiusSat, float radiusDecel, float maxVelocity, float maxAcceleration, 
    float maxRotation, float maxAngular, float rotSatisfaction, float rotDeceleration, float maxTime, float orientation) {
    // create and set position, velocity, and acceleration vectors
    pos = new PVector(xpos, ypos);
    vel = new PVector(0,0);
    accel = new PVector(0,0);
    rSat = radiusSat; // set radius of satisfaction
    rDecel = radiusDecel; // set radius of deceleration
    maxVel = maxVelocity; // set max velocity
    maxAccel = maxAcceleration; // set max acceleration
    maxT = maxTime; // time it takes to get to max velocity
    angVel = 0; // set initial angular velocity
    angAccel = 0; // set initial angular acceleration
    maxRot = maxRotation; // set maximum rotation per second
    maxAng = maxAngular; // set maximum angular velocity per second
    rotSat = rotSatisfaction; // set rotational range of satisfaction
    rotDecel = rotDeceleration; // set rotational range of deceleration
    orient = orientation; // set initial orientation
    velOrient = 0; // set initial acceleration orientation
    lastUpdate = millis();
  }
  
  /**
   * update position, velocity, orientation, and orientation velocity
   */
  void update() {
    float elapsed = (millis() - lastUpdate)/1000;
    PVector temp = new PVector(accel.x,accel.y);
    temp.mult(elapsed); // multiply velocity by time to get distance
    vel.add(temp);
    if (vel.mag() > maxVel) {
      vel.normalize();
      vel.mult(maxVel);
    }
    temp.set(vel);
    temp.mult(elapsed); // multiply velocity by time to get distance
    pos.add(temp);
    
    angVel += angAccel * elapsed;
    angVel = mapToRange(angVel);
    orient += angVel * elapsed;
    orient = mapToRange(orient);
    
     println("time: " + millis() + " , " + orient + " , " + angVel + " , " + angAccel);
    //println(orient + " , " + angVel + " , " + angAccel + " , " + velOrient);
    lastUpdate = millis();
  }
  
  /**
   * seeks target
   * sets linear acceleration in direction of target
   * returns (0,1,2) = (stopped, arriving, moving at max speed)
   */
  int seek(PVector target) {
    int phase = 0;
    target.sub(pos); // get direction
    float distance = target.mag(); // get distance
    float goalSpeed = 0;
    if (distance < rSat) { // character is in radius of satisfaction
      accel.mult(0);
      vel.mult(0);
      phase = 0;
    } else if (distance > rDecel) { // character is outside of the deceleration radius
      goalSpeed = maxVel; // goal speed is to get to max velocity
      phase = 2;
    } else { // character is within radius of deceleration but outside radius of satisfaction
      goalSpeed = maxVel * distance/rDecel;
      phase = 1;
    }
    accel.set(target); // set acceleration direction
    accel.normalize(); // normalize to unit length
    accel.mult(goalSpeed); // direction * goal speed = goal velocity
    accel.sub(vel); // goal velocity - current velocity = total velocity needed to get to goal velocity
    accel.div(maxT); // divide total velocity by number of seconds needed to get to max speed
    if (accel.mag() > maxAccel) { // if the calculated acceleration is greater than the max acceleration
      accel.normalize();
      accel.mult(maxAccel); // set it to the max acceleration
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
   * change angular acceleration to change orientation of character in direction of linear velocity
   */
  void fixOrientation() {
     float tempOrient = atan2(vel.y, vel.x); // get the orientation of velocity
     float rotation = tempOrient - orient; // calculate desired rotation
     rotation = mapToRange(rotation); // make sure that rotation is between [-PI, PI]
     float rotSize = abs(rotation); // calculate absolute value of that rotation
     float goalRotation = 0; // initialize goal rotation
     if (rotSize < rotSat) { // if rotation size is less than the range of satisfaction
       angVel = 0; // set angular velocity and acceleration to 0
       angAccel = 0;
       return ;
     } else if (rotSize > rotDecel) { // if rotation size is greater than the range of deceleration
       goalRotation = maxRot; // set goal rotation to max
     } else {
       goalRotation = maxRot * rotSize/rotDecel; // scale goal rotation to a percentage of the range of deceleration 
     }
     goalRotation = goalRotation * rotation/rotSize; // get the direction of rotation
     angAccel = goalRotation - angVel; // calculate desired acceleration
     angAccel /= maxT; // divide by the max time that it takes to reach that desired acceleration;
     if (abs(angAccel) > maxAng) {
      angAccel = maxAng * angAccel/abs(angAccel);
     } 
  }
}
