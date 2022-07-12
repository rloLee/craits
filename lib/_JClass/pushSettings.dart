
import 'package:flutter/cupertino.dart';

class JPushSettings{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JPushSettingsInfo info;

  JPushSettings({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JPushSettings.fromJson(Map<dynamic, dynamic> json){
    return JPushSettings(
      resultCode: json['resultCode'],
      resultMsg: json['ersultMsg'],
      info: json['info'] != null ? JPushSettingsInfo.fromJson(json['info']) : null
    );
  }
}


class JPushSettingsInfo{
  final dynamic followYn;
  final dynamic cmtYn;
  final dynamic likeYn;
  final dynamic newYn;
  final dynamic takeYn;
  final dynamic misYn;
  final dynamic dupYn;
  
  JPushSettingsInfo({
    @required this.followYn,
    @required this.cmtYn,
    @required this.likeYn,
    @required this.newYn,
    @required this.takeYn,
    @required this.misYn,
    @required this.dupYn,
  });

  factory JPushSettingsInfo.fromJson(Map<dynamic, dynamic> json){
    return JPushSettingsInfo(
      followYn: json['follow_yn'],
      cmtYn: json['cmt_yn'],
      likeYn: json['like_yn'],
      newYn: json['new_yn'],
      takeYn: json['take_yn'],
      misYn: json['mis_yn'],
      dupYn: json['dup_yn'],
    );
  }
}