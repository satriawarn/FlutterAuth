import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutterauth/provider/sign_in_provider.dart';
import 'package:flutterauth/screens/google_maps.dart';
import 'package:flutterauth/screens/image_upload_screen.dart';
import 'package:flutterauth/screens/login_screen.dart';
import 'package:flutterauth/screens/show_images.dart';
import 'package:flutterauth/utils/next_screen.dart';
import 'package:provider/provider.dart';

import '../model/push_notification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirebaseMessaging _messaging;
  late final FirebaseAnalytics _analytics;
  late int _totalNotificationCounter;

  PushNotification? _notificationInfo;

  void analyticsInstance() async {
    print("firebase analytics initialize");
    await Firebase.initializeApp();
    _analytics = FirebaseAnalytics.instance;
    // await FirebaseAnalytics.instance.logBeginCheckout(
    //     value: 10.0,
    //     currency: 'USD',
    //     items: [
    //       AnalyticsEventItem(
    //           itemName: 'Socks', itemId: 'xjw73ndnw', price: 10.0),
    //     ],
    //     coupon: '10PERCENTOFF');
  }

  void registerNotification() async {
    await Firebase.initializeApp();

    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted permissions");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataBody: message.data['body'],
          dataTitle: message.data['title'],
        );

        setState(() {
          // _totalNotificationCounter++;
          _notificationInfo = notification;
        });
      });
    } else {
      print("permission denied");
    }
  }

  checkForInitialMessage() async {
    await Firebase.initializeApp();

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification!.title,
        body: initialMessage.notification!.body,
        dataBody: initialMessage.data['body'],
        dataTitle: initialMessage.data['title'],
      );

      setState(() {
        _notificationInfo = notification;
      });
    }
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    //initiate analytics
    analyticsInstance();

    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
        dataBody: message.data['body'],
        dataTitle: message.data['title'],
      );

      setState(() {
        _notificationInfo = notification;
      });
    });

    //normal nofitication
    registerNotification();

    // when app is in terminated state
    checkForInitialMessage();

    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage("${sp.imageUrl}"),
              radius: 50,
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome ${sp.name}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${sp.email}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${sp.uid}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("PROVIDER:"),
                const SizedBox(width: 5),
                Text(
                  "${sp.provider}".toUpperCase(),
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                _analytics.logEvent(
                    name: 'Upload Image Click', parameters: null);

                nextScreen(
                    context,
                    ImageUpload(
                      userId: sp.uid,
                    ));
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "Upload Image",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                nextScreen(
                    context,
                    ShowUploads(
                      userId: sp.uid,
                    ));
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "Show Image",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                nextScreen(context, const GoogleMapsScreen());
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.greenAccent,
              ),
              child: const Text(
                "Open Google Maps",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                sp.userSignOut();
                nextScreenReplace(context, const LoginScreen());
              },
              child: const Text(
                "SIGNOUT",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
