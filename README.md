# 📱 Car Controller App (Flutter)

A modern **Flutter mobile app** for controlling a car or robotic vehicle over Wi-Fi.  
This app sends HTTP commands to a target device (such as a microcontroller or IoT board) that hosts a local web server.

---

## ⚙️ Features

- 🚗 **Directional Controls:** Forward, Backward, Left, Right, and Stop  
- ⚙️ **Speed Selection:** Choose from preset speed levels (100, 150, 200, 255)  
- 🎯 **Servo Steering Control:** Adjust steering angle (0°–180°) via slider or quick buttons  
- 🛑 **Emergency Stop Button**  
- 🌐 **Custom IP Input:** Connect to any device hosting a Wi-Fi server (default `192.168.4.1`)  
- 🔁 **Hold-to-Move Control:** Continuous commands while buttons are pressed  
- 💡 **Offline Operation:** Works on local Wi-Fi — no internet required  

---

## 🧩 Files

| File | Description |
|------|-------------|
| `lib/main.dart` | Main Flutter app source code |
| `pubspec.yaml` | Flutter dependencies and project configuration |

---

## 🛠️ Requirements

- **Flutter SDK** (latest stable version)  
- **Dart SDK** (comes with Flutter)  
- **Dependencies:**
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    http: ^0.13.6
