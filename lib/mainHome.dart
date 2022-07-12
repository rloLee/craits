import 'dart:convert';
import 'dart:io';
import 'package:craits/Common/com.dart';
import 'package:craits/Etc/popUpDialog_done.dart';
import 'package:craits/Etc/popUpDialog_effect.dart';
import 'package:craits/Etc/popUpDialog_park.dart';
import 'package:craits/Etc/popUpDialog_parkfree.dart';
import 'package:craits/Etc/popUpDialog_takeAlarm.dart';
import 'package:craits/Etc/popUpPermission.dart';
import 'package:craits/Home_Feed/feed_comment.dart';
import 'package:craits/_JClass/reverseGeocode.dart';
import 'package:craits/MyPage/myPage.dart';
import 'package:craits/main.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:craits/Home_feed/home.dart';
import 'package:craits/menu1_Hospital/hospital.dart';
import 'package:craits/menu2_Pharmacy/pharmacy.dart';
import 'package:craits/menu3_Medicine/medicine.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel channel = AndroidNotificationChannel(
    'craits01', // id
    'CRAITSChannel', // title
    'CRAITS channel descs', // description
    importance: Importance.high,
    groupId: 'craitsGroup01');

AndroidNotificationChannelGroup androidNotificationChannelGroup =
    AndroidNotificationChannelGroup(channel.groupId, 'your channel group name',
        description: 'your channel group description');

/// Notification plugin 생성
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 알림 발생 함수
Future<void> _showGroupedNotifications(RemoteNotification notification) async {
  // List<ActiveNotification> activeNotifications = await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.getActiveNotifications();

  // 안드로이드 알림
  AndroidNotificationDetails notificationAndroidSpecifics =
      AndroidNotificationDetails(channel.id, channel.name, channel.description,
          importance: Importance.max,
          priority: Priority.high,
          groupKey: channel.groupId);

  var iOSNotiDetails = const IOSNotificationDetails();

  // 플랫폼별 설정 - 현재 안드로이드만 적용됨
  NotificationDetails notificationPlatformSpecifics = NotificationDetails(
      android: notificationAndroidSpecifics, iOS: iOSNotiDetails);

  // 알림 발생!
  await flutterLocalNotificationsPlugin.show(notification.hashCode,
      notification.title, notification.body, notificationPlatformSpecifics,
      payload: 'Default_Sound');

  // // 그룹용 알림 설정
  // // 특징 setAsGroupSummary 가 true 이다.
  // AndroidNotificationDetails androidPlatformChannelSpecifics =
  //   AndroidNotificationDetails(
  //     channel.id, channel.name, channel.description,
  //     onlyAlertOnce: true,
  //     groupKey: channel.groupId, setAsGroupSummary: true);

  // // 플랫폼별 설정 - 현재 안드로이드만 적용됨
  // NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  // // 그룹용 알림 출력
  // // 이때는 ID를 0으로 고정시켜 새로 생성되지 않게 한다.
  // await flutterLocalNotificationsPlugin.show(
  //     0, '', '', platformChannelSpecifics);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

GlobalKey<FormState> pkFreeKey = GlobalKey<FormState>(); //글로벌 키 선언

class MainHome extends StatefulWidget {
  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _currentIndex = 0;
  Widget tab;
  static final storage =
      FlutterSecureStorage(); //flutter_secure_storage 사용을 위한 초기화 작업

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    tab = Home();
    await welcome(); //퍼미션 설정
    firebaseInit(); //파이어베이스 관련 설정
    initDynamicLinks(); //다이나믹링크 설정
  }

  //알림을 눌렀을때 어떤 행동을 할지 정해주는 부분
  Future onSelectNotification(String payload) async {
    print("payload : $payload");
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Text('Payload: $payload'),
            ));
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    Uri deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.path == '/feed') {
        var feedId = deepLink.queryParameters['code'];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FeedComment(
                      feedId: feedId,
                      onDelete: () {},
                    )));
      }
    }
  }

//처음 실행한 경우 퍼미션 설정
  Future welcome() async {
    String welcome = await storage.read(key: 'welcome');
    if (welcome == null) {
      showDialog(
              context: context,
              builder: (context) => PopupPermission(),
              barrierDismissible: false)
          .then((value) async {
        if (value) {
          storage.write(key: 'welcome', value: 'true');
          await getPosition();
        }
      });
    } else {
      await getPosition();
    }
  }

  void firebaseInit() async {
    String token = await storage.read(key: 'token');
    if (token == null) {
      firebaseCloudMessagingListeners();
    }
    FirebaseMessaging.instance.requestPermission();
    //알림용 icon 설정
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_notification');

//ios 알림 설정 : 소리, 뱃지 등을 설정하여 줄수가 있습니다.
    var initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    //알림초기화
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      //알람 선택했을때
      if (payload != null) onSelectNotification(payload);
    });

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (!kIsWeb) {
      // await flutterLocalNotificationsPlugin
      //     .resolvePlatformSpecificImplementation<
      //         AndroidFlutterLocalNotificationsPlugin>()
      //     .createNotificationChannelGroup(androidNotificationChannelGroup);

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        if (message.data['type'] == 'TAKE')
          showDialog(
              context: context,
              builder: (context) => PopupTakeAlarm(message.data));
        else if (message.data['type'] == 'DONE')
          showDialog(
              context: context, builder: (context) => PopupDone(message.data));
        else if (message.data['type'] == 'EFFECT')
          showDialog(
              context: context,
              builder: (context) => PopupEffect(message.data));
        else if (message.data['type'] == 'PK')
          showDialog(
              context: navigatorKey.currentContext,
              builder: (_) => PopupPark(message.data),
              useRootNavigator: true);
        else if (message.data['type'] == 'PKFREE')
          showDialog(
              context: navigatorKey.currentContext,
              builder: (_) =>
                  PopupParkFree(key: pkFreeKey, data: message.data));
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        _showGroupedNotifications(notification);
      }
      if (message.data['type'] == 'TAKE')
        showDialog(
            context: context,
            builder: (context) => PopupTakeAlarm(message.data));
      else if (message.data['type'] == 'DONE')
        showDialog(
            context: context, builder: (context) => PopupDone(message.data));
      else if (message.data['type'] == 'EFFECT')
        showDialog(
            context: context, builder: (context) => PopupEffect(message.data));
      else if (message.data['type'] == 'PK')
        showDialog(
            context: navigatorKey.currentState.overlay.context,
            builder: (_) => PopupPark(message.data),
            barrierDismissible: true);
      else if (message.data['type'] == 'PKFREE')
        showDialog(
            context: navigatorKey.currentState.overlay.context,
            builder: (_) => PopupParkFree(key: pkFreeKey, data: message.data),
            barrierDismissible: true);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data != null) {
        if (message.data['type'] == 'TAKE')
          showDialog(
              context: context,
              builder: (context) => PopupTakeAlarm(message.data));
        else if (message.data['type'] == 'DONE')
          showDialog(
              context: context, builder: (context) => PopupDone(message.data));
        else if (message.data['type'] == 'EFFECT')
          showDialog(
              context: context,
              builder: (context) => PopupEffect(message.data));
        else if (message.data['type'] == 'PK')
          showDialog(
              context: navigatorKey.currentState.overlay.context,
              builder: (_) => PopupPark(message.data),
              barrierDismissible: true);
        else if (message.data['type'] == 'PKFREE')
          showDialog(
              context: navigatorKey.currentState.overlay.context,
              builder: (_) => PopupParkFree(key: pkFreeKey, data: message.data),
              barrierDismissible: true);
      }
    });
  }

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();
    _firebaseMessaging.getToken().then((token) {
      regiserToken(token);
      storage.write(key: "token", value: token);
    });
  }

  void iOSPermission() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future regiserToken(String token) async {
    try {
      final uri = Uri.parse(commonUri + '/V1/Push/RegisterToken.json');
      var params = {
        'user_auth_id': user.userAuthId,
        'token_id': token,
        'os_type': Platform.isIOS ? 'IOS' : 'ANDROID'
      };

      final newUri = uri.replace(queryParameters: params);
      http.get(newUri).timeout(timeoutDuration);
    } catch (_) {}
  }

  Future getPosition() async {
    final uriGeo = Uri.parse(
        'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc');
    bool serviceEnabled;
    LocationPermission permission;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {}

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        //위치 권한 거부
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          //위치 권한 또 거부......
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // 위치 권한이 영원히 거부 상태..............
        // TODO: 랜덤 위치 설정,메시지창, 권한 설정 화면으로 이동시켜줘야할듯.
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (mounted)
          setState(() {
            dCurLong = position.longitude;
            dCurLat = position.latitude;
          });
      }

      var params = {
        'coords': dCurLong.toString() + ',' + dCurLat.toString(),
        'output':
            'json', //정렬 - NAME : 이름순 - DISTANCE : 거리순 - REVIEW : 평점순 - LAST : 최신순
      };

      var headers = {
        'X-NCP-APIGW-API-KEY-ID': naverClientId,
        'X-NCP-APIGW-API-KEY': naverClientSecretId,
      };

      final newUri = uriGeo.replace(queryParameters: params);
      http.Response response = await http.get(newUri, headers: headers);
      if (response.statusCode == 200) {
        JReverseGeocode reverseGeocode = JReverseGeocode.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
        if (reverseGeocode.status.code == 0) {
          if (mounted)
            setState(() {
              sLocation =
                  '${reverseGeocode.results[0].region.area2.name} ${reverseGeocode.results[0].region.area3.name} ${reverseGeocode.results[0].region.area4.name}';
              sSigungu = reverseGeocode.results[0].region.area1.name;
              sSido = reverseGeocode.results[0].region.area2.name;
            });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: Duration(milliseconds: 1500),
              content: Text('위치 정보 오류가 발생했습니다.')));
          if (mounted)
            setState(() {
              dCurLat = 37.563600;
              dCurLong = 126.962370;
              sLocation = '';
              sSigungu = '';
              sSido = '';
            });
        }
      } else {
        if (mounted)
          setState(() {
            sLocation = '';
            sSigungu = '';
            sSido = '';
          });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('오류가 발생했습니다.')));
    }
  }

  void goHome() {
    setState(() {
      _currentIndex = 0;
      tab = Home();
    });
  }

  static DateTime currBackPressTime;
  bool _isEnd() {
    DateTime now = DateTime.now();
    if (currBackPressTime == null ||
        now.difference(currBackPressTime) > Duration(seconds: 2)) {
      currBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('\'뒤로\' 버튼을 한번 더 누르면 종료됩니다.')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex == 0) {
          return await Future.value(_isEnd());
        } else {
          setState(() {
            _currentIndex = 0;
            tab = Home();
          });
          return Future(() => false);
        }
      },
      child: Scaffold(
          body: tab != null
              ? tab
              : Center(
                  child: CircularProgressIndicator(),
                ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedFontSize: 12.0,
            unselectedFontSize: 12.0,
            selectedItemColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                activeIcon: SvgPicture.asset('assets/home_color.svg'),
                icon: SvgPicture.asset(
                  'assets/home_color.svg',
                  color: const Color(0xFF707070),
                ),
                label: '홈',
              ),
              BottomNavigationBarItem(
                activeIcon: SvgPicture.asset('assets/hospital_color.svg'),
                icon: SvgPicture.asset(
                  'assets/hospital_color.svg',
                  color: const Color(0xFF707070),
                ),
                label: '병원',
              ),
              BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset('assets/pharmacy_color.svg'),
                  icon: SvgPicture.asset(
                    'assets/pharmacy_color.svg',
                    color: const Color(0xFF707070),
                  ),
                  label: '약국'),
              BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset('assets/pill_color.svg'),
                  icon: SvgPicture.asset(
                    'assets/pill_color.svg',
                    color: const Color(0xFF707070),
                  ),
                  label: '약'),
              BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset('assets/user_color.svg'),
                  icon: SvgPicture.asset(
                    'assets/user_color.svg',
                    color: const Color(0xFF707070),
                  ),
                  label: 'MY')
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                if (_currentIndex == 0)
                  tab = Home();
                else if (_currentIndex == 1)
                  tab = Hospital(goHome);
                else if (_currentIndex == 2)
                  tab = Pharmacy(goHome);
                else if (_currentIndex == 3)
                  tab = Medicine(goHome);
                else if (_currentIndex == 4) tab = MyPage(goHome);
              });
            },
          )),
    );
  }
}
