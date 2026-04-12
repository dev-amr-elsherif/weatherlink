#define BLYNK_TEMPLATE_ID "TMPL5VFL4RHih"
#define BLYNK_TEMPLATE_NAME "Weather Monitor"
#define BLYNK_AUTH_TOKEN "QTbml8OyLxCcCqRNFZ9Xh9Nw5cqy2Mll"

#define BLYNK_PRINT Serial
#include <WiFi.h>
#include <WiFiClient.h>
#include <BlynkSimpleEsp32.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <DHT.h>

char ssid[] = "Wokwi-GUEST";
char pass[] = "";

// ================= Sensor Pins =================
#define I2C_SDA 8
#define I2C_SCL 9
#define DHTPIN 15
#define DHTTYPE DHT22 
#define RAIN_PIN 4    
#define LIGHT_PIN 16

// ================= Control Pins =================
#define AWNING_PIN 5        // Awning
#define FAN_PIN 6           // Fan
#define OUTDOOR_LIGHT_PIN 7 // Outdoor Light

// ================= OLED Configuration =================
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

DHT dht(DHTPIN, DHTTYPE);
BlynkTimer timer;

// Default Mode: Auto
bool isAutoMode = true; 

// ================= Manual Control =================
// Auto/Manual Toggle (V7)
BLYNK_WRITE(V7) {
  isAutoMode = param.asInt();
  Serial.print("System Mode Changed to: "); 
  Serial.println(isAutoMode ? "AUTO" : "MANUAL");
}

// Manual Overrides
BLYNK_WRITE(V4) { if(!isAutoMode) digitalWrite(AWNING_PIN, param.asInt()); }
BLYNK_WRITE(V5) { if(!isAutoMode) digitalWrite(FAN_PIN, param.asInt()); }
BLYNK_WRITE(V6) { if(!isAutoMode) digitalWrite(OUTDOOR_LIGHT_PIN, param.asInt()); }

// ================= Edge Logic & Sensor Reading =================
void processAndSendData() {
  float t = dht.readTemperature();
  float h = dht.readHumidity();
  int r_raw = analogRead(RAIN_PIN);
  int r = map(r_raw, 0, 4095, 100, 0); // Rain percentage
  int l = digitalRead(LIGHT_PIN); // 0 = Day, 1 = Night

  if (isnan(h) || isnan(t)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  // 1. Send Data to App
  Blynk.virtualWrite(V0, t); 
  Blynk.virtualWrite(V1, h); 
  Blynk.virtualWrite(V2, r); 
  Blynk.virtualWrite(V3, (l == 0 ? 255 : 0)); 

  // 2. Edge Computing Logic (Auto Mode)
  if (isAutoMode) {
    // Awning logic: close if rain > 60%
    int awningState = (r > 60) ? HIGH : LOW;
    digitalWrite(AWNING_PIN, awningState);
    Blynk.virtualWrite(V4, awningState); 

    // Fan logic: turn on if temp > 30
    int fanState = (t > 30.0) ? HIGH : LOW;
    digitalWrite(FAN_PIN, fanState);
    Blynk.virtualWrite(V5, fanState); 

    // Light logic: turn on if night
    int lightState = (l == 1) ? HIGH : LOW;
    digitalWrite(OUTDOOR_LIGHT_PIN, lightState);
    Blynk.virtualWrite(V6, lightState); 
  }

  // 3. OLED Display Update
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  
  display.setCursor(0, 0);
  display.print("Temp: "); display.print(t, 1); display.print(" C");
  
  display.setCursor(0, 16);
  display.print("Humidity: "); display.print(h, 1); display.print(" %");
  
  display.setCursor(0, 32);
  display.print("Rain: "); display.print(r); display.print(" %");
  
  display.setCursor(0, 48);
  display.print("Light: "); display.print(l == 0 ? "High (Day)" : "Low (Night)");
  
  display.display();
}

void setup() {
  Serial.begin(115200);
  
  pinMode(LIGHT_PIN, INPUT_PULLUP);
  pinMode(AWNING_PIN, OUTPUT);
  pinMode(FAN_PIN, OUTPUT);
  pinMode(OUTDOOR_LIGHT_PIN, OUTPUT);
  
  digitalWrite(AWNING_PIN, LOW);
  digitalWrite(FAN_PIN, LOW);
  digitalWrite(OUTDOOR_LIGHT_PIN, LOW);
  
  Wire.begin(I2C_SDA, I2C_SCL);
  
  // Initialize OLED
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("SSD1306 allocation failed");
    for(;;); // Don't proceed, loop forever
  }
  display.clearDisplay();
  display.display();

  dht.begin();

  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);
  timer.setInterval(2000L, processAndSendData); 
  
  Blynk.virtualWrite(V7, 1); 
}

void loop() {
  Blynk.run(); 
  timer.run(); 
}