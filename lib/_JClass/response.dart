import 'package:flutter/cupertino.dart';

class JResponse{
  final dynamic resultCode;
  final dynamic resultMsg;

  JResponse({
    @required this.resultCode,
    @required this.resultMsg,
  });

  factory JResponse.fromJson(Map<dynamic, dynamic> json){
    return JResponse(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
    );
  }
}