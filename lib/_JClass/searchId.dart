import 'package:flutter/cupertino.dart';

class JSearchId{
  final String resultCode;
  final String resultMsg;
  final JSearchIdInfo info;

  JSearchId({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JSearchId.fromJson(Map<dynamic, dynamic> json){
    return JSearchId(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info: JSearchIdInfo.fromJson(json['info'])
    );
  }
}

class JSearchIdInfo{
  final String email;
  final String loginType;
  final String regDt;

  JSearchIdInfo({
    @required this.email,
    @required this.loginType,
    @required this.regDt
  });

  factory JSearchIdInfo.fromJson(Map<dynamic, dynamic> json){
    return JSearchIdInfo(
      email: json['email'],
      loginType: json['login_type'],
      regDt: json['reg_dt'],
    );
  }
}
