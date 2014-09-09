/* 
 * Matthew Diamond 2014
 */

import processing.video.*;
import processing.net.*;

//The number of times any key has been pressed
int keysPressed;
//Colors
color white;
color black;
//The color trackers
Tracker xy;
Tracker yz;
//Cameras for the trackers
Capture cam;
Capture cam1;
//A list of the cameras available for use
String[] cameras;
//The server
Server server;

/*******************/
/*     HELPERS     */
/*******************/

/* 
 * Initialize all major objects and variables
 */
void initialize(){
  //Number of keypresses
  keysPressed = 0;

  //Colors
  white = color(255, 255, 255);
  black = color(0, 0, 0);

  //Cameras and Color trackers
  cameras = Capture.list();
  String camName = cameras[15];
  String camName1 = cameras[0];
  cam = new Capture(this, camName);
  cam1 = new Capture(this, camName1);
  xy = new Tracker(15, cam, camName);
  yz = new Tracker(15, cam1, camName1);

  //Server
  server = new Server(this, 5787);
}

/* 
 * List available cameras, exit if there are none
 */
void listCameras(){
  if(cameras.length == 0){
    println("There are no cameras available for capture.");
    exit();
  }
  else{
    println("Available cameras:");
    for(int i = 0; i < cameras.length; i++){
      println(i + ":" + cameras[i]);
    }
  }
}

/*******************/
/*      SETUP      */
/*******************/

/* 
 * Initialize, print out list of cameras, etc.
 */
void setup(){
  //Set the size of the rendering
  size(1024, 576);
  println("DONE SETTING SIZE");

  //Get variables and objects ready
  initialize();
  println("DONE INITIALIZING");

  //Set rendering colors
  noFill();
  stroke(white);
  background(black);
  println("DONE SETTING RENDERING COLORS");

  //List cameras
  listCameras();
  println("DONE LISTING CAMERAS");

  println("RUNNING draw()");
}

/*******************/
/*      DRAW       */
/*******************/

/* 
 * Update all information and serve it, display averages
 */
void draw(){
  Client client = server.available();

  //In configuration mode, configure the trackers
  if(xy.confMode || yz.confMode){
    if(xy.confMode){
      xy.update();
    }
    else if(yz.confMode){
      yz.update();
    }
  }

  //No longer in configuration mode, run the application
  else{
    //If both trackers have new information
    if(xy.updated && yz.updated){
      //Get all 3 coordinates
      float x = xy.getCoordinates()[0];
      float y = xy.getCoordinates()[1];
      float z = yz.getCoordinates()[0] * -1;

      //Send packet
      server.write(x + "," + y + "," + z);

      //Reset updated status of the trackers
      xy.updated = false;
      yz.updated = false;

      //Reset debug rendering
      background(black);

      //Debug rendering shows you the current state of the trackers
      println(x, y, z);
      image(cam, 0, height / 4, width / 2, height / 2);
      image(cam1, width / 2, height / 4, width / 2, height / 2);
      xy.update();
      yz.update();
      rect((((xy.coordinates[0] / cam.width) * width) - 7) / 2, ((((xy.coordinates[1] / cam.height) * height)  - 7) / 2) + height / 4, 15, 15);
      rect(((((yz.coordinates[0] / cam1.width) * width) - 7) / 2) + width / 2, (((yz.coordinates[1] / cam1.height) * height)  - 7), 15, 15);
    }
    //If either tracker is out of date, attempt to update both of them
    else{
      xy.update();
      yz.update();
    }
  }
}

/*******************/
/*    HANDLERS     */
/*******************/

/* 
 * Send coordinates from the mouse press to the Tracker object being configured
 * Does nothing unless in configuration mode
 */
void mousePressed(){
  if(keysPressed == 0){
    xy.addColor();
  }
  else if(keysPressed == 1){
    yz.addColor();
  }
}

/* 
 * Increment keysPressed
 * Cycle through Tracker objects each time a key is pressed until all Tracker objects are configured
 * When a Tracker has been configured, disable configuration mode
 */
void keyPressed(){
  keysPressed += 1;
  if(keysPressed == 1){
    xy.confMode = false;
    println("CONFIGURING SECOND CAMERA");
  }
  else if(keysPressed == 2){
    yz.confMode = false;
    println("CONFIGURATION COMPlETE");
  }
}
