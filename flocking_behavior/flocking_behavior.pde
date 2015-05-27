Leader l;

ArrayList<Follower> followers;

int wSize;

float rCir; // radius of the circle

void setup() {
  wSize = 900; // set size
  size(wSize, wSize); // set window size
  rCir = wSize/25; // set radius
   
   //(xpos, ypos, radius, rotationSatisfaction, rotationDeceleration, maxVelocity, 
      // maxAcceleration, maxRotation, maxAngular, maxTime, orientation, wanderRate, leaderColor)
   l = new Leader(height/2, width/2, rCir, 2*PI/180, 30*PI/180, 60, 90, 3*PI/4, PI, .01, 0, .15, color(0,100,0));
   followers = new ArrayList<Follower>();
   //(xpos, ypos, radius, radiusSatisfaction, radiusDeceleration, rotationSatisfaction, rotationDeceleration, maxVelocity, 
      //maxAcceleration, maxRotation, maxAngular, maxTime, orientation, followerColor)
   followers.add(new Follower(random(height-rCir*4)+rCir*2, random(width-rCir*4)+rCir*2, rCir, 10, 140, 2*PI/180, 30*PI/180, 50, 110, 3*PI/4, PI, .1, 0, color(0,0,139)));
   
   followers.add(new Follower(random(height-rCir*4)+rCir*2, random(width-rCir*4)+rCir*2, rCir, 10, 140, 2*PI/180, 30*PI/180, 50, 110, 3*PI/4, PI, .1, 0, color(0,0,139)));
   
   //followers.add(new Follower(random(height-rCir*4)+rCir*2, random(width-rCir*4)+rCir*2, rCir, 10, 140, 2*PI/180, 30*PI/180, 50, 110, 3*PI/4, PI, .1, 0, color(0,0,139)));
   
   //followers.add(new Follower(random(height-rCir*4)+rCir*2, random(width-rCir*4)+rCir*2, rCir, 10, 140, 2*PI/180, 30*PI/180, 50, 110, 3*PI/4, PI, .1, 0, color(0,0,139)));
   
  
}

void draw() {
  background(255);
  stroke(0);
  line (rCir, rCir, rCir, height-rCir);
  line (rCir, rCir, width-rCir, rCir);
  line (width-rCir, rCir, width-rCir, height-rCir);
  line (rCir, height-rCir, width-rCir, width-rCir);
  l.drawCharacter(); 
  for (int i = 0; i < followers.size(); i ++ ) {
    Follower f = followers.get(i);
    f.drawCharacter();
    ArrayList<Follower> otherBoids = (ArrayList<Follower>)followers.clone();
    otherBoids.remove(i);
    f.blendToFlock(l, otherBoids, i);
    f.steeringSeekAngular();
  }
}

