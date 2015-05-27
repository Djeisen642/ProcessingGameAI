class Character {
  PVector accel, vel, pos;
  
  ArrayList<PVector> pastPos;
  
  float maxAccel, maxVel, maxT;
  
  float rCir;
  
  float orient, velOrient, orientSteps, angVel, angAccel, maxRot, maxAng;
  
  float rotSat, rotDecel;
    
  float lastUpdate, breadcrumbTime;
  
  float wanderR, wanderOrientation;
  
  boolean wanderToRandomOrientation;
  
  Character (float xpos, float ypos, float radius, float rotationSatisfaction, float rotationDeceleration, float maxVelocity, 
      float maxAcceleration, float maxRotation, float maxAngular, float maxTime, float orientation, float wanderRate, boolean option) {
    pos = new PVector(xpos, ypos);
    vel = new PVector(0,0);
    accel = new PVector(0,0);
    pastPos = new ArrayList<PVector>();
    rCir = radius;
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
    wanderToRandomOrientation = option;
    wanderR = wanderRate;
    wanderOrientation = 0;
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
    if (wanderToRandomOrientation) {
      steeringWanderAngular();
      steeringWanderLinear();
    } else {
      PVector target = steeringOrientationTarget();
      //ellipse(target.x, target.y, rCir/4, rCir/4);
      steeringSeekLinear(target);
      steeringSeekAngular();
    }
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
    println("time: " + elapsed + " , " + temp.mag() + " , " + vel.mag() + " , " + accel.mag() + " , " + accel.heading());
    if (pos.x > width - rCir*1.5 || pos.x < rCir*1.5 || pos.y > height - rCir*1.5 || pos.y < rCir*1.5) {    
      if (pos.x > width - rCir*1.5) {
        vel.x = -abs(vel.x);
      } else if (pos.x < rCir*1.5) {
        vel.x = abs(vel.x);
      }
      if (pos.y > height - rCir*1.5) {
        vel.y = -abs(vel.y);
      }   else if (pos.y < rCir*1.5) {
        vel.y = abs(vel.y);
      }
      orient = vel.heading();
    }
    lastUpdate = millis();
  }
  
  void steeringWanderLinear() {
    PVector tempOrientation = new PVector(cos(orient), sin(orient));
    tempOrientation.normalize();
    tempOrientation.mult(maxVel);
    accel.set(tempOrientation);
    accel.div(maxT);
    accel.limit(maxAccel);
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
  
  void steeringWanderAngular() {
    float rotation = random(PI) - random(PI);
    angVel = mapToRange(angVel);
    angAccel = rotation - angVel;
    angAccel /= maxT;
    if (abs(angAccel) > maxAng) {
      angAccel = maxAng * angAccel/abs(angAccel);
    }
    angAccel = mapToRange(angAccel);
  }
  
  /**
   * seeks target
   * sets linear acceleration in direction of target
   */
  void steeringSeekLinear(PVector target) {
    int phase = 0;
    target.sub(pos); // get direction
    float distance = target.mag(); // get distance
    float goalSpeed = maxVel;
    accel.set(target); // set acceleration direction
    accel.normalize(); // normalize to unit length
    accel.mult(goalSpeed); // direction * goal speed = goal velocity
    accel.div(maxT); // divide total velocity by number of seconds needed to get to max speed
    accel.limit(maxAccel);
  } 
  
  /**
   * change angular acceleration to change orientation of character in direction of linear velocity
   */
  void steeringSeekAngular() {
     float tempOrient = vel.heading(); // get the orientation of velocity
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
  
  PVector steeringOrientationTarget() {
    float wanderRadius = 4*rCir;
    float wanderOffset = 4*rCir;
    wanderOrientation += wanderR * (random(PI)-random(PI));
    wanderOrientation = mapToRange(wanderOrientation);
    float targetOrientation = wanderOrientation + orient;
    targetOrientation = mapToRange(targetOrientation);
    PVector target = new PVector(pos.x, pos.y);
    target.add(new PVector(wanderOffset*cos(orient), wanderOffset*sin(orient)));
    target.add(new PVector(wanderRadius*cos(targetOrientation), wanderRadius*sin(targetOrientation)));
    return target;
  }
}










