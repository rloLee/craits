import 'package:flutter/cupertino.dart';

class JBannerList{
  final String resultCode;
  final String resultMsg;
  final List<JBannerListUnit> list;

  JBannerList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.list,
  });

  factory JBannerList.fromJson(Map<String, dynamic> json){
    var _listJson = json['list'] as List;
    List<JBannerListUnit> _list = [];
    
    if(_listJson != null)
      _list =  _listJson.map((listJson) => JBannerListUnit.fromJson(listJson)).toList();

    return JBannerList(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      list: _list,
    );
  }
}

class JBannerListUnit{
  final dynamic seq;
  final String title;
  final String imageUrl;
  final String urlLink;
  final String ordnerNo;

  JBannerListUnit({
    @required this.seq,
    @required this.title,
    @required this.imageUrl,
    @required this.urlLink,
    @required this.ordnerNo,
  });

  factory JBannerListUnit.fromJson(Map<String, dynamic> json){
    return JBannerListUnit(
      seq: json['seq'],
      title: json['title'],
      imageUrl: json['image_url'],
      urlLink: json['url_link'],
      ordnerNo: json['ordner_no'],
    );
  }
}