import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Beacon Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Beacon Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const MethodChannel _methodChannel = MethodChannel('beaconMethod');

  final TextEditingController pairingRequestController = TextEditingController(
      text:
          "GUsRsanpcKz42MYDnuo63Lw8HD8bXoFZphzoY7iqZGqYuHwxQGBf7YbqmBg8dDgakbnjRsGnNgb6dM94Ax7uxm4o7f9YiQ8gYRH4N8EEQZCLowjbJTCk81fwvftZtk9nZPS6RvqSVZY1rdFNVkHmeLq6gnozkjhDdVrzEkTs6PFr4ZGQR4rryHHnm2RwbuCbERPARnPwqdAfxQaTHs4ivFHnBLPE8hejC4yVNDYCSM3z98wSjxznQzrT1WGt5Pr2WmJ6mzVLM2agF8GADEiPHjhnmSnGwo4whzAFtE8ZFoGwk1HwqUswWxQnE3Q6WVAndiusD1d7uSQe");

  String value = "Beacon Response: ";

  @override
  void initState() {
    super.initState();
    _methodChannel.invokeMethod('startBeacon');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: pairingRequestController,
                maxLines: 10,
              ),
              ElevatedButton(
                child: const Text('Pair'),
                onPressed: () async {
                  final Map response = await _methodChannel.invokeMethod('pair',
                      {"pairingRequest": pairingRequestController.text});
                  if (json.decode(response['error'].toString()) == 0) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Successfully Paired'),
                    ));
                  }
                },
              ),
              ElevatedButton(
                child: const Text('Respond'),
                onPressed: () async {
                  await _methodChannel.invokeMethod('respondExample');
                },
              ),
              const SizedBox(height: 10),
              Text(value)
            ],
          ),
        ),
      ),
    );
  }
}
