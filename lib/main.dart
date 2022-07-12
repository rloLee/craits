import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:craits/Home_feed/home.dart';
import 'login.dart';
import 'mainHome.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel channel;

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  KakaoContext.clientId = '7fbe905eebb16553530f3ac3e44118fc';

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      //달력에 필요. locale 한국으로 설정
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SfGlobalLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko'),
      ],
      locale: const Locale('ko'),
      home: MyLogin(),
      theme: ThemeData(
        fontFamily: 'SpoqaHanSansNeo',
        backgroundColor: const Color(0xFFF2F4F6),
        disabledColor: const Color(0xFFB9B9B9),
        primaryColor: const Color(0xFF469BA7), //469BA7
        accentColor: const Color(0xFF469BA7), //469BA7
        shadowColor: const Color(0xFFDADCDE),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.black54,
        ),
        dividerTheme:
            DividerThemeData(thickness: 1, color: Color(0xFFF3F3F3), space: 1),
        sliderTheme: SliderThemeData(
            thumbColor: Colors.white,
            rangeThumbShape: RoundRangeSliderThumbShape(elevation: 5.0),
            overlayColor: Color(0x22469BA7),
            valueIndicatorColor: Color(0xff469BA7),
            rangeValueIndicatorShape: PaddleRangeSliderValueIndicatorShape(),
            rangeTrackShape: RectangularRangeSliderTrackShape(),
            activeTrackColor: Color(0xFF469BA7),
            inactiveTrackColor: Color(0xFFDADCDE)),
        primaryTextTheme: TextTheme(
            headline6: TextStyle(
                fontSize: 16.0,
                color: Color(0xFF262626),
                fontWeight: FontWeight.w500)),
        tabBarTheme: TabBarTheme(
          labelColor: const Color(0xFF469BA7),
          unselectedLabelColor: const Color(0xFF262626),
          labelStyle: TextStyle(
              fontSize: 16.0,
              fontFamily: 'SpoqaHanSansNeo',
              fontWeight: FontWeight.w700),
          unselectedLabelStyle: TextStyle(
              fontSize: 16.0,
              fontFamily: 'SpoqaHanSansNeo',
              fontWeight: FontWeight.w500),
        ),
        textTheme: const TextTheme(
          button: const TextStyle(
              fontSize: 14.0,
              color: Color(0xFF469BA7),
              fontWeight: FontWeight.normal,
              fontFamily: 'SpoqaHanSansNeo'),
          headline1: const TextStyle(
              fontSize: 18.0,
              color: Color(0xFF262626),
              fontWeight: FontWeight.w700,
              fontFamily: 'SpoqaHanSansNeo'),
          headline2: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF262626),
              fontWeight: FontWeight.w700,
              fontFamily: 'SpoqaHanSansNeo'),
          headline3: const TextStyle(
              fontSize: 14.0,
              color: Color(0xFF262626),
              fontWeight: FontWeight.w700,
              fontFamily: 'SpoqaHanSansNeo'),
          headline4: const TextStyle(
              fontSize: 18.0,
              color: Color(0xFF262626),
              fontWeight: FontWeight.w500,
              fontFamily: 'SpoqaHanSansNeo'),
          headline5: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF262626),
              fontWeight: FontWeight.w500,
              fontFamily: 'SpoqaHanSansNeo'),
          headline6: const TextStyle(
              fontSize: 14.0,
              color: Color(0xFF469BA7),
              fontWeight: FontWeight.normal,
              fontFamily: 'SpoqaHanSansNeo'),
          subtitle1: const TextStyle(
              fontSize: 14.0,
              color: Color(0xFF469BA7),
              fontWeight: FontWeight.w500,
              fontFamily: 'SpoqaHanSansNeo'),
          subtitle2: const TextStyle(
              fontSize: 14.0,
              color: Color(0xFF959595),
              fontWeight: FontWeight.normal,
              fontFamily: 'SpoqaHanSansNeo'),
          bodyText1: const TextStyle(
              fontSize: 14.0,
              color: Color(0xFF262626),
              fontWeight: FontWeight.normal,
              fontFamily: 'SpoqaHanSansNeo'),
          bodyText2: const TextStyle(
              fontSize: 13.0,
              color: Color(
                0xFF262626,
              ),
              fontWeight: FontWeight.normal,
              fontFamily: 'SpoqaHanSansNeo'),
          caption: const TextStyle(
              fontSize: 13.0,
              color: Color(0xFF959595),
              fontWeight: FontWeight.normal,
              fontFamily: 'SpoqaHanSansNeo'),
        ),
        indicatorColor: const Color(0xFF469BA7),
        appBarTheme: AppBarTheme(
          elevation: 1.0,
          shadowColor: const Color(0xFFDADCDE),
          backgroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: const TextStyle(
              fontSize: 16.0,
              color: Color(
                0xFF262626,
              ),
              fontWeight: FontWeight.w500,
              fontFamily: 'SpoqaHanSansNeo'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
              fontSize: 14.0,
              color: Color(0xFF262626),
              fontWeight: FontWeight.w500,
              fontFamily: 'SpoqaHanSansNeo'),
        )),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
          primary: Color(0xFF469BA7),
        )),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF469BA7),
          secondary: const Color(0xFF469BA7),
          onBackground: const Color(0xFFB9B9B9),
        ),
      ),
      // initialRoute = home : 처음 보이는 페이지, 동시에 존재하면 에러
      // initialRoute: '/',
      routes: {
        '/login': (context) => MyLogin(),
        '/home': (context) => Home(),
        '/mainBar': (context) => MainHome(),
      },
    );
  }
}
