import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutterauth/provider/internet_provider.dart';
import 'package:flutterauth/provider/sign_in_provider.dart';
import 'package:flutterauth/screens/splash_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeDilation = 1;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  version = packageInfo.version;
  MobileAds.instance.initialize();

  RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: testDeviceIds);
  MobileAds.instance.updateRequestConfiguration(configuration);

  await Firebase.initializeApp();
  runApp(const MyApp());
}

String? version;
List<String> testDeviceIds = ['8006A0B39642B1FE54BF24F0EC98FCE7'];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => SignInProvider()),
        ),
        ChangeNotifierProvider(
          create: ((context) => InternetProvider()),
        ),
      ],
      child: const MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
