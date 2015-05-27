class Follower {
  PVector accel, vel, pos;
  
  ArrayList<PVector> pastPos;
  
  float maxAccel, maxVel, maxT;
  
  float rSat, rDecel, rCir;
  
  float orient, velOrient, orientSteps, angVel, angAccel, maxRot, maxAng;
  
  float rotSat, rotDecel;
    
  float lastUpdate, breadcrumbTime;
  
  color fColor;
  
  Follower (float xpos, float ypos, float radius, float radiusSatisfaction, float radiusDeceleration, float rotationSatisfaction, float rotationDeceleration, float maxVelocity, 
      float maxAcceleration, float maxRotation, float maxAngular, float maxTime, float orientation, color followerColor) {
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
    fColor = followerColor;
  }
  
  void drawCharacter() {
    fill(fColor);
    noStroke();
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
      int k = 20-i;
      fill(fColor, -pow(1.4,k-4)+255);
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
    //println("time: " + elapsed + " , " + temp.mag() + " , " + vel.mag() + " , " + accel.mag() + " , " + accel.heading());
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
  
  void blendToFlock(Leader leader, ArrayList<Follower> otherBoids, int number) {
    PVector collisionAvoid = collisionAvoidance(otherBoids, leader);
    collisionAvoid.mult(50);
    PVector cohesion = cohesion(otherBoids);
    cohesion.mult(0);    
    PVector velMatch = velocityMatching(otherBoids);
    velMatch.mult(0);
    PVector followL = followLeader(leader.pos);
    followL.mult(20);
    println( number + "Avoidance = " + collisionAvoid.mag() + " , " + collisionAvoid.heading() + " Cohesion = " + cohesion.mag() + " , " +  cohesion.heading() +      
      " VelMatch = " + velMatch.mag() + " , " + velMatch.heading() + " followL = " + followL.mag() + " , " + followL.heading());
    accel.set(collisionAvoid);
    accel.add(cohesion);
    accel.add(velMatch);
    accel.add(followL);
    accel.limit(maxAccel);
    //println(accel.mag() + " , " + accel.heading());
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
  
  PVector collisionAvoidance(ArrayList<Follower> followers, Leader leader) {
    PVector collisionAvoid = new PVector(0,0);
    FloatList collisionTimes = new FloatList();
    Float shortestTime = 1000.0;
    PVector minSeparation = new PVector(0,0);
    PVector relativePos = new PVector(0,0);
    PVector relativeVel = new PVector(0,0);
    for (int i = 0; i < followers.size(); i ++) {
      PVector dPos = new PVector(followers.get(i).pos.x, followers.get(i).pos.y);
      dPos.sub(pos);
      //if (dPos.mag() <  height/2) {
        PVector dVel = new PVector(followers.get(i).vel.x, followers.get(i).vel.y);
        dVel.sub(vel);
        float t = -dPos.dot(dVel)/pow(dVel.mag(), 2);
        if (t >= 0 ) {
          PVector tempTPos = new PVector(followers.get(i).pos.x, followers.get(i).pos.y);
          PVector tempTVel = new PVector(followers.get(i).vel.x, followers.get(i).vel.y);
          tempTVel.mult(t);
          tempTPos.add(tempTVel);
          PVector tempCPos = new PVector(pos.x, pos.y);
          PVector tempCVel = new PVector(vel.x, vel.y);
          tempCVel.mult(t);
          tempCPos.add(tempCVel);
          tempTPos.sub(tempCPos);
          if (tempTPos.mag() < rCir && t < shortestTime) {
            shortestTime = t;
            minSeparation.set(tempTPos);
            relativePos.set(dPos);
            relativeVel.set(dVel);
          }
        }
      //}
    }
    // leader check
    //PVector dPos = new PVector(leader.pos.x, leader.pos.y);
    //dPos.sub(pos);
    //if (dPos.mag() <  height/2) {
      //PVector dVel = new PVector(leader.vel.x, leader.vel.y);
      //dVel.sub(vel);
      //float t = -dPos.dot(dVel)/pow(dVel.mag(), 2);
      //if (t > 0 ) {
        //PVector tempTPos = new PVector(leader.pos.x, leader.pos.y);
        //PVector tempTVel = new PVector(leader.vel.x, leader.vel.y);
        //tempTVel.mult(t);
        //tempTPos.add(tempTVel);
        //PVector tempCPos = new PVector(pos.x, pos.y);
        //PVector tempCVel = new PVector(vel.x, vel.y);
        //tempCVel.mult(t);
        //tempCPos.add(tempCVel);
        //tempTPos.sub(tempCPos);
        //if (tempTPos.mag() < rCir && t < shortestTime) {
          //shortestTime = t;
          //minSeparation.set(tempTPos);
          //relativePos.set(dPos);
          //relativeVel.set(dVel);
        //}
      //}
    //}
    if (shortestTime != 1000) {
      if (minSeparation.mag() > 0 && shortestTime > 0) {
          relativeVel.mult(shortestTime);
          relativePos.add(relativeVel);
      }
      relativePos.normalize();
      relativePos.mult(maxAccel);
      collisionAvoid.set(relativePos);
    } 
    return collisionAvoid;
  }
  
  PVector cohesion(ArrayList<Follower> followers) {
    PVector averagePosition = new PVector(pos.x, pos.y);
    for (int i = 0; i < followers.size(); i ++ ) {
      averagePosition.add(followers.get(i).pos);
    }
    averagePosition.div(followers.size()+1);
    averagePosition.sub(pos);
    averagePosition.normalize();
    averagePosition.mult(maxVel);
    averagePosition.sub(vel);
    averagePosition.div(maxT);
    averagePosition.limit(maxAccel);
    return averagePosition;
  }
  
  PVector velocityMatching(ArrayList<Follower> followers) {
    PVector averageVelocity = new PVector(vel.x, vel.y);
    for (int i = 0; i < followers.size(); i ++ ) {
      averageVelocity.add(followers.get(i).vel);
    }
    averageVelocity.div(followers.size()+1);
    averageVelocity.sub(vel);
    averageVelocity.div(maxT);
    averageVelocity.limit(maxAccel);
    return averageVelocity;
  }
  
  /**
   * seeks leader
   * sets linear acceleration in direction of leader
   * returns (0,1,2) = (stopped, arriving, moving at max speed)
   */
  PVector followLeader(PVector leaderPos) {
    PVector seekAccel = new PVector(leaderPos.x, leaderPos.y);
    seekAccel.sub(pos); // get direction
    float distance = seekAccel.mag(); // get distance
    float goalSpeed = 0;
    if (distance < rSat) { // character is in radius of satisfaction
      goalSpeed = 0;
    } else if (distance > rDecel) { // character is outside of the deceleration radius
      goalSpeed = maxVel; // goal speed is to get to max velocity
    } else { // character is within radius of deceleration but outside radius of satisfaction
      goalSpeed = maxVel * distance/rDecel;
    }
    seekAccel.normalize(); // normalize to unit length
    seekAccel.mult(goalSpeed); // direction * goal speed = goal velocity
    seekAccel.sub(vel); // goal velocity - current velocity = total velocity needed to get to goal velocity
    seekAccel.div(maxT); // divide total velocity by number of seconds needed to get to max speed
    seekAccel.limit(maxAccel);
    return seekAccel;
  }
}










