# WeatherLink
### Intelligent Hybrid Edge-Computing & Smart Home IoT Dashboard

[![Download APK](https://img.shields.io/badge/Download_APK-v1.0.0-success)](https://github.com/dev-amr-elsherif/weatherlink/releases/download/v1.0.0/app-release.apk)

## 🏗 Core Architecture: The Hybrid Edge-Computing Model

WeatherLink transcends traditional cloud-dependent IoT solutions by introducing a robust **Hybrid Edge-Computing architecture**. This paradigm drastically minimizes latency, optimizes bandwidth, and most importantly, guarantees absolute operational continuity during network outages.

* **Autonomous Edge Intelligence (Auto Mode):** The ESP32-S3 microcontroller acts as a localized orchestrator rather than a simple telemetry relayer. Critical automation logic is computed directly on the edge. If the analog rain sensor detects a sudden downpour (>60%), the ESP32 instantaneously triggers the smart awning to retract. If ambient temperatures breach 30°C, the exhaust fan is fully engaged. The logic executes completely independently of internet stability.
* **Direct Remote Control (Manual Mode):** When precision control is demanded, the mobile application can bypass the autonomous logic. Toggling "Auto Mode" off transforms the Flutter application into a low-latency remote control, mapping UI interactions directly to the hardware relays for uninhibited manual override.
* **Cloud Brokerage:** Operating in the middle layer, the Blynk IoT Cloud leverages asynchronous bidirectional communication (Virtual Pins V0 to V7) to synchronize system states between the hardware edge hub and the mobile client, enabling zero-delay polling and reliable dashboard updates.

## ✨ Key Features

### Edge Node (Hardware Intelligence)
* **Mission-Critical Automations:** Hardcoded, threshold-based logic guarantees reliable hardware response to environmental shifts.
* **Precision Telemetry Acquisition:** Continuous data streaming for Temperature, Humidity, Real-Time Precipitation, and Ambient Illuminance.
* **Multi-Relay Actuation Mastery:** Safe, unified management of heavy-duty appliances, including Motorized Awnings, HVAC Exhaust Fans, and Exterior Lighting Networks.

### Smart Hub Application
* **Zero-Delay Telemetry Sync:** State-of-the-art data synchronization leveraging `provider` for deeply reactive state management.
* **Adaptive "Glassmorphism Lite" User Interface:** A highly polished, dynamic aesthetic running on Material 3. The primary Hero Section intrinsically reacts to real-time ambient light data, seamlessly shifting its gradient background through contextual states (Bright, Dim, Dark).
* **Proactive System Alerts:** Context-aware event broadcasting dynamically injects critical alerts directly into the UI (e.g., `ALERT: HEAVY RAIN`, `HIGH TEMP WARNING`), preemptively informing the user of the system's edge operations.
* **Frictionless Mode Toggling:** Sub-millisecond transition between AI-driven auto execution and manual system override.

## 🛠 Tech Stack

* **Client Application:** Flutter (Dart, Material 3)
* **Application Architecture:** Feature-Driven Development, MVC Architectural Pattern, Provider State Management
* **Edge Processing:** ESP32-S3 Microcontroller (Wokwi Simulated Environment)
* **IoT Backend Broker:** Blynk IoT Cloud (REST API / WiFiClient)
* **Hardware Sensors:** DHT22 (Climate), Analog Rain Sensor (Precipitation), LDR (Luminosity)

## ⚙️ Hardware Wiring & Logic Mapping

The ESP32-S3 acts as the primary computation node, interfacing with peripherals to control the corresponding actuators based on hardcoded threshold configurations:

### Telemetry Subsystem (Sensors)
* **DHT22 Interfacing:** Captures complex ambient climate metrics (Temperature & Humidity).
* **Analog Rain Sensor:** Translates water droplet volume into a measurable precipitation percentage.
* **LDR Array:** Actively profiles ambient luminosity.

### Actuator Control Mapping (Relays)
* **Pin 5 - Smart Awning Node:**
  * *Edge Logic:* Engages retraction mechanism if active Precipitation > 60%.
* **Pin 6 - Exhaust Fan Node:**
  * *Edge Logic:* Activates climate mitigation if ambient Temperature > 30°C.
* **Pin 7 - Exterior Illumination Node:**
  * *Edge Logic:* Triggers exterior lighting arrays if LDR detects Dark ambient conditions.

## 🚀 Getting Started

Deploying the WeatherLink Smart Hub locally is streamlined. Follow these instructions to compile the Flutter application and connect it to your provisioned hardware nodes.

### Prerequisites
* Flutter SDK (v3.19.0 or higher recommended)
* Dart SDK
* Integrated Development Environment (Android Studio / VS Code) with Flutter extensions installed
* An active and configured [Blynk IoT](https://blynk.io/) profile and corresponding authentication token

### Installation Strategy

1. **Clone the Repository**
   Initialize the local workspace by pulling down the latest production branch:
   ```bash
   git clone https://github.com/yourusername/weatherlink.git
   cd weatherlink
   ```

2. **Resolve Dependencies**
   Pull the dart packages required for compilation:
   ```bash
   flutter pub get
   ```

3. **Inject Environment Variables**
   Locate the Blynk connection configuration logic within the application state and populate it with your specific provisioned device credentials:
   ```dart
   const String blynkAuthToken = 'YOUR_BLYNK_AUTH_TOKEN_HERE';
   const String blynkCloudServer = 'blynk.cloud'; 
   ```

4. **Initialize Compilation**
   Mount your testing device or initialize a local emulator, then execute the deployment:
   ```bash
   flutter run
   ```
