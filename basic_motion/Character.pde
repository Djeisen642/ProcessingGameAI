class Character {
  // list of past positions
  ArrayList<PVector> pastPos;
  
  // velocity and position vector
  PVector vel, pos;
  
  // various kinematic variables and values 
  float maxSpeed, orient, angVel, rSat, velOrientation, orientSteps, lastUpdate, rCir, breadcrumbTime;
  
  Character ( float xpos, float ypos, float maxSp, float radius, float radiusSat, float orientation, float oSteps) {
    pos = new PVector(xpos, ypos); // initialize position
    vel = new PVector(0,0); //initialize velocity
    pastPos = new ArrayList<PVector>(); // initialize past positions
    rCir = radius; //set circle radius
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
    
    lastUpdate = millis(); //initialize the amount of time since the last update
    breadcrumbTime = millis(); // initialize the amount of time since last breadcrumb was dropped
  }
  
  void drawCharacter() {
    fill(0); // black character
    //line(pos.x, pos.y, pos.x +accel.x, pos.y + accel.y);
    //line(pos.x, pos.y, pos.x +vel.x, pos.y + vel.y);
    ellipse(pos.x, pos.y, rCir, rCir); // draw circle
    pushMatrix(); // use push and pop to set scope of rotation
    translate(pos.x, pos.y); // move the triangle to the correct location
    rotate(orient); // rotate the triangle to the correct orientation
    triangle(4*rCir/20, 9*rCir/20, 4*rCir/20, -9*rCir/20, 20*rCir/20, 0); //draw triangle
    popMatrix();
    if(millis() - breadcrumbTime > 200) { // if it has been 200 ms since the last breadcrumb
      breadCrumbs(); //drop a breadcrumb
    }
    for (int i = 0; i < pastPos.size(); i++) { // draw all breadcrumbs
      ellipse(pastPos.get(i).x, pastPos.get(i).y, rCir/4, rCir/4);
    }
    update(); //update position and orientation
  }
  
  /**
   * add a previous position to the list of past positions to later be displayed as a breadcrumb
   */
  void breadCrumbs() {
    // every 200 milliseconds add the position to the list of past positions
    pastPos.add(new PVector(pos.x, pos.y));
    
    // if there are more than 10 positions remove the oldest one
    if (pastPos.size() > 10) {
      pastPos.remove(0);
    }
    breadcrumbTime = millis(); // update time since last breadcrumb dropped
  }
  
  /**
   * update position and orientation based on velocity and angular velocity using elapsed time
   */
  void update() {
    float elapsed = (millis() - lastUpdate)/1000; // get time elapsed since last update
    PVector temp = new PVector(vel.x,vel.y);
    temp.mult(elapsed); // multiply velocity by time to get distance
    pos.add(temp);
    if (abs(velOrientation - orient) < .075) { // if velocity orientation and character orientation are, for all intents and purposes, equal
      angVel = 0.0; // set angular velocity to 0
    } else {
      //println(angVel* elapsed);
      orient += angVel * elapsed; // add angular velocity * elapsed time to orientation
      orient = mapToRange(orient);
    }
    lastUpdate = millis(); // set last update to current time
  }
   
  /**
   * seeks target
   * sets linear velocity in direction of target
   * returns (0,1,2) = (stopped, arriving, moving at max speed)
   */
  int kinematicSeekLinear(PVector target) {
    int phase = 0;
    PVector tempTarget = new PVector(target.x, target.y);
    tempTarget.sub(pos); // get direction
    float distance = tempTarget.mag(); // get distance
    
    if (distance < rSat) { // character is in radius of satisfaction
      vel.mult(0); // set velocity to zero
      phase = 0;
    } else {//if (distance > maxSpeed){ // character is farther than one velocity update at max speed away
      vel.set(tempTarget); // set velocity in direction of target
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
  void kinematicOrient() {
    float tempOrient = vel.heading(); // find orientation of velocity
    if (abs(tempOrient - velOrientation) > 0.001) { // if it's different than the last
      velOrientation = tempOrient; // set it as the new orientation
      angVel = velOrientation - orient; // calculate the change necessary 
      angVel = mapToRange(angVel);
      angVel /= orientSteps; // divide total by number of steps
    }
  }
}
