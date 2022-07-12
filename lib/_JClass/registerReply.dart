import 'package:flutter/cupertino.dart';

class JRegisterReply{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JRegisterReplyInfo info;

  JRegisterReply({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JRegisterReply.fromJson(Map<dynamic, dynamic> json){
    return JRegisterReply(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info: JRegisterReplyInfo.fromJson(json['info']), 
    );
  }
}

class JRegisterReplyInfo{
  final dynamic replyId;
  final dynamic replyUserId;
  final dynamic name;
  final dynamic content;
  final dynamic regDt;
  final dynamic likeFlag;
  final dynamic profileImageUrl;

  JRegisterReplyInfo({
    @required this.replyId,
    @required this.replyUserId,
    @required this.name,
    @required this.content,
    @required this.regDt,
    @required this.likeFlag,
    @required this.profileImageUrl,
  });

  factory JRegisterReplyInfo.fromJson(Map<dynamic, dynamic> json){
    return JRegisterReplyInfo(
      replyId: json['reply_id'],
      replyUserId: json['reply_user_id'],
      name: json['name'],
      content: json['content'],
      regDt: json['reg_dt'],
      likeFlag: json['like_flag'],
      profileImageUrl: json['profile_image_url'],
    );
  }
}