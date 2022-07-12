import 'package:flutter/cupertino.dart';

class JFollowList{
  final dynamic resultCode;
  final dynamic resultMsg;
  final dynamic pageNo;
  final JFollowListInfo info;

  JFollowList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.pageNo,
    @required this.info,
  });

  factory JFollowList.fromJson(Map<dynamic, dynamic> json){
    return JFollowList(
      resultCode: json['resultCode'], 
      resultMsg: json['resultMsg'], 
      pageNo: json['pageNo'], 
      info: json['info'] != null? JFollowListInfo.fromJson(json['info']) : null,
    );
  }
}

class JFollowListInfo{
  final dynamic type;
  final dynamic cnt;
  final List<JFollowListInfoListUnit> list;

  JFollowListInfo({
    @required this.type,
    @required this.cnt,
    @required this.list,
  });

  factory JFollowListInfo.fromJson(Map<dynamic, dynamic> json){
    var listJson = json['list'] as List;
    List<JFollowListInfoListUnit> _list = [];
    if(listJson != null)
      _list = listJson.map((listJson) => JFollowListInfoListUnit.fromJson(listJson)).toList();
    return JFollowListInfo(
      type: json['type'],
      cnt: json['cnt'],
      list : _list,
    );
  }
}

class JFollowListInfoListUnit{
  final dynamic followUserId;
  final dynamic name;
  final dynamic profileImageUrl;

  JFollowListInfoListUnit({
    @required this.followUserId,
    @required this.name,
    @required this.profileImageUrl
  });

  factory JFollowListInfoListUnit.fromJson(Map<dynamic, dynamic> json){
    return JFollowListInfoListUnit(
      followUserId: json['follow_user_id'],
      name: json['follow_user_name'],
      profileImageUrl: json['profile_image_url'],
    );
  }
}