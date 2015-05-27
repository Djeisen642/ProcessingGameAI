class Character {
  // vectors
  PVector accel, vel, pos;
  
  // max linear
  float maxAccel, maxVel, maxT;
  
  // orientation
  float orient, velOrient, orientSteps, angVel, angAccel, maxRot, maxAng;
  
  // radius of satisfaction, deceleration
  float rSat, rDecel;
  
  // range of satisfaction, deceleration
  float rotSat, rotDecel;
  
  float lastUpdate;
  
  /**
   * character constructor
   */
  Character ( float xpos, float ypos, float maxVelocity, float maxAcceleration, 
    float maxRotation, float maxAngular, float maxTime, float orientation) {
    // create and set position, velocity, and acceleration vectors
    pos = new PVector(xpos, ypos);
    vel = new PVector(0,0);
    accel = new PVector(0,0);
    maxVel = maxVelocity; // set max velocity
    maxAccel = maxAcceleration; // set max acceleration
    maxT = maxTime; // time it takes to get to max velocity
    angVel = 0; // set initial angular velocity
    angAccel = 0; // set initial angular acceleration
    maxRot = maxRotation; // set maximum rotation per second
    maxAng = maxAngular; // set maximum angular velocity per second
    orient = orientation; // set initial orientation
    velOrient = 0; // set initial acceleration orientation
    lastUpdate = millis();
  }
  
  /**
   * update position, velocity, orientation, and orientation velocity
   */
  void update() {
    float elapsed = (millis() - lastUpdate)/1000;
    angVel += angAccel * elapsed;
    if (abs(angVel) > maxRot)
      angVel = maxRot * angVel/abs(angVel);
    angVel = mapToRange(angVel);
    orient += angVel * elapsed;
    orient = mapToRange(orient);
    wander();
    PVector temp = new PVector(accel.x, accel.y);    
    temp.mult(elapsed);
    vel.add(temp);
    if (vel.mag() > maxVel) {
      vel.normalize();
      vel.mult(maxVel);
    }
    temp.set(vel);
    temp.mult(elapsed);
    pos.add(vel);   
    if (pos.x > width - 30 || pos.x < 30 || pos.y > height - 30 || pos.y < 30) {    
      if (pos.x > width - 30) {
        vel.x = -abs(vel.x);
      } else if (pos.x < 30) {
        vel.x = abs(vel.x);
      }
      if (pos.y > height - 30) {
        vel.y = -abs(vel.y);
      }   else if (pos.y < 30) {
        vel.y = abs(vel.y);
      }
      orient = atan2(vel.y, vel.x);
    }
    //println(vel.mag() + " , " + accel.mag());
    lastUpdate = millis();
  }
  
  /**
   * moves in the direction of orientation
   * sets linear acceleration in direction of orientation
   */
  void wander() {
    float x = cos(orient);
    float y = sin(orient);
    PVector temp = new PVector(x, y);
    temp.normalize();
    temp.mult(maxVel);
    accel.set(temp);
    accel.div(maxT);
    if (accel.mag() > maxAccel) {
      accel.normalize();
      accel.mult(maxAccel);
    }
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
   * randomly change orientation
   */
  void changeOrientation() {
     float rotation = random(PI) - random(PI);
     angAccel = rotation / maxT;
     if (abs(angAccel) > maxAng) {
       angAccel = maxAng * angAccel/abs(angAccel);
     }
     angAccel = mapToRange(angAccel);
  }
}
