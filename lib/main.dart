import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rosseti_service/forms/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/static_variable.dart';

void main() => runApp(MyApp());

class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Проверка чеков',
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ru', ''),
      ],
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        FallbackCupertinoLocalisationsDelegate()
      ],
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF005b9c,
          <int, Color>{
            50: Color(0xFF3baaf9),
            100: Color(0xFF3baaf9),
            200: Color(0xFF2ea0f1),
            300: Color(0xFF2798e8),
            400: Color(0xFF1a8cdd),
            500: Color(0xFF0e7ecd),
            600: Color(0xFF0270be),
            700: Color(0xFF0168b2),
            800: Color(0xFF0060a5),
            900: Color(0xFF005b9c),
          },
        ),
      ),
      home: LoginPage(),
    );
  }
}
