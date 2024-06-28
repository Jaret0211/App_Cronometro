import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Cronometro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      home: const WatchScreen(),
    );
  }
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return TimerScreen(mode);
          },
        );
      },
    );
  }
}

class TimerScreen extends StatefulWidget {
  final WearMode mode;

  const TimerScreen(this.mode, {super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer;
  late int _count;
  late String _strCount;
  late String _status;

  @override
  void initState() {
    _count = 0;
    _strCount = "00:00:00";
    _status = "Start";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isAmbient = widget.mode == WearMode.ambient;
    return Scaffold(
      backgroundColor: isAmbient ? Colors.black : const Color.fromRGBO(215,198,172, 20),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10.0),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100.0,
                    height: 100.0,
                    child: CircularProgressIndicator(
                      value: _count % 60 / 60, // Display progress for seconds
                      strokeWidth: 1.5,
                      backgroundColor: Color.fromARGB(255, 255, 255, 255),
                      valueColor: AlwaysStoppedAnimation<Color>(isAmbient ? Colors.grey : Color.fromRGBO(161, 136, 100, 1)),
                    ),
                  ),
                  Text(
                    _strCount,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: isAmbient ? Colors.grey : Color.fromRGBO(255, 255, 255, 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            _buildWidgetButton(isAmbient),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetButton(bool isAmbient) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAmbient ? Colors.grey : Color.fromRGBO(161, 136, 100, 1),
                foregroundColor: isAmbient ? Colors.black : Colors.white,
                padding: const EdgeInsets.all(8.0),
                minimumSize: const Size(40, 40),
              ),
              onPressed: () {
                if (_status == "Start") {
                  _startTimer();
                } else if (_status == "Stop") {
                  _timer.cancel();
                  setState(() {
                    _status = "Continue";
                  });
                } else if (_status == "Continue") {
                  _startTimer();
                }
              },
              child: Icon(
                _status == "Start" || _status == "Continue" ? Icons.play_arrow : Icons.stop,
                size: 24,
              ),
            ),
            const SizedBox(width: 10.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAmbient ? Colors.grey : Color.fromRGBO(161, 136, 100, 1),
                foregroundColor: isAmbient ? Colors.black : Colors.white,
                padding: const EdgeInsets.all(8.0),
                minimumSize: const Size(40, 40),
              ),
              onPressed: () {
                if (_timer != null) {
                  _timer.cancel();
                  setState(() {
                    _count = 0;
                    _strCount = "00:00:00";
                    _status = "Start";
                  });
                }
              },
              child: const Icon(Icons.refresh, size: 24),
            ),
          ],
        ),
      ],
    );
  }

  void _startTimer() {
    _status = "Stop";
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _count += 1;
        int hour = _count ~/ 3600;
        int minute = (_count % 3600) ~/ 60;
        int second = (_count % 3600) % 60;
        _strCount = hour < 10 ? "0$hour" : "$hour";
        _strCount += ":";
        _strCount += minute < 10 ? "0$minute" : "$minute";
        _strCount += ":";
        _strCount += second < 10 ? "0$second" : "$second";
      });
    });
  }
}
