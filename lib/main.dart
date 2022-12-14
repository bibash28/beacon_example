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
          "GUsRsanpcKwo4t53chv9Gar7xV6B42o4behDHwpmZYFF76U6RFCGj3Aka2E8zSEV8GTYiG55fAWJ1jCnVyfxuTRw3JbtYMBu47FKW2NCk8sSNNYUiPTHvnZeQkRGEzvnsgKsP33S7AD5X66XgJDcHZHkMwTNK5SWnchnERyAMgBywxpCAVtUph91PEGUbMK61VfxB76M8ynDfhtgL3yUPkoSf9mtzioQtrKqRStv1M9FJMjqGegy7MV727oEB9KsKrtk6nsESW9TVpsvKALFhRwYAk7km3XNcgyrmJaZ8M15g8Q9KDSZL7LWWKg8if2EPU1AXwxsvrPx");

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
