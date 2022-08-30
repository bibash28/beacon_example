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
  static const EventChannel _eventChannel = EventChannel('beaconEvent');

  final TextEditingController pairingRequestController = TextEditingController(
      text:
          "GUsRsanpcKw3qz67A8adX1VNhMfWumXTrSXwN3dkQmJywa6M1Wt5mF2n5omouMQTNCF4mRHo83gU4R6ZBijpXvyVkU1PnGBEJAiirmZH8mSCuWywngqiDJDDyQmfGNc2uj85uBffndZ4Agys5LHLK6d5jMH4yooAWmnKc6qWHT8eeEd3SrZbKqVoCE7UG7gpYtLvkHG2mFsnUGJbBTP3dQ4WRTiyYwgZAHwTRgXTFqtR6XYuQZnYHfCiqynNeBSXR5NBtAc4bWEXWf165ygCHqp4nYHaaHTv1NuEpXdu29tKxtsNSi53XtiVdGa2YcgXLoPZ5tXEudVi");

  @override
  void initState() {
    super.initState();
    _methodChannel.invokeMethod('startBeacon');
  }

  static Stream<String> get getBeaconResponse {
    return _eventChannel.receiveBroadcastStream().cast();
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
              Container(
                alignment: Alignment.centerLeft,
                child: const Text('Pairing Request: '),
              ),
              TextField(
                controller: pairingRequestController,
                maxLines: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    child: const Text('Unpair'),
                    onPressed: () async {
                      final Map response =
                          await _methodChannel.invokeMethod('removePeers');
                      if (json.decode(response['error'].toString()) == 0) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Successfully disconnected.'),
                        ));
                      }
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Pair'),
                    onPressed: () async {
                      final Map response = await _methodChannel.invokeMethod(
                          'pair',
                          {"pairingRequest": pairingRequestController.text});
                      if (json.decode(response['error'].toString()) == 0) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Successfully paired.'),
                        ));
                      }
                    },
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  child: const Text('Respond'),
                  onPressed: () async {
                    await _methodChannel.invokeMethod('respondExample');
                  },
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text('Beacon Response: '),
              ),
              SizedBox(
                width: double.infinity,
                child: StreamBuilder<String>(
                    stream: getBeaconResponse,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.hasData ? snapshot.data! : '',
                        textAlign: TextAlign.left,
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
