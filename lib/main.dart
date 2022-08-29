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
          "GUsRsanpcKwCC7ibxHu25uw4RtU2kPB8brXvz93HfsZjUxgxnQaAS6zatPCGftcicMkNDe1buV9nGaFaEFmUQYCNstPCwZ3MHiJR7C4PwVmv7Ct46qawk9c7pxL2yD5UsbT9TTecuprjP4mL8iZzFq9otPbHHgS98aukcsAmcbkJ8ieU3jxYuGq7eFwFMaWLG2CzNs5ZxqGH8rjC6K9krqBSCdE67hxhjWcj398hPW4qiEd4L6p6ujXyfk54Tp2jAPcE7vmRAeZnwoEbUqxhdB2oFbdB5ijYNgDKPKy9BU6iADZ1gMH3DVfSzhgZsrR6hnj3dK3iodwo");

  String value = "Response: ";

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
                  setState(() {
                    value = response.toString();
                  });
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
