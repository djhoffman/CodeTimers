/*
  CodeTimers
  remixed by DJ

  Expects a string of comma-delimted Serial data from Arduino:
  ** field is 0 or 1 as a string (switch) — not used
  ** second fied is 0-4095 (potentiometer)
  ** third field is 0-4095 (LDR) — not used, we only check for 2 data fields
    
 */
 

// Importing the serial library to communicate with the Arduino 
import processing.serial.*;    

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      

// Data coming in from the data fields
// data[0] = "1" or "0"                  -- BUTTON
// data[1] = 0-4095, e.g "2049"          -- POT VALUE
// data[2] = 0-4095, e.g. "1023"        -- LDR value
String [] data;

int switchValue = 0;
int potValue = 0;
int ldrValue = 0;

// Change to appropriate index in the serial list — YOURS MIGHT BE DIFFERENT
int serialIndex = 19;

// display for pics
PFont text;

// lines for the pics 
String[] lines;
int currentLineNum = 0;

// timing for pics
Timer displayTimer;
float timePerLine = 0;
float minTimePerLine = 100;
float maxTimePerLine = 1000;
int defaultTimerPerLine = 1500;

// mapping pot values
float minPotValue = 0;
float maxPotValue = 4095;

boolean showRise = false;
PImage[] imageList = new PImage[8];
int img;

float c;

//SETUP SETUP SETUP SETUP SETUP SETUP............
void setup ( ) {
  size (600,  600);   
  
  imageList[0] = loadImage("pink1.jpg");
  imageList[1] = loadImage("pink2.jpg");
  imageList[2] = loadImage("pink3.png");
  imageList[3] = loadImage("pink4.jpg");
  imageList[4] = loadImage("rainbow1.jpg");
  imageList[5] = loadImage("rainbow2.jpg");
  imageList[6] = loadImage("rainbow3.jpg");
  imageList[7] = loadImage("rainbow4.jpg");
  
  textAlign(CENTER);
  text = createFont("Helvetica", 100);
 
 colorMode(HSB);
  
  // List all the available serial ports
  printArray(Serial.list());
  
  // Set the com port and the baud rate according to the Arduino IDE
  //-- use your port name
  myPort  =  new Serial (this, "/dev/cu.SLAB_USBtoUART",  115200); 
  
  
  // Allocate the timer
  displayTimer = new Timer(defaultTimerPerLine);
  
   // settings for drawing the ball
  loadText();
  startText();
} 
//SETUP SETUP SETUP SETUP SETUP SETUP..........


// We call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  
    
    print(inBuffer);
    
    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));
    
    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');
   
   // we have THREE items — ERROR-CHECK HERE
   if( data.length >= 2 ) {
      switchValue = int(data[0]);           // first index = switch value 
      potValue = int(data[1]);               // second index = pot value
      ldrValue = int(data[2]);               // third index = LDR value
      
      // change the display timer
      timePerLine = map( potValue, minPotValue, maxPotValue, minTimePerLine, maxTimePerLine );
      displayTimer.setTimer( int(timePerLine));
   }
  }
} 

//-- change background to red if we have a button
void draw ( ) {  
  // every loop, look for serial information
  checkSerial();
  drawBackground();
  checkTimer();
  drawText();
} 

// if input value is 1 (from ESP32, indicating a button has been pressed), change the background
void drawBackground() {
    background(255);  //white
}

//drag mouse around to make rainbow fun
void mouseDragged() {
  fill(c, 255, 255); //rainbow
  rect(0, 0, 600, 600);
}

void loadText() {
   lines = loadStrings("text.txt");
   
   // This shows the text lines in the debugger
  println("there are " + lines.length + " lines");
  for (int i = 0 ; i < lines.length; i++) {
    println(lines[i]);
  } 
}

//-- resets all variables
void startText() {
  currentLineNum = 0;
  displayTimer.start();
}

//-- look at current value of the timer and change it
void checkTimer() {
  //-- if timer is expired, go to next  the line number
  if( displayTimer.expired() ) {
     currentLineNum++;
     
     // check to see if we are at pink text, then go to rainbow
     if( currentLineNum == lines.length ) 
       currentLineNum = 0;
       
       if( lines[currentLineNum].equals("Pink") )
          showRise = true;
       else
         showRise = false;
         
     displayTimer.start(); 
  }
}

//https://www.openprocessing.org/sketch/100832/
//-- draw images
//-- draw text
void drawText() {
  
  //-- CURRENT LINE (may be blank!)
  textFont(text);
  if (c >= 255)  c=0;  else  c++;
  
  if( showRise ) {
    fill(255); //white
    textSize(100);
    image(imageList[(int)random(3)], 0, 0);
  } 
  else { 
    fill(c, 255, 255);//rainbow
    textSize(100);
    image(imageList[(int)random(7)], 0, 0, 600, 600);
  }
  
  text(lines[currentLineNum], width/2, height/2 ); 
}
