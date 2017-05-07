// miap-visualization.pde
// Eric Heep

import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  background(0);
  frameRate(60);
  fullScreen();
  colorMode(HSB, 360); 
  noCursor();
  
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/v") == true) {
    int idx = msg.get(0).intValue();
    float db = msg.get(1).floatValue();
    float timeDelay = msg.get(2).floatValue();
  }
}

void draw() {
  noStroke();
  strokeWeight(2);
  fill(360, 360, 0, 180);
  rect(0, 0, width, height);
}