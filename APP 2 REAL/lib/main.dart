import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'properties/home_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future main() async {
  // init the hive
  await Hive.initFlutter();

  // open a box
  var box = await Hive.openBox('mybox');
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.removeAfter(initialization);
  runApp(const MyApp());
}

Future initialization(BuildContext? context) async {
  await Future.delayed(Duration(seconds: 3));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(primarySwatch: Colors.blue), //primary color of the app
    );
  }
}
