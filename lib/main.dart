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
          "GUsRsanpcL2Se3yYrWmrimk36PYiJLmk4rz8GR9oxSqTyMstRbRtvsYt1XiumG5EC51ov7mKLNJqcXaiT4UWyHmagy3iQhT4UV4e6QPrUVRk8ZyAHs6C7nwpyLAZB2hoQLB5JrtTwQFV3cpqp4b3StqRLitmMDQrKoBmL7CTGKRrWTn7Ew9FZmYA4wdTVDirQ4EqNuQSTPag1TTeStReke9dTSM42mzGdqZJTRCrfEHSnjhH3fK7Z4Brt52DFbEFNB95hGSMjY37n5aqqtzTzbqZcJCKMw8rDVVtbb8CArXk9bWMJWFE6F5smGVU9g8cgRMwmv4NDGvF");

  String value = "";

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
                child: Text(
                  value,
                  textAlign: TextAlign.left,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
