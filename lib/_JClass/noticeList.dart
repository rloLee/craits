import 'package:flutter/cupertino.dart';

class JNoticeList{
  final String resultCode;
  final String resultMsg;
  final List<JNoticeListUnit> list;

  JNoticeList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.list,
  });

  factory JNoticeList.fromJson(Map<dynamic, dynamic> json){
    var _listJson = json['list'] as List;
    List<JNoticeListUnit> _list = [];
    if(_listJson != null)
      _list = _listJson.map((listJson) => JNoticeListUnit.fromJson(listJson)).toList();

    return JNoticeList(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      list: _list
    );
  }
}

class JNoticeListUnit{
  final dynamic seq;
  final String title;
  final String content;
  String hitYn;
  final String regDt;

  JNoticeListUnit({
    @required this.seq,
    @required this.title,
    @required this.content,
    @required this.hitYn,
    @required this.regDt
  });

  factory JNoticeListUnit.fromJson(Map<dynamic, dynamic> json){
    return JNoticeListUnit(
      seq: json['seq'],
      title: json['title'],
      content: json['content'],
      hitYn: json['hit_yn'],
      regDt: json['reg_dt'],
    );
  }
}