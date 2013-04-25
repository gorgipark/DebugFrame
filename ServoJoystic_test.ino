
#include <Servo.h>

const int servo1 = 8;       // first servo
const int servo2 = 9; 
const int joyH = 5;        // L/R Parallax Thumbstick
const int joyV = 1;        // U/D Parallax Thumbstick


int servoValH,servoValV;   
int tempJH, tempJV;
int old_servoValH=0;
int old_servoValV=0;


Servo myservo1;  // create servo object to control a servo
Servo myservo2;  // create servo object to control a servo


void setup() {

  // Servo  
  myservo1.attach(servo1);  // attaches the servo
  myservo2.attach(servo2);  // attaches the servo

   myservo1.write(85); 
   myservo2.write(120); 

  // Inizialize Serial
  Serial.begin(9600);
}


void loop(){



    tempJH = analogRead(joyH);       
    servoValH = map(tempJH, 0, 1023, 10, 170);  

    if (old_servoValH!=servoValH)
       {
         old_servoValH=servoValH;   
         myservo1.write(servoValH); 
       } 
    
    tempJV= analogRead(joyV);       
    servoValV = map(tempJV, 0, 1023, 70, 170);  

    if (old_servoValV!=servoValV)
       {
         old_servoValV=servoValV;   
         myservo2.write(servoValV); 
       } 

    Serial.print("!");
    Serial.print(servoValH);   
    Serial.print(",");
    Serial.print(tempJH);   
    Serial.print(",");
    Serial.print(servoValV);   
    Serial.print(",");    
    Serial.print(tempJV);   
    Serial.println();


    delay(15);                                       

}


