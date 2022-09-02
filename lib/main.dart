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
          "GUsRsanpcKw4ACJdHiXCZ5NKwEHXefDrDffTFLnYB7k1mDpFFtYaraQx5jUhcHMozjfDSSwvKcbnpmRCq54G1vai2KwNJEqUpz3FYRerUAZ7nJtDN3aGp3Wo5eyhFQSxFmPqoUVa6bwQxZRoYJJcM8kjsM8vRTtSJg1jdpFEUWQCAbNhi9oZg3uyL412PPmmD5JSDUgtv1WJNLqAv7dcQ6fKM9GGpkspPzSWBYD8GRQSFZUHUf6BU1Me9BhtHUXv6HUMy7i1tyva5Rs4AwwiPC5xRw4YEEPGGkpKjgoU8r2SRYgZi6HsF5Wm7zUhhrzCdx66UJa8fHtC");

  bool hasPeers = false;

  String value = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startBeacon();
    });
  }

  startBeacon() async {
    final Map response = await _methodChannel.invokeMethod('startBeacon');
    setState(() {
      hasPeers = json.decode(response['success'].toString());
    });
    getBeaconResponse();
  }

  void getBeaconResponse() {
    _eventChannel.receiveBroadcastStream().listen(
      (data) {
        setState(() {
          value = data.toString();
        });
      },
    );
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
                    onPressed: !hasPeers
                        ? null
                        : () async {
                            final Map response = await _methodChannel
                                .invokeMethod('removePeers');

                            setState(() {
                              bool success =
                                  json.decode(response['success'].toString());
                              hasPeers = !success;
                            });

                            if (!hasPeers) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Successfully disconnected.'),
                              ));
                            }
                          },
                    child: const Text('Unpair'),
                  ),
                  ElevatedButton(
                    onPressed: hasPeers
                        ? null
                        : () async {
                            final Map response = await _methodChannel
                                .invokeMethod('pair', {
                              "pairingRequest": pairingRequestController.text
                            });

                            setState(() {
                              bool success =
                                  json.decode(response['success'].toString());
                              hasPeers = success;
                            });

                            if (hasPeers) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Successfully paired.'),
                              ));
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Failed to pair.'),
                              ));
                            }
                          },
                    child: const Text('Pair'),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: value.isEmpty
                      ? null
                      : () async {
                          setState(() {
                            value = '';
                          });
                          await _methodChannel.invokeMethod('respondExample');
                        },
                  child: const Text('Respond'),
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
                child: Text(
                  value,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
