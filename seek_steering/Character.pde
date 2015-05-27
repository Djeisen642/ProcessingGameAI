class Character {
  PVector accel, vel, pos;
  
  ArrayList<PVector> pastPos;
  
  float maxAccel, maxVel, maxT;
  
  float rSat, rDecel, rCir;
  
  float orient, velOrient, orientSteps, angVel, angAccel, maxRot, maxAng;
  
  float rotSat, rotDecel;
    
  float lastUpdate, breadcrumbTime;
  
  Character (float xpos, float ypos, float radius, float radiusSatisfaction, float radiusDeceleration, float rotationSatisfaction, float rotationDeceleration, float maxVelocity, 
      float maxAcceleration, float maxRotation, float maxAngular, float maxTime, float orientation) {
    pos = new PVector(xpos, ypos);
    vel = new PVector(0,0);
    accel = new PVector(0,0);
    pastPos = new ArrayList<PVector>();
    rCir = radius;
    rSat = radiusSatisfaction;
    rDecel = radiusDeceleration;
    rotSat = rotationSatisfaction; // set rotational range of satisfaction
    rotDecel = rotationDeceleration; // set rotational range of deceleration
    maxVel = maxVelocity;
    maxAccel = maxAcceleration;
    maxRot = maxRotation;
    maxAng = maxAngular;
    maxT = maxTime;
    orient = orientation;
    lastUpdate = millis();
    breadcrumbTime = millis();
  }
  
  void drawCharacter() {
    fill(0);
    //line(pos.x, pos.y, pos.x +accel.x, pos.y + accel.y);
    //line(pos.x, pos.y, pos.x +vel.x, pos.y + vel.y);
    ellipse(pos.x, pos.y, rCir, rCir);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(orient);
    triangle(4*rCir/20, 9*rCir/20, 4*rCir/20, -9*rCir/20, 20*rCir/20, 0);
    popMatrix();
    if(millis() - breadcrumbTime > 200) {
      breadCrumbs();
    }
    for (int i = 0; i < pastPos.size(); i++) {
      ellipse(pastPos.get(i).x, pastPos.get(i).y, rCir/4, rCir/4);
    }
    update();
  }
  
  
  void breadCrumbs() {
    // every 200 milliseconds add the position to the list of past positions
    pastPos.add(new PVector(pos.x, pos.y));
    
    // if there are more than 10 positions remove the oldest one
    if (pastPos.size() > 10) {
      pastPos.remove(0);
    }
    breadcrumbTime = millis();
  }
  
  void update() {
    float elapsed = (millis() - lastUpdate)/1000;
    PVector temp = new PVector(accel.x,accel.y);
    temp.mult(elapsed); // multiply velocity by time to get distance
    vel.add(temp);
    vel.limit(maxVel);
    temp.set(vel);
    temp.mult(elapsed); // multiply velocity by time to get distance
    pos.add(temp);
    
    angVel += angAccel * elapsed;
    angVel = mapToRange(angVel);
    orient += angVel * elapsed;
    orient = mapToRange(orient);
    
    //println("time: " + millis() + " , " + orient + " , " + angVel + " , " + angAccel);
    println("time: " + millis() + " , " + vel.mag() + " , " + accel.mag());
    lastUpdate = millis();
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
   * seeks target
   * sets linear acceleration in direction of target
   * returns (0,1,2) = (stopped, arriving, moving at max speed)
   */
  int steeringSeekLinear(PVector target) {
    int phase = 0;
    PVector temp = new PVector(target.x, target.y);
    temp.sub(pos); // get direction
    float distance = temp.mag(); // get distance
    float goalSpeed = 0;
    if (distance < rSat) { // character is in radius of satisfaction
      goalSpeed = 0;
      phase = 0;
    } else if (distance > rDecel) { // character is outside of the deceleration radius
      goalSpeed = maxVel; // goal speed is to get to max velocity
      phase = 2;
    } else { // character is within radius of deceleration but outside radius of satisfaction
      goalSpeed = maxVel * distance/rDecel;
      phase = 1;
    }
    accel.set(temp); // set acceleration direction
    accel.normalize(); // normalize to unit length
    accel.mult(goalSpeed); // direction * goal speed = goal velocity
    accel.sub(vel); // goal velocity - current velocity = total velocity needed to get to goal velocity
    accel.div(maxT); // divide total velocity by number of seconds needed to get to max speed
    accel.limit(maxAccel);
    return phase;
  } 
  
  /**
   * change angular acceleration to change orientation of character in direction of linear velocity
   */
  void steeringSeekAngular() {
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










