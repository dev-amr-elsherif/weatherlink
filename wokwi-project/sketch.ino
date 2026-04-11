#define BLYNK_TEMPLATE_ID "TMPL5VFL4RHih"
#define BLYNK_TEMPLATE_NAME "Weather Monitor"
#define BLYNK_AUTH_TOKEN "QTbml8OyLxCcCqRNFZ9Xh9Nw5cqy2Mll"

#define BLYNK_PRINT Serial
#include <WiFi.h>
#include <WiFiClient.h>
#include <BlynkSimpleEsp32.h>
#include <LiquidCrystal_I2C.h>
#include <Wire.h>
#include <DHT.h>

char ssid[] = "Wokwi-GUEST";
char pass[] = "";

// ================= أطراف الحساسات =================
#define I2C_SDA 8
#define I2C_SCL 9
#define DHTPIN 15
#define DHTTYPE DHT22 
#define RAIN_PIN 4    
#define LIGHT_PIN 16

// ================= أطراف التحكم =================
#define AWNING_PIN 5        // التندة
#define FAN_PIN 6           // المروحة
#define OUTDOOR_LIGHT_PIN 7 // الإضاءة

LiquidCrystal_I2C lcd(0x27, 16, 2);
DHT dht(DHTPIN, DHTTYPE);
BlynkTimer timer;

// المتغير السحري (الوضع الافتراضي: تلقائي)
bool isAutoMode = true; 

// ================= أوامر الاستقبال من التطبيق (Manual Control) =================
// زرار تفعيل أو إيقاف الوضع التلقائي (V7)
BLYNK_WRITE(V7) {
  isAutoMode = param.asInt();
  Serial.print("⚙️ System Mode Changed to: "); Serial.println(isAutoMode ? "AUTO" : "MANUAL");
}

// التحكم اليدوي (بيشتغل بشكل سليم لو الـ Auto مقفول، أو بيعمل Override مؤقت)
BLYNK_WRITE(V4) { if(!isAutoMode) digitalWrite(AWNING_PIN, param.asInt()); }
BLYNK_WRITE(V5) { if(!isAutoMode) digitalWrite(FAN_PIN, param.asInt()); }
BLYNK_WRITE(V6) { if(!isAutoMode) digitalWrite(OUTDOOR_LIGHT_PIN, param.asInt()); }

// ================= مخ النظام (Edge Logic & Sensor Reading) =================
void processAndSendData() {
  float t = dht.readTemperature();
  float h = dht.readHumidity();
  int r_raw = analogRead(RAIN_PIN);
  int r = map(r_raw, 0, 4095, 100, 0); // نسبة المطر
  int l = digitalRead(LIGHT_PIN); // 0 = نهار, 1 = ليل (حسب توصيل الـ LDR)

  if (isnan(h) || isnan(t)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  // 1. إرسال القراءات للتطبيق
  Blynk.virtualWrite(V0, t); 
  Blynk.virtualWrite(V1, h); 
  Blynk.virtualWrite(V2, r); 
  Blynk.virtualWrite(V3, (l == 0 ? 255 : 0)); 

  // 2. الحوسبة الطرفية (Edge Computing Logic) - بيشتغل لو الـ Auto مفعل
  if (isAutoMode) {
    // منطق التندة: لو المطر أكتر من 60% اقفل التندة، غير كده افتحها
    int awningState = (r > 60) ? HIGH : LOW;
    digitalWrite(AWNING_PIN, awningState);
    Blynk.virtualWrite(V4, awningState); // نحدث زرار التطبيق عشان المستخدم يشوف إنها اتقفلت

    // منطق المروحة: لو الحرارة أكتر من 30 شغل الشفاط/المروحة
    int fanState = (t > 30.0) ? HIGH : LOW;
    digitalWrite(FAN_PIN, fanState);
    Blynk.virtualWrite(V5, fanState); // نحدث التطبيق

    // منطق الإضاءة: لو ليل شغل النور (لنفترض 1 يعني ليل في الـ LDR ده)
    int lightState = (l == 1) ? HIGH : LOW;
    digitalWrite(OUTDOOR_LIGHT_PIN, lightState);
    Blynk.virtualWrite(V6, lightState); // نحدث التطبيق
  }

  // طباعة على الشاشة
  lcd.setCursor(0, 0);
  lcd.print("T:"); lcd.print(t, 1); lcd.print("C L:");
  lcd.print(l == 0 ? "High" : "Low ");
  lcd.setCursor(0, 1);
  lcd.print("H:"); lcd.print(h, 1); lcd.print("% R:");
  lcd.print(r); lcd.print("% ");
}

void setup() {
  Serial.begin(115200);
  
  pinMode(LIGHT_PIN, INPUT_PULLUP);
  pinMode(AWNING_PIN, OUTPUT);
  pinMode(FAN_PIN, OUTPUT);
  pinMode(OUTDOOR_LIGHT_PIN, OUTPUT);
  
  // الحالة الابتدائية
  digitalWrite(AWNING_PIN, LOW);
  digitalWrite(FAN_PIN, LOW);
  digitalWrite(OUTDOOR_LIGHT_PIN, LOW);
  
  Wire.begin(I2C_SDA, I2C_SCL);
  lcd.init();
  lcd.backlight();
  dht.begin();

  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);
  timer.setInterval(2000L, processAndSendData); // تحديث كل ثانيتين
  
  // إخبار التطبيق إننا بدأنا على وضع الـ Auto
  Blynk.virtualWrite(V7, 1); 
}

void loop() {
  Blynk.run(); 
  timer.run(); 
}