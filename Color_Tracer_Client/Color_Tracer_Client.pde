/* 
 * Matthew Diamond 2014
 */

import processing.video.*;
import processing.net.*;

//Screen resolution
int resX;
int resY;
int resZ;
//Colors
color black;
color white;
//Trace object
Trace trace;
//Client
Client client;

/*******************/
/*     HELPERS     */
/*******************/

/* 
 * Initialize all major objects and variables
 */
void initialize(){
  //Screen resolution
  resX = 800;
  resY = 600;
  resZ = 600;

  //Colors
  black = color(0, 0, 0);
  white = color(255, 255, 255);

  //Trace
  trace = new Trace();

  //Client
  client = new Client(this, "medman826.servequake.com", 5787);
}

/*******************/
/*      SETUP      */
/*******************/

/* 
 * Initialize, print out list of cameras, etc.
 */
void setup(){
  //Set the size of the rendering
  size(800, 800, P3D);
  println("DONE SETTING SIZE");

  //Get variables and objects ready
  initialize();
  println("DONE INITIALIZING");

  //Set rendering colors
  stroke(white);
  noFill();
  background(black);
  println("DONE SETTING RENDERING COLORS");

  println("RUNNING draw()");
}

/*******************/
/*      DRAW       */
/*******************/

/* 
 * Update all information and render
 */
void draw(){

  float[] ratios;
  int[] coordinates = new int[3];

  if(client.available() > 0){
    ratios = float(split(client.readString(), ","));
    if(ratios.length == 3){
      coordinates[0] = (int) (ratios[0] * resX);
      coordinates[1] = (int) (ratios[1] * resY);
      coordinates[2] = (int) (ratios[2] * resZ);
      trace.update(new Coordinates(coordinates[0], coordinates[1], coordinates[2]));

      //Update and render
      if(coordinates[0] <= resX && coordinates[1] <= resY && coordinates[2] <= resZ){
        background(black);
        trace.render();
        println(coordinates[0], coordinates[1], coordinates[2]);
      }
    }
  }
}