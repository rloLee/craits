import 'package:flutter/cupertino.dart';

class JPushLogList{
  final String resultCode;
  final String resultMsg;
  List<JPushLogListUnit> list;
  
  JPushLogList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.list
  });

  factory JPushLogList.fromJson(Map<dynamic, dynamic> json){
    var listJson = json['list'] as List;
    List _list = [];
    if(listJson!=null)
      _list = listJson.map((listJson) => JPushLogListUnit.fromJson(listJson)).toList();

    return JPushLogList(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      list: _list
    );
  }
}

class JPushLogListUnit{
  final String seq;
  final String notiType;
  final String title;
  final String body;
  final dynamic linkId;
  final String hitYn;
  final String elapsedTime;
  final String sendDt;

  JPushLogListUnit({
    @required this.seq,
    @required this.notiType,
    @required this.title,
    @required this.body,
    @required this.linkId,
    @required this.hitYn,
    @required this.elapsedTime,
    @required this.sendDt,
  });

  factory JPushLogListUnit.fromJson(Map<dynamic, dynamic> json){
    return JPushLogListUnit(
      seq: json['seq'],
      notiType: json['noti_type'],
      title: json['title'],
      body: json['body'],
      linkId: json['link_id'],
      hitYn: json['hit_yn'],
      elapsedTime: json['elapsed_time'],
      sendDt: json['send_dt'],
    );
  }
}