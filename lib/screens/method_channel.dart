import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutterauth/services/start_service.dart';

class MethodChannelScreen extends StatefulWidget {
  const MethodChannelScreen({Key? key}) : super(key: key);

  @override
  State<MethodChannelScreen> createState() => _MethodChannelScreenState();
}

class _MethodChannelScreenState extends State<MethodChannelScreen> {
  String? battery;

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
  }

  _getBatteryLevel() async {
    var temp = await StartService().getBatteryLevel;
    setState(() {
      battery = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Method Channel"),
      ),
      body: Center(
        child: Text(
          "Battery Level : $battery%",
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}
