import 'package:flutter/cupertino.dart';

class JRegisterComment{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JRegisterCommentInfo info;

  JRegisterComment({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JRegisterComment.fromJson(Map<dynamic, dynamic> json){
    return JRegisterComment(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info: JRegisterCommentInfo.fromJson(json['info']), 
    );
  }
}

class JRegisterCommentInfo{
  final dynamic commentId;
  final dynamic commentUserId;
  final dynamic name;
  final dynamic content;
  final dynamic regDt;
  final dynamic likeFlag;
  final dynamic profileImageUrl;

  JRegisterCommentInfo({
    @required this.commentId,
    @required this.commentUserId,
    @required this.name,
    @required this.content,
    @required this.regDt,
    @required this.likeFlag,
    @required this.profileImageUrl,
  });

  factory JRegisterCommentInfo.fromJson(Map<dynamic, dynamic> json){
    return JRegisterCommentInfo(
      commentId: json['comment_id'],
      commentUserId: json['comment_user_id'],
      name: json['name'],
      content: json['content'],
      regDt: json['reg_dt'],
      likeFlag: json['like_flag'],
      profileImageUrl: json['profile_image_url'],
    );
  }
}


