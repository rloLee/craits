import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:craits/Common/com.dart';
import 'package:craits/_JClass/pushSettings.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

//리뷰
class SetPush extends StatefulWidget {
  @override
  _SetPushState createState() => _SetPushState();
}

class _SetPushState extends State<SetPush> {
  bool bAllow = false;
  // bool bAll = false;
  bool bFollow = false;
  bool bComment = false;
  bool bLike = false;
  bool bNew = false;
  bool bTake = false;
  bool bMis = false;
  bool bDup = false;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future getData() async{
      final uri = Uri.parse(commonUri+ '/V1/Push/SearchPush.json');
    try{
      var params = {
        'user_auth_id' : user.userAuthId,
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(Duration(seconds: 10));
      
      JPushSettings _pushSettings;
      if(response.statusCode == 200){
        _pushSettings = JPushSettings.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_pushSettings != null && _pushSettings.resultCode == 'SUCC' && _pushSettings.info != null){
          setState(() {
            bAllow = true;
            bFollow = _pushSettings.info.followYn == 'Y'? true : false;
            bComment = _pushSettings.info.cmtYn == 'Y'? true : false;
            bLike = _pushSettings.info.likeYn== 'Y'? true : false;
            bNew = _pushSettings.info.newYn == 'Y'? true : false;
            bTake = _pushSettings.info.takeYn == 'Y'? true : false;
            bDup = _pushSettings.info.dupYn == 'Y'? true : false;
            bMis = _pushSettings.info.misYn == 'Y'? true : false;
          });
        }
        else{
          setState(() {
            bAllow = false;
          });
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
      }
    }
    on TimeoutException catch(_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }
  
  Future setPush(String param, String value) async { 
    try {		
      final uri = Uri.parse(commonUri+ '/V1/Push/SetPush.json');

      showDialog(context: context,barrierDismissible: false,  builder: (_)  => LoadingDialog());
      var params = {
        'user_auth_id' : user.userAuthId,
        param : value
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(Duration(seconds: 10));
      
      Navigator.pop(context); //로딩끝
      
      JResponse _response;
      if(response.statusCode == 200){
        _response = JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
    }
    on TimeoutException catch(_) {
        Navigator.pop(context); //로딩끝
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }
  
  static final storage = FlutterSecureStorage(); //flutter_secure_storage 사용을 위한 초기화 작업

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token){
      regiserToken(token);
      storage.write(
        key: "token",
        value: token);
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
      final uri = Uri.parse(commonUri+ '/V1/Push/RegisterToken.json');

      showDialog(context: context,barrierDismissible: false,  builder: (_)  => LoadingDialog());
      var params = {
        'user_auth_id' : user.userAuthId,
        'token_id' : token,
        'os_type' : Platform.isIOS? 'IOS':'ANDROID'
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      
      Navigator.pop(context); //로딩끝
      
      JResponse _response;
      if(response.statusCode == 200){
        _response = JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
    }
    on TimeoutException catch(_) {
      Navigator.pop(context); //로딩끝
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title : Text('알림 설정'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
        }),
      ),
      body: Column(
        children: [
          SwitchListTile(
            value: bAllow, 
            title: Text('푸시알람 설정', style: Theme.of(context).textTheme.headline4,),
            onChanged: (value){
              setState(() {
                bAllow = value;
              });
              if(bAllow)
                firebaseCloudMessagingListeners();
              else 
                storage.delete(key: "token");
            }),
          Divider(thickness: 20, height: 20, color: Color(0xFFF2F4F6)),
          SwitchListTile(
            value: bFollow, 
            title: Text('팔로우 알림', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            subtitle:Text('누군가 나를 팔로우 했을 때 알림', style:  Theme.of(context).textTheme.caption),
            tileColor: bAllow? Colors.transparent : Colors.black12,
            onChanged: bAllow? (value){
              setState(() {
                bFollow = value;
              });
              String paramValue = value? 'Y' : 'N';
              setPush('follow_yn', paramValue);
            }:null
          ),
          SwitchListTile(
            value: bComment, 
            title: Text('댓글 알림', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            subtitle:Text('내글에 댓글, 다른 게시물에 대댓글 했을 때 알림', style:  Theme.of(context).textTheme.caption),
            tileColor: bAllow? Colors.transparent : Colors.black12,
            onChanged: bAllow? (value){
              setState(() {
                bComment = value;
              });
              String paramValue = value? 'Y' : 'N';
              setPush('cmt_yn', paramValue);
            }:null  
          ),
          SwitchListTile(
            value: bLike, 
            title: Text('좋아요 알림', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            subtitle:Text('내글, 내댓글에 좋아요 했을 때 알림', style:  Theme.of(context).textTheme.caption),
            tileColor: bAllow? Colors.transparent : Colors.black12,
            onChanged: bAllow? (value){
              setState(() {
                bLike = value;
              });
              String paramValue = value? 'Y' : 'N';
              setPush('like_yn', paramValue);
            }: null ),
          SwitchListTile(
            value: bNew, 
            title: Text('새게시글 알림', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            subtitle:Text('내가 팔로우한 사람의 새 게시글 알림', style:  Theme.of(context).textTheme.caption),
            tileColor: bAllow? Colors.transparent : Colors.black12,
            onChanged: bAllow? (value){
              setState(() {
                bNew = value;
              });
              String paramValue = value? 'Y' : 'N';
              setPush('new_yn', paramValue);
            }: null),
          Divider(thickness: 20, height: 20, color: Color(0xFFF2F4F6)),
          SwitchListTile(
            value: bTake, 
            title: Text('약복용 알림', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            subtitle:Text('내가 설정한 시간에 약복용 알림', style:  Theme.of(context).textTheme.caption),
            tileColor: bAllow? Colors.transparent : Colors.black12,
            onChanged: bAllow? (value){
              setState(() {
                bTake = value;
              });
              String paramValue = value? 'Y' : 'N';
              setPush('take_yn', paramValue);
            } : null),
          SwitchListTile(
            value: bMis, 
            title: Text('오처방 알림', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            subtitle:Text('처방전, 약봉투, 오처방시 알림', style:  Theme.of(context).textTheme.caption),
            tileColor: bAllow? Colors.transparent : Colors.black12,
            onChanged: bAllow? (value){
              setState(() {
                bMis = value;
              });
              String paramValue = value? 'Y' : 'N';
              setPush('mis_yn', paramValue);
            } : null),
          SwitchListTile(
            value: bDup, 
            title: Text('중복처방 알림', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            subtitle:Text('처방전, 약봉투, 중복처방시 알림', style:  Theme.of(context).textTheme.caption),
            tileColor: bAllow? Colors.transparent : Colors.black12,
            onChanged: bAllow? (value){
              setState(() {
                bDup = value;
              });
              String paramValue = value? 'Y' : 'N';
              setPush('dup_yn', paramValue);
            } : null)
        ],
      )
    );
  }
}