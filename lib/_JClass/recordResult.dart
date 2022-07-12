import 'package:flutter/cupertino.dart';

class JRecordResult{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JRecordResultInfo info;

  JRecordResult({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JRecordResult.fromJson(Map<dynamic, dynamic> json){
    return JRecordResult(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info: JRecordResultInfo.fromJson(json['info']),
    );
  }
}

class JRecordResultInfo{
  final dynamic bundleId;
  final dynamic recordId;
  final dynamic resultType;
  final dynamic durType;

  JRecordResultInfo({
    @required this.bundleId,
    @required this.recordId,
    @required this.resultType,
    @required this.durType,
  });

  factory JRecordResultInfo.fromJson(Map<dynamic, dynamic> json){
    return JRecordResultInfo(
      bundleId: json['bundle_id'],
      recordId: json['record_id'],
      resultType: json['result_type'],
      durType: json['dur_type'],
    );
  }
}
