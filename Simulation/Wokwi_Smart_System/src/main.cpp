#include <Arduino.h> // Required for PlatformIO to work properly

// ================= Blynk Application Settings =================
// These details connect your hardware to your specific Blynk project
#define BLYNK_TEMPLATE_ID "TMPL5VFL4RHih"
#define BLYNK_TEMPLATE_NAME "Weather Monitor"
#define BLYNK_AUTH_TOKEN "QTbml8OyLxCcCqRNFZ9Xh9Nw5cqy2Mll"
#define BLYNK_PRINT Serial

// ================= Libraries =================
#include <WiFi.h>              // Connects the board to WiFi
#include <WiFiClient.h>        // Helps manage the WiFi connection
#include <BlynkSimpleEsp32.h>  // Connects the board to the Blynk App
#include <Wire.h>              // Required for the OLED screen communication (I2C)
#include <Adafruit_GFX.h>      // Graphics library for the OLED screen
#include <Adafruit_SSD1306.h>  // Specific library for your SSD1306 OLED screen
#include <DHT.h>               // Library for the Temperature/Humidity sensor
#include <ESP32Servo.h>        // Library to control the Servo motor
#include <Adafruit_NeoPixel.h> // Library to control the Smart Light Ring

// ================= WiFi Credentials =================
// Using Wokwi's virtual WiFi for the simulation
char ssid[] = "Wokwi-GUEST";
char pass[] = "";

// ================= Pin Definitions =================
// Here we tell the brain (ESP32) which component is connected to which pin
#define RAIN_PIN 4  // Rain sensor (Analog input)
#define SERVO_PIN 5 // Awning motor (PWM output)
#define DHTPIN 6    // Temperature and Humidity sensor
#define LDR_PIN 7   // Light sensor (Analog input to check if it's day or night)
#define PIR_PIN 8   // Motion sensor (Digital input to check for movement)
#define FAN_PIN 9   // Fan motor (PWM output for speed control)
#define I2C_SDA 10  // OLED Screen Data pin
#define I2C_SCL 11  // OLED Screen Clock pin
#define NEO_PIN 12  // Smart Light Ring (NeoPixel) pin
// Note: SWITCH_PIN has been completely removed as requested!

// ================= Component Setup =================
// 1. Temperature Sensor Setup
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// 2. Servo Motor Setup
Servo awningServo;

// 3. Smart Lights Setup (16 LEDs in the ring)
#define NUMPIXELS 16
Adafruit_NeoPixel strip(NUMPIXELS, NEO_PIN, NEO_GRB + NEO_KHZ800);

// 4. OLED Screen Setup (Size: 128x64 pixels)
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
TwoWire I2C_OLED = TwoWire(0);
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &I2C_OLED, -1);

// ================= System Variables =================
// This tells the system to start in "Auto Mode" by default
bool isAutoMode = true;

// Variables to store the current readings from sensors
float currentTemp = 0.0; // Current Temperature
float currentHum = 0.0;  // Current Humidity
int currentRain = 0;     // Current Rain Level (%)
int currentLDR = 0;      // Current Light Level (0 to 4095)

// Variables to store the manual commands coming from the Blynk App
int manualAwningState = 0; // Value from the Awning slider
int manualFanState = 0;    // Value from the Fan slider
int manualLightState = 0;  // Value from the Lights slider

// Timing variables (We use these instead of "delay" to prevent the system from freezing)
unsigned long lastSensorReadTime = 0;    // Remembers the last time we read sensors
unsigned long motionTimer = 0;           // Keeps track of time when motion stops
const unsigned long turnOffDelay = 5000; // Wait 5 seconds before turning off lights
bool isLightOn = false;                  // Is the light currently on?
bool isCountingDown = false;             // Are we currently counting down the 5 seconds?

// ================= Blynk App Controls =================

// 1. Auto/Manual Switch from the App (Virtual Pin V7)
BLYNK_WRITE(V7)
{
  isAutoMode = param.asInt(); // 1 means Auto, 0 means Manual
  Serial.print("Blynk App changed mode to: ");
  Serial.println(isAutoMode ? "AUTO" : "MANUAL");
}

// 2. Manual Sliders from the App (These only control the system if we are in Manual Mode)
BLYNK_WRITE(V4) { manualAwningState = param.asInt(); } // Awning Slider (0 to 100)
BLYNK_WRITE(V5) { manualFanState = param.asInt(); }    // Fan Slider (0 to 255)
BLYNK_WRITE(V6) { manualLightState = param.asInt(); }  // Lights Slider (0 to 8)

// ================= Function Prototypes =================
// This is like a table of contents, telling the code these functions exist below
void readSensors();
void updateDisplay();
void sendToBlynk();
void runSmartAutoLogic();
void runManualLogic();
void updateSmartLights(int ldrVal);

// ================= Initialization (Setup) =================
// This runs only ONCE when the device is turned on
void setup()
{
  Serial.begin(115200); // Start communication with the computer for debugging

  // Set up the pins as Inputs (reading) or Outputs (sending power)
  pinMode(PIR_PIN, INPUT);
  pinMode(FAN_PIN, OUTPUT);

  // Start the Awning motor and set it to fully open (1000)
  awningServo.attach(SERVO_PIN);
  awningServo.writeMicroseconds(1000);

  // Start the Smart Lights and make sure they are turned off
  strip.begin();
  strip.show();

  // Start the OLED Screen
  I2C_OLED.begin(I2C_SDA, I2C_SCL, 400000);
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C))
  {
    Serial.println("OLED Screen Failed to start!");
  }
  display.clearDisplay(); // Clear the screen
  display.display();

  // Start the Temperature Sensor
  dht.begin();

  // Connect to the internet and the Blynk App
  Serial.println("Connecting to Blynk...");
  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);

  // Tell the Blynk App to switch its button to "Auto" when the device starts
  Blynk.virtualWrite(V7, 1);

  Serial.println("System is Ready!");
}

// ================= Main Loop =================
// This runs continuously, over and over, very fast
void loop()
{
  Blynk.run(); // Keep the connection with the App alive

  // 1. Read sensors and update everything every 2 seconds (2000 milliseconds)
  if (millis() - lastSensorReadTime >= 2000)
  {
    lastSensorReadTime = millis(); // Reset the timer

    readSensors();   // Go get the latest data from the physical sensors
    updateDisplay(); // Show the new data on the OLED screen
    sendToBlynk();   // Send the new data to the Blynk App to update the gauges
  }

  // 2. Decide who is the boss: The Smart Auto Logic or The Manual App Logic?
  if (isAutoMode)
  {
    runSmartAutoLogic(); // Let the sensors make the decisions
  }
  else
  {
    runManualLogic(); // Let the user's sliders on the app make the decisions
  }
}

// ================= Function 1: Read the Sensors =================
void readSensors()
{
  // Read Temperature and Humidity
  float t = dht.readTemperature();
  float h = dht.readHumidity();

  // If the sensor gave a real number, save it
  if (!isnan(t) && !isnan(h))
  {
    currentTemp = t;
    currentHum = h;
  }

  // Read Rain Sensor (ESP32 gives a number from 0 to 4095)
  int rainRaw = analogRead(RAIN_PIN);
  // Convert that raw number into a percentage from 0% to 100%
  currentRain = map(rainRaw, 0, 4095, 0, 100);
  // Make sure the percentage never goes below 0 or above 100
  currentRain = constrain(currentRain, 0, 100);

  // Read the Light Sensor (0 to 4095)
  currentLDR = 4095 - analogRead(LDR_PIN);
}

// ================= Function 2: Update the OLED Screen =================
void updateDisplay()
{
  display.clearDisplay();              // Erase old text
  display.setTextSize(1);              // Set text size
  display.setTextColor(SSD1306_WHITE); // Set text color

  // Print Temperature
  display.setCursor(0, 0);
  display.print("Temp: ");
  display.print(currentTemp, 1);
  display.print(" C");

  // Print Humidity
  display.setCursor(0, 16);
  display.print("Hum:  ");
  display.print(currentHum, 1);
  display.print(" %");

  // Print Rain Percentage
  display.setCursor(0, 32);
  display.print("Rain: ");
  display.print(currentRain);
  display.print(" %");

  // Print Current Mode (Auto or Manual)
  display.setCursor(0, 48);
  display.print("Mode: ");
  display.print(isAutoMode ? "AUTO (Smart)" : "MANUAL (App)");

  display.display(); // Push the text to the actual screen
}

// ================= Function 3: Send Data to the Blynk App =================
void sendToBlynk()
{
  Blynk.virtualWrite(V0, currentTemp); // Update Temperature Gauge
  Blynk.virtualWrite(V1, currentHum);  // Update Humidity Gauge
  Blynk.virtualWrite(V2, currentRain); // Update Rain Gauge
  Blynk.virtualWrite(V3, currentLDR);  // Update Light Sensor Gauge (0 to 4095)
}

// ================= Function 4: The Smart Brain (Auto Logic) =================
// This runs only if the system is in Auto Mode
void runSmartAutoLogic()
{
  // --------- A. Awning (Roof) Logic ---------
  int pulseWidth = 1000; // 1000 means fully open

  if (currentRain <= 40)
  {
    pulseWidth = 1000; // Light rain or no rain -> Keep fully open
  }
  else if (currentRain > 40 && currentRain < 65)
  {
    // Medium rain -> Close it slowly depending on how hard it's raining
    pulseWidth = map(currentRain, 41, 64, 1000, 1500);
  }
  else
  {
    pulseWidth = 2000; // Heavy rain -> Close it completely (2000)
  }
  awningServo.writeMicroseconds(pulseWidth); // Send the command to the motor

  // --------- B. Fan Logic ---------
  int fanSpeed = 0; // 0 means turned off

  if (currentTemp < 25.0)
  {
    fanSpeed = 0; // Cool weather -> Keep fan off
  }
  else if (currentTemp >= 25.0 && currentTemp < 29.0)
  {
    fanSpeed = 150; // Warm weather -> Turn fan on medium speed

    // Emergency: If it's warm AND very humid, turn fan to maximum speed (255)
    if (currentTemp >= 28.0 && currentHum > 75.0)
      fanSpeed = 255;
  }
  else
  {
    fanSpeed = 255; // Hot weather -> Turn fan to maximum speed
  }
  analogWrite(FAN_PIN, fanSpeed); // Send the power to the fan

  // --------- C. Smart Lights Logic ---------
  int motion = digitalRead(PIR_PIN); // Check if someone is moving

  if (motion == HIGH) // If someone is moving...
  {
    isLightOn = true;
    isCountingDown = false;        // Stop any countdown
    updateSmartLights(currentLDR); // Turn on lights based on how dark it is
  }
  else // If nobody is moving...
  {
    if (isLightOn) // If the lights are currently on
    {
      if (!isCountingDown)
      {
        // Start the 5-second countdown timer
        isCountingDown = true;
        motionTimer = millis();
      }

      // If the 5 seconds have NOT finished yet...
      if (millis() - motionTimer < turnOffDelay)
      {
        updateSmartLights(currentLDR); // Keep the lights on
      }
      else // If the 5 seconds are finished...
      {
        // Turn everything off
        isLightOn = false;
        isCountingDown = false;
        strip.clear();
        strip.show();
      }
    }
    else // If lights are already off, make sure they stay off
    {
      strip.clear();
      strip.show();
    }
  }
}

// ================= Function 5: The App Control (Manual Logic) =================
// This runs only if the system is in Manual Mode
void runManualLogic()
{
  // --------- 1. Awning (Roof) ---------
  // V4 from the app gives us a slider percentage (0 to 100)
  // We convert this percentage into a motor signal (1000 = open, 2000 = closed)
  int pulseWidth = map(manualAwningState, 0, 100, 1000, 2000);
  awningServo.writeMicroseconds(pulseWidth);

  // --------- 2. Fan ---------
  // V5 from the app gives us a slider value (0 to 255)
  // This value is exactly what the fan needs for its speed
  analogWrite(FAN_PIN, manualFanState);

  // --------- 3. Smart Lights ---------
  // V6 from the app gives us a slider value (0 to 8)
  strip.clear(); // Turn off all LEDs first

  // This loop turns on the LEDs symmetrically (left and right sides together)
  // It turns on as many pairs as the slider tells it to
  for (int i = 0; i < manualLightState; i++)
  {
    strip.setPixelColor(i, strip.Color(255, 255, 255));      // Turn on one LED on the right (White color)
    strip.setPixelColor(15 - i, strip.Color(255, 255, 255)); // Turn on the matching LED on the left (White color)
  }
  strip.show(); // Push the changes to the physical LED ring
}

// ================= Helper Function: Smooth Lighting =================
// This calculates how many LEDs to turn on based on how dark it is
void updateSmartLights(int ldrVal)
{
  // If the light sensor reads more than 2000, it means it is Daytime
  if (ldrVal > 2000)
  {
    strip.clear(); // Keep all lights off in the morning
  }
  else // It is Nighttime or Dark
  {
    // The darker it is (closer to 0), the more LEDs we turn on (up to 8 pairs)
    int spread = map(ldrVal, 2000, 0, 1, 8);
    spread = constrain(spread, 1, 8); // Make sure it stays between 1 and 8

    // The darker it is, the more the color shifts from dim Blue to bright White
    int gColor = map(ldrVal, 2000, 0, 150, 255); // Green color amount
    int bColor = map(ldrVal, 2000, 0, 50, 255);  // Blue color amount

    strip.clear();
    // Turn on the LEDs symmetrically based on the calculated 'spread'
    for (int i = 0; i <= spread; i++)
    {
      strip.setPixelColor(i, strip.Color(255, gColor, bColor));
      strip.setPixelColor((16 - i) % 16, strip.Color(255, gColor, bColor));
    }
  }
  strip.show(); // Push the changes to the physical LED ring
}