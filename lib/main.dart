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
          "GUsRsanpcLZGE9oNTJyV6WKhvE9itMUi9uStuXnXWPMhKsPynPLX79xqNNqwXiipaiJUsJwY9xE5zzZzycWA2XZfE6STW6LMpr72HCrJvFJZ6DPNxhhpd4WXtdNDLbF6tDsXfBcYn66wpkQ6fN1rHSXqfpPGSD8CfE4fuGxEAB3kw8GazUjwX2Eg6taGrFJqqEmragutBGoZ3Qgw7FahbuUGPMNDDS86iGWXvFkUDxKgKkP8KahwBaUBUd61gjUMMWP2p5PCZpudWm8dEz2MnTPszMcrzbZu7ZmBRic5J5TJCkmjvpEb2YJC1JMs39nrk5RbpuhRvZdr");

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
          value = data;
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
                              hasPeers =
                                  json.decode(response['success'].toString());
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
                              hasPeers =
                                  json.decode(response['success'].toString());
                            });

                            if (hasPeers) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Successfully paired.'),
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
