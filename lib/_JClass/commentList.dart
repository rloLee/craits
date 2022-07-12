import 'package:flutter/cupertino.dart';

class JCommentList{
  final dynamic resultCode;
  final dynamic resultMsg;
  final dynamic pageNo;
  final List<JCommentListUnit> list;

  JCommentList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.pageNo,
    @required this.list,
  });

  factory JCommentList.fromJson(Map<dynamic, dynamic> json){
    var listJson = json['list'] as List;
    List _lists = [];
    if(listJson!=null)
      _lists = listJson.map((listJson) => JCommentListUnit.fromJson(listJson)).toList();

    return JCommentList(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      pageNo: json['pageNo'],
      list: _lists,
    );
  }
}

class JCommentListUnit{
  final dynamic id;
  final dynamic commentUserId;
  final String name;
  final String content;
  final String regDt;
  final String elapsedTime;
  final dynamic likeCnt;
  final String likeFlag;
  final dynamic profileImageUrl;
  final List<JCommentListUnitReplyListUnit> replyList;

  JCommentListUnit({
    @required this.id,
    @required this.commentUserId,
    @required this.name,
    @required this.content,
    @required this.regDt,
    @required this.elapsedTime,
    @required this.likeCnt,
    @required this.likeFlag,
    @required this.profileImageUrl,
    @required this.replyList,
  });

  factory JCommentListUnit.fromJson(Map<dynamic, dynamic> json){  
    var listJson = json['reply_list'] as List;
    List _lists = [];
    if(listJson != null)
      _lists = listJson.map((listJson) => JCommentListUnitReplyListUnit.fromJson(listJson)).toList();

    return JCommentListUnit(
      id: json['comment_id'],
      commentUserId: json['comment_user_id'],
      name: json['name'],
      content: json['content'],
      regDt: json['reg_dt'],
      elapsedTime: json['elapsed_time'],
      likeCnt: json['like_cnt'],
      likeFlag: json['like_flag'],
      profileImageUrl: json['profile_image_url'],
      replyList: _lists,
    );
  }
}

class JCommentListUnitReplyListUnit{
  final dynamic id;
  final dynamic repliyUserId;
  final dynamic name;
  final String content;
  final String regDt;
  final String elapsedTime;
  final String likeFlag;
  final dynamic profileImageUrl;

  JCommentListUnitReplyListUnit({
    @required this.id,
    @required this.repliyUserId,
    @required this.name,
    @required this.content,
    @required this.regDt,
    @required this.elapsedTime,
    @required this.likeFlag,
    @required this.profileImageUrl,
  });

  factory JCommentListUnitReplyListUnit.fromJson(Map<dynamic, dynamic> json){
    return JCommentListUnitReplyListUnit(
      id: json['reply_id'],
      repliyUserId: json['reply_user_id'],
      name: json['name'],
      content: json['content'],
      regDt: json['reg_dt'],
      elapsedTime: json['elapsed_time'],
      likeFlag: json['like_flag'],
      profileImageUrl: json['profile_image_url'],
    );
  }
}