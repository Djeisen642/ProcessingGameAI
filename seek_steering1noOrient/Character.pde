class Character {
  // vectors
  PVector accel, vel, pos;
  
  // max linear
  float maxAccel, maxVel, maxT;
  
  // orientation
  float orient, accelOrient, orientSteps, angVel, angAccel;
  float velOrientation;
  boolean oriented;
  
  // radius of satisfaction, deceleration, and character
  float rSat, rDecel, rCir;
  
  /**
   * character constructor
   */
  Character ( float xpos, float ypos, float radiusSat, float radiusDecel, float maxVelocity, float maxAcceleration, float maxTime, float orientation, float orientationSteps) {
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
    orient = orientation; // set initial orientation
    accelOrient = 0; // set initial acceleration orientation
    velOrientation = 0;
    orientSteps = orientationSteps; // set number of steps it takes to completely orient character in direction of acceleration
  }
  
  /**
   * update position and orientation
   */
  void update() {
    pos.add(vel);
    vel.add(accel);
    orient += angVel;
    //angVel += angAccel;
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
    float goalSpeed = 0;
    if (distance < rSat) { // character is in radius of satisfaction
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
    accel.sub(vel); // goal velocity - current velocity = total acceleration needed to get to goal velocity
    accel.div(maxT);
    if (accel.mag() > maxAccel) {
      accel.normalize();
      accel.mult(maxAccel);
    }
    return phase;
  } 
  
  /**
   * change angular velocity to change orientation of character in direction of linear velocity
   */
  void fixOrientation() {
    float tempOrientation = 0;
    
    if ( vel.x == 0) { // if x velocity is 0
      if ( vel.y == 0) { // if y velocity is 0
        tempOrientation = orient; // somehow we're at the target and we might as well not change the orientation
      } else if (vel.y > 0) { // if y velocity is positive
        tempOrientation = PI/2; // the target is at PI/2 relative to the character
      } else { // if y velocity is negative
        tempOrientation = -PI/2; // the target is at -PI/2 relative to the character
      }
    } else { // else the target is somewhere between (-PI, -PI/2), (-PI/2, PI/2), (PI/2, PI) relative to the character
      tempOrientation = atan(vel.y/vel.x); // calculate where the target is relative to the character
      
      if (vel.x < 0) { // (- y velocity / x velocity) = (y velocity/ - x velocity) making quadrants 1, 4 indistinguishable from 2, 3 when using atan, therefore check
        tempOrientation = tempOrientation + PI; // if it is in quadrant 2, 3, add PI
      }
      // make sure that orientation is between [-PI, PI]
      if (tempOrientation > PI) {
        tempOrientation = tempOrientation - 2*PI;
      } else if (tempOrientation < -PI) {
        tempOrientation = tempOrientation + 2*PI;
      }
    }
    
    if (abs(tempOrientation - velOrientation) > .0001) { // if calculated orientation is, for all intents and purposes, not equal to velocity orientation 
      velOrientation = tempOrientation; // set velocity orientation to new calculated orientation
      angVel = (velOrientation - orient); // set angular velocity to (velocity orientation - character orientation) to determine how much change in orientation is necessary
      
      // make sure that orientation is between [-PI, PI]
      if (angVel > PI) {
        angVel = angVel - 2*PI;
      } else if (angVel < -PI) {
        angVel = angVel + 2*PI;
      }
      angVel /= orientSteps; // divide the amount of change necessary by the number of steps desired to make that change
    }
    
    // make sure that the character orientation is between [-PI, PI]
    if (orient > PI) {
      orient = orient - 2*PI;
    } else if (orient < -PI) {
      orient = orient + 2*PI;
    }
    
    if (abs(velOrientation - orient) < .0001) { // if velocity orientation and character orientation are, for all intents and purposes, equal
      angVel = 0.0; // set angular velocity to 0
    }
  }
}
