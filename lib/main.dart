import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:masoud_oil_admin/cashed_helper.dart';
import 'package:masoud_oil_admin/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

// Add token to Firestore on app start
Future<void> _addTokenToFirestore() async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await FirebaseFirestore.instance
        .collection('tokens')
        .doc(CashedHelper.getData(key: 'id') as String)
        .set({'token': token});
  }
}

// Generate unique id for each device
Future<void> _generateUniqueId() async {
  var uniqueId = CashedHelper.getData(key: 'id') ?? '';
  if (uniqueId == '') {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await CashedHelper.putData(key: 'id', value: id);
  }
  print(CashedHelper.getData(key: 'id'));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CashedHelper.init();
  await Firebase.initializeApp();
  Permission.location.isGranted.then((isGranted) {
    if (!isGranted) {
      Permission.location.request();
    }
  }).catchError((error) {
    print(error.toString());
  });

  await _generateUniqueId();

  await _addTokenToFirestore();

  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    print('Token: $fcmToken');
    FirebaseFirestore.instance
        .collection('tokens')
        .doc(CashedHelper.getData(key: 'id') as String)
        .set({'token': fcmToken});
    // Note: This callback is fired at each app startup and whenever a new
    // token is generated.
  });

  FirebaseMessaging.onMessage.listen((event) {
    print('Notification Message: ${event.data.toString()}');
  }).onError((error) {
    print(error.toString());
  });

  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    print('Notification Message: ${event.data.toString()}');
  }).onError((error) {
    print(error.toString());
  });

  final fcmToken = await FirebaseMessaging.instance.getToken();

  print('FCM token: $fcmToken');

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masoud Oil Admin',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xFFF2CB62,
          {
            50: Color(0x1AF2CB62),
            100: Color(0x33F2CB62),
            200: Color(0x4DF2CB62),
            300: Color(0x66F2CB62),
            400: Color(0x80F2CB62),
            500: Color(0x99F2CB62),
            600: Color(0xB3F2CB62),
            700: Color(0xCCF2CB62),
            800: Color(0xE6F2CB62),
            900: Color(0xFFF2CB62),
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
      ],
      home: const HomeScreen(),
    );
  }
}
