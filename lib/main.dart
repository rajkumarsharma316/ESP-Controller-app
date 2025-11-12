import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const Esp8266CarApp());
}

class Esp8266CarApp extends StatelessWidget {
  const Esp8266CarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP8266 Car Controller',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      debugShowCheckedModeBanner: false,
      home: const ControllerPage(),
    );
  }
}

class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key});

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  String host = "192.168.4.1";
  int port = 80;
  int speed = 175;
  int servoAngle = 90;
  String status = "Ready";

  String lastCommand = "";
  bool isSending = false;

  String get baseUrl => "http://$host:$port";

  Future<void> sendCommand(String path) async {
    if (isSending || path == lastCommand) return;
    isSending = true;
    lastCommand = path;
    try {
      final url = Uri.parse("$baseUrl$path");
      final resp = await http.get(url).timeout(const Duration(seconds: 1));
      setState(() => status = "${path.split('?').first} → ${resp.statusCode}");
    } catch (e) {
      setState(() => status = "Error: $e");
    } finally {
      isSending = false;
    }
  }

  void stopCar() {
    sendCommand("/stop");
    lastCommand = "";
  }

  void handleJoystickMove(double x, double y) {
    String cmd = "/stop";
    if (x.abs() < 0.2 && y.abs() < 0.2) {
      stopCar();
      return;
    }

    if (y < -0.4 && x.abs() < 0.3) cmd = "/forward";
    else if (y > 0.4 && x.abs() < 0.3) cmd = "/backward";
    else if (x < -0.4 && y.abs() < 0.3) cmd = "/left";
    else if (x > 0.4 && y.abs() < 0.3) cmd = "/right";
    else if (y < -0.4 && x < -0.4) cmd = "/forwardleft";
    else if (y < -0.4 && x > 0.4) cmd = "/forwardright";
    else if (y > 0.4 && x < -0.4) cmd = "/backwardleft";
    else if (y > 0.4 && x > 0.4) cmd = "/backwardright";

    sendCommand(cmd);
  }

  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.of(context).size.height;
    final double joystickSize = screenH * 0.7;

    return Scaffold(
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ===== JOYSTICK SIDE =====
            Expanded(
              flex: 3,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  transform: Matrix4.identity()
                    ..scale(1.05)
                    ..translate(0.0, -4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      radius: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.5),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  width: joystickSize,
                  height: joystickSize,
                  child: Joystick(
                    mode: JoystickMode.all,
                    listener: (details) => handleJoystickMove(details.x, details.y),
                    onStickDragEnd: stopCar,
                  ),
                ),
              ),
            ),

            // ===== SLIDER SIDE =====
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Two vertical sliders side by side
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Speed slider
                      Column(
                        children: [
                          RotatedBox(
                            quarterTurns: -1,
                            child: SizedBox(
                              width: 200,
                              child: Slider(
                                value: speed.toDouble(),
                                min: 0,
                                max: 255,
                                divisions: 51,
                                activeColor: Colors.blueAccent,
                                label: "Speed $speed",
                                onChanged: (v) => setState(() => speed = v.toInt()),
                                onChangeEnd: (v) => sendCommand("/speed?value=${v.toInt()}"),
                              ),
                            ),
                          ),
                          Text("Speed: $speed", style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(width: 30),

                      // Servo slider
                      Column(
                        children: [
                          RotatedBox(
                            quarterTurns: -1,
                            child: SizedBox(
                              width: 200,
                              child: Slider(
                                value: servoAngle.toDouble(),
                                min: 0,
                                max: 180,
                                divisions: 180,
                                activeColor: Colors.orangeAccent,
                                label: "Angle $servoAngle°",
                                onChanged: (v) => setState(() => servoAngle = v.toInt()),
                                onChangeEnd: (v) => sendCommand("/servo?angle=${v.toInt()}"),
                              ),
                            ),
                          ),
                          Text("Servo: $servoAngle°", style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Emergency Stop Button
                  ElevatedButton.icon(
                    onPressed: stopCar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.stop_circle, color: Colors.white),
                    label: const Text("STOP", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 25),

                  // Status
                  Text(
                    "Status: $status",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
