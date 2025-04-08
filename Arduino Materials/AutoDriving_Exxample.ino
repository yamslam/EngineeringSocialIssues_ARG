#include <Wire.h>
#include <Adafruit_MotorShield.h> //NOTE: You must import and install this library 
// Create the motor shield object
Adafruit_MotorShield AFMS = Adafruit_MotorShield();
// Select which 'port' M1, M2, M3 or M4
Adafruit_DCMotor *Motor1 = AFMS.getMotor(1);
Adafruit_DCMotor *Motor2 = AFMS.getMotor(2);
Adafruit_DCMotor *Motor3 = AFMS.getMotor(3);
Adafruit_DCMotor *Motor4 = AFMS.getMotor(4);

//Decalre which pins belong to the Sonar Sensor
const int pingPin = 7;
const int echoPin = 6;
//This helps us convert the wave created by the sonar sensor into something meaningful
long duration, inches, cm;

//Declare which pins the line sensors go to NOTE: These are analog inputs
const int linesenseLeft = 0;
const int linesenseRight = 1;

//Declare which pins the buzzer is in
const int buzzer = 13; 

void setup() {
 	// set up Serial library at 9600 bps
  Serial.begin(9600);
 	//Serial.println("Running...");

  //Ping creates the wave, echo catches the reflection 
  pinMode(pingPin, OUTPUT);
  pinMode(echoPin, INPUT);

  //Buzzers buzz, should be an output
  pinMode(buzzer, OUTPUT);

  //Related to the motors idk
 	AFMS.begin();
 	
 	// Set the speed to start, from 0 (off) to 255 (max speed)
 	Motor1->setSpeed(150);
 	Motor1->run(FORWARD);
 	Motor1->run(RELEASE);

   //Motor 2 Setup
 	Motor2->setSpeed(150);
 	Motor2->run(FORWARD);
 	Motor2->run(RELEASE);

   //Motor 3 Setup
 	Motor3->setSpeed(150);
 	Motor3->run(FORWARD);
 	Motor3->run(RELEASE);

  //Motor 4 Setup
 	Motor4->setSpeed(150);
 	Motor4->run(FORWARD);
 	Motor4->run(RELEASE);
}

void loop(){

  //Declared values between 0 and 255 for this. For untimed stuff related to cars, I stayed well below max to observe what was happening
  int motorspeedFULL = 150;
  int motorspeedHALF = 75;
  int motorspeedBRAKE = 0 ;

  //Like I mentioned before, these get put in as an analog signal
  int QRE_Left = analogRead(linesenseLeft);
  int QRE_Right = analogRead(linesenseRight);

  //Sets the min value for white and black NOTE: You may need to use the serial monitor to calibrate these values each time you change enviornments
  int Black = 1013;
  int White = 981;
  int Grey = 1005;
  int TargetDist = 3;

  //Line sensor Read
  Serial.print("Left: ");
  Serial.println(QRE_Left);
  delay(50);
  Serial.print("Right: ");
  Serial.println(QRE_Right);
  delay(50);

  //Sonar sensor read and write
  pinMode(pingPin, OUTPUT);
   digitalWrite(pingPin, LOW);
   delayMicroseconds(2);

   digitalWrite(pingPin, HIGH);
   delayMicroseconds(10);
   digitalWrite(pingPin, LOW);
   pinMode(echoPin, INPUT);

  //Stuff is happening here to convert the time it takes for the ping to come back to the echo. See other functions
   duration = pulseIn(echoPin, HIGH);
   inches = microsecondsToInches(duration);
   cm = microsecondsToCentimeters(duration);

  //Use this to test what values the sonar sensor is giving and recieving
   /*Serial.print(inches);
   Serial.print("in, ");
   Serial.print(cm);
   Serial.print("cm");
   Serial.println();
   delay(100);*/

  if(QRE_Left >= Black && inches >= TargetDist){                             //Left sensor sees line, turn to the left to correct
    
      Serial.println("Turn LEFT");

      Motor1->setSpeed(motorspeedFULL);
  	  Motor1->run(FORWARD);
      Motor2->setSpeed(motorspeedFULL);
  	  Motor2->run(FORWARD);

      Motor3->setSpeed(motorspeedBRAKE);
  	  Motor3->run(FORWARD);
      Motor4->setSpeed(motorspeedBRAKE);
  	  Motor4->run(FORWARD);

      noTone(buzzer);
    
    } else if (QRE_Right >= Black && inches >= TargetDist){                    // Right sensor sees line, turn to the right to correct

    Serial.println("Turn RIGHT");

      Motor3->setSpeed(motorspeedFULL);
  	  Motor3->run(FORWARD);
      Motor4->setSpeed(motorspeedFULL);
  	  Motor4->run(FORWARD);

      Motor1->setSpeed(motorspeedBRAKE);
  	  Motor1->run(FORWARD);
      Motor2->setSpeed(motorspeedBRAKE);
  	  Motor2->run(FORWARD);

      noTone(buzzer);

  } else if(QRE_Left <= White && QRE_Right <= White && inches >= TargetDist){  //Both sensors see white --> line is between sensors

    Serial.println("Drive Normal");

      Motor1->setSpeed(motorspeedFULL);
  	  Motor1->run(FORWARD);
      Motor2->setSpeed(motorspeedFULL);
  	  Motor2->run(FORWARD);

      Motor3->setSpeed(motorspeedFULL);
  	  Motor3->run(FORWARD);
      Motor4->setSpeed(motorspeedFULL);
  	  Motor4->run(FORWARD);

      noTone(buzzer);

  } else if (QRE_Left == Grey && QRE_Right == Grey && inches >= TargetDist){  //Both sensors see Black --> Entering the target)

    Serial.println("Entering Target");

    Motor1->setSpeed(motorspeedFULL);
  	  Motor1->run(FORWARD);
      Motor2->setSpeed(motorspeedFULL);
  	  Motor2->run(FORWARD);

      Motor3->setSpeed(motorspeedFULL);
  	  Motor3->run(FORWARD);
      Motor4->setSpeed(motorspeedFULL);
  	  Motor4->run(FORWARD);

  } else if(inches <= TargetDist){         //Sonar sensor sees wall

    Serial.println("Stop");

      Motor1->setSpeed(motorspeedBRAKE);
  	  Motor1->run(FORWARD);
      Motor2->setSpeed(motorspeedBRAKE);
  	  Motor2->run(FORWARD);

      Motor3->setSpeed(motorspeedBRAKE);
  	  Motor3->run(FORWARD);
      Motor4->setSpeed(motorspeedBRAKE);
  	  Motor4->run(FORWARD);

      tone(buzzer, 1000);
  }

}

//Transform ping values into a meaningful distance --> https://www.bananarobotics.com/shop/HC-SR04-Ultrasonic-Distance-Sensor#:~:text=The%20easy%20way%20to%20read,centimeters%20or%20about%201.7%20centimeters.
long microsecondsToInches(long microseconds) {
   return microseconds / 74 / 2;
}

long microsecondsToCentimeters(long microseconds) {
   return microseconds / 29 / 2;
}

