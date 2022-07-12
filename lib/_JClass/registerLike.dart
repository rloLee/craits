
import 'package:flutter/cupertino.dart';

class JRegisterLike{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JRegisterLikeInfo info;

  JRegisterLike({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JRegisterLike.fromJson(Map<dynamic, dynamic> json){
    return JRegisterLike(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info: JRegisterLikeInfo.fromJson(json['info']), 
    );
  }
}

class JRegisterLikeInfo{
  final dynamic type;
  final dynamic id;
  final dynamic flag;
  final dynamic cnt;

  JRegisterLikeInfo({
    @required this.type,
    @required this.id,
    @required this.flag,
    @required this.cnt,
  });

  factory JRegisterLikeInfo.fromJson(Map<dynamic, dynamic> json){
    return JRegisterLikeInfo(
      type: json['type'],
      id: json['id'],
      flag: json['flag'],
      cnt: json['cnt'],
    );
  }
}