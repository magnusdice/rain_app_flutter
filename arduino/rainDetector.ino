#include <LiquidCrystal_I2C.h>
#include <Wire.h>
#include <Servo.h>
#include "DHT.h"
#define DHTPIN D7
#define DHTTYPE DHT11
#define sensorPin D5

#include <Arduino.h>
#if defined(ESP32)
  #include <WiFi.h>
#elif defined(ESP8266)
  #include <ESP8266WiFi.h>
#endif

#include <Firebase_ESP_Client.h>
DHT dht (DHTPIN, DHTTYPE);
Servo servo;

//Provide Token
#include "addons/TokenHelper.h"
//Provide RTDB payload
#include "addons/RTDBHelper.h"

//Network Credentials
#define WIFI_SSID "iPhone (2)"
#define WIFI_PASSWORD "magnus9999"

//Insert Firebase project API key
#define API_KEY "AIzaSyCOH4kOoNlb3_S5VEynk-_lY3D57O9m8qc"

//RTDB URL
#define DATABASE_URL "iotrainproject-ecadb-default-rtdb.asia-southeast1.firebasedatabase.app/"

//Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

bool signupOK = false;
int pos = 0;
int sensorValue = 0;
bool boolValue;
bool autoValue;
bool switchState;

void setup(){   
  pinMode(DHTPIN, INPUT);
  dht.begin();
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("ok");
    signupOK = true;
  }
  else{
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  servo.attach(2,500,2400); //D3 // d4 =2
  delay(2000);

}

void loop(){
  
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  sensorValue = analogRead(A0);
  Serial.println(sensorValue);
  

  if (Firebase.ready() && signupOK ) {
    
    if (Firebase.RTDB.setFloat(&fbdo, "DHThum/hum",h)){
//      Serial.println("PASSED");
       Serial.print("Humidity: ");
       Serial.println(h);
      
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    }
    
    
    // Write an Float number on the database path test/float
    if (Firebase.RTDB.setFloat(&fbdo, "DHTTemp/temp", t)){
//      Serial.println("PASSED");
       Serial.print("Temperature: ");
       Serial.println(t);
    }
    else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    }

    if(Firebase.RTDB.setFloat(&fbdo, "Sensor/Rain",sensorValue)){
      Serial.print("Rain: ");
      Serial.println(sensorValue);
    } else {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
    }

    if(Firebase.RTDB.getBool(&fbdo,"switch/switch")){
      if(fbdo.dataTypeEnum() == fb_esp_rtdb_data_type_boolean){
        boolValue = fbdo.boolData();
        Serial.println(boolValue);

      } else {
        Serial.println(fbdo.errorReason());
      }
    }

    if(Firebase.RTDB.getBool(&fbdo, "auto/auto")){
      if(fbdo.dataTypeEnum()== fb_esp_rtdb_data_type_boolean){
        autoValue = fbdo.boolData();
        Serial.println(autoValue);
      } else{
        Serial.println(fbdo.errorReason());
      }
    }

    Serial.println("Test");
    Serial.println(boolValue);

    if(autoValue == 0){
      Serial.println("Automatic Enable");
      if(sensorValue > 800){
        servo.write(180);
        Serial.println("Auto Close");

      }else{
        servo.write(-200);
        Serial.println("Auto Open");
      }

    } else {
      Serial.println("Manual Enable");
      if(boolValue == 0){
        servo.write(180);
        Serial.println("Manual Open");
      } else {
        servo.write(-200);
        Serial.println("Manual Close");
      }

    }

    
    delay(10);

    // if(boolValue == 0){
    //   for(pos = 0; pos <=180; pos ++){
    //     servo.write(pos);
    //     delay(15);
        
    //     if (pos == 180){
    //       break;
    //     }
    //   }
    //   Serial.println("Open Door");
    // } else {
    //   for(pos = 180;pos >=1;pos--){
    //     servo.write(pos);
    //     delay(15);
    //     if (pos ==0){
    //       break;
    //     }
    //   }
    //   Serial.println("Close Door");
    // }


    


  Serial.println("______________________________");
  
  // servo.write(0); //angle 90 degree
  // delay(1000);
  // servo.write(0);
  // delay(1000);
  }
}
