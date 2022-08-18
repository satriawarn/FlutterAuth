import 'package:flutter/services.dart';

class StartService {
  static const platform = MethodChannel("com.trace.service");

  Future<String> get getBatteryLevel async {
    String? batteryLevel;
    try {
      final int result = await platform.invokeMethod("getBatteryLevel");
      batteryLevel = result.toString();
    } on PlatformException catch (e) {
      batteryLevel = "gagal, battery level tidak terdefinisi";
    }

    return batteryLevel;
  }
}
