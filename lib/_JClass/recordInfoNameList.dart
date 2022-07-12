import 'package:flutter/cupertino.dart';

class JRecordNameList{
  final String resultCode;
  final String resultMsg;
  List<JRecordNameListUnit> list;

  JRecordNameList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.list,
  });

  factory JRecordNameList.fromJson(Map<String, dynamic> json){
    var listsJson = json['list'] as List;
    List<JRecordNameListUnit> _lists = [];
    if(listsJson != null)
      _lists = listsJson.map((listJson) => JRecordNameListUnit.fromJson(listJson)).toList();

    
    return JRecordNameList(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      list : _lists
    );
  }
}

class JRecordNameListUnit{
  final String patientName;

  JRecordNameListUnit({
    @required this.patientName,
  });

  factory JRecordNameListUnit.fromJson(Map<String, dynamic> json){
    return JRecordNameListUnit(
      patientName: json['patient_name'],
    );
  }
}


class JRecordHospitalList{
  final String resultCode;
  final String resultMsg;
  List<JRecordHospitalListUnit> list;

  JRecordHospitalList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.list,
  });

  factory JRecordHospitalList.fromJson(Map<String, dynamic> json){
    var listsJson = json['list'] as List;
    List<JRecordHospitalListUnit> _lists = [];
    if(listsJson != null)
      _lists = listsJson.map((listJson) => JRecordHospitalListUnit.fromJson(listJson)).toList();

    
    return JRecordHospitalList(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      list : _lists
    );
  }
}

class JRecordHospitalListUnit{
  final dynamic hospitalId;
  final String hospitalName;

  JRecordHospitalListUnit({
    @required this.hospitalId,
    @required this.hospitalName,
  });

  factory JRecordHospitalListUnit.fromJson(Map<String, dynamic> json){
    return JRecordHospitalListUnit(
      hospitalId: json['hospital_id'],
      hospitalName: json['hospital_name'],
    );
  }
}