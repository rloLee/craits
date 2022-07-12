
import 'package:flutter/cupertino.dart';

class JProfileInfo{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JProfileInfoDetail info;


  JProfileInfo({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JProfileInfo.fromJson(Map<dynamic, dynamic> json){
    return JProfileInfo(
      resultCode: json['resultCode'],
      resultMsg:  json['resultMsg'],
      info:JProfileInfoDetail.fromJson(json['info'])
    );
  }
}

class JProfileInfoDetail{
  final dynamic name;
  final dynamic hpNo;
  final dynamic email;
  final dynamic birthday;
  final dynamic bloodType;
  final dynamic weight;
  final dynamic height;
  final dynamic imageUrl;
  final dynamic followCnt;
  final dynamic followingCnt;

  JProfileInfoDetail({
    @required this.name,
    @required this.hpNo,
    @required this.email,
    @required this.birthday,
    @required this.bloodType,
    @required this.weight,
    @required this.height,
    @required this.imageUrl,
    @required this.followCnt,
    @required this.followingCnt,
  });

  factory JProfileInfoDetail.fromJson(Map<dynamic, dynamic> json){
    return JProfileInfoDetail(
      name:   json['name'],
      hpNo:   json['hp_no'],
      email:   json['email'],
      birthday:  json['birthday'],
      bloodType:  json['blood_type'],
      weight:  json['weight'],
      height:  json['height'],
      imageUrl:  json['image_url'],
      followCnt:  json['follow_cnt'],
      followingCnt:  json['following_cnt'],
    );
  }
}