
import 'package:flutter/cupertino.dart';

class JUpdateFollow{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JUpdateFollowInfo info;

  JUpdateFollow({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JUpdateFollow.fromJson(Map<dynamic, dynamic> json){
    return JUpdateFollow(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info: JUpdateFollowInfo.fromJson(json['info']), 
    );
  }
}

class JUpdateFollowInfo{
  final dynamic followUserId;
  final dynamic flag;

  JUpdateFollowInfo({
    @required this.followUserId,
    @required this.flag,
  });

  factory JUpdateFollowInfo.fromJson(Map<dynamic, dynamic> json){
    return JUpdateFollowInfo(
      followUserId: json['follow_user_id'],
      flag: json['flag'],
    );
  }
}