import 'package:flutter/material.dart';

class JLogin{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JLoginInfo info;

  JLogin({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JLogin.fromJson(Map<dynamic, dynamic> json){
    return JLogin(
        resultCode: json['resultCode'],// as dynamic,
        resultMsg: json['resultMsg'],// as dynamic,
        info: JLoginInfo.fromJson(json['info']),// as dynamic,
    );
  }
}

class JLoginInfo{
  final dynamic userAuthId;
  final dynamic userId;
  final dynamic name;
  final dynamic email;
  final dynamic birthday;
  final dynamic bloodType;
  final dynamic weight;
  final dynamic height;
  final dynamic imageUrl;
  final dynamic followCnt;
  final dynamic followingCnt;
  String loginType;

  JLoginInfo({
    @required this.userAuthId,
    @required this.userId,
    @required this.name,
    @required this.email,
    @required this.birthday,
    @required this.bloodType,
    @required this.weight,
    @required this.height,
    @required this.imageUrl,
    @required this.followCnt,
    @required this.followingCnt,
  });

  factory JLoginInfo.fromJson(Map<dynamic, dynamic> json){
    return JLoginInfo(
      userAuthId: json['user_auth_id'],
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      birthday: json['birthday'],
      bloodType: json['blood_type'],
      weight: json['weight'],
      height: json['height'],
      imageUrl: json['image_url'],
      followCnt: json['follow_cnt'],
      followingCnt: json['following_cnt'],
    );
  }
}