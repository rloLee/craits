import 'package:flutter/cupertino.dart';

class JBundleList{
  final dynamic resultCode;
  final dynamic resultMsg;
  final dynamic pageNo;
  final List<JBundleListUnit> list;

  JBundleList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.pageNo,
    @required this.list,
  });

  factory JBundleList.fromJson(Map<dynamic, dynamic> json){
    var listJson = json['list'] as List;
    List<JBundleListUnit> _lists = listJson.map((listJson)=>JBundleListUnit.fromJson(listJson)).toList();
      
    return JBundleList(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      pageNo: json['pageNo'],
      list: _lists,
    );
  }
}

class JBundleListUnit{
  final dynamic bundleId;
  final String patientName;
  final String subjectName;
  final String hospitalName;
  final String pharmacyName;
  final String recordDate;
  final List<JRecordList> recordList;

  JBundleListUnit({
    @required this.bundleId,
    @required this.patientName,
    @required this.subjectName,
    @required this.hospitalName,
    @required this.pharmacyName,
    @required this.recordDate,
    @required this.recordList
  });
  
  factory JBundleListUnit.fromJson(Map<dynamic, dynamic> json){

    var recordListJson = json['record_list'] as List;
    List<JRecordList> _recordLists = [];

      
    if(recordListJson != null)
      _recordLists = recordListJson.map((listJson)=> JRecordList.fromJson(listJson)).toList();

    return JBundleListUnit(
      bundleId: json['bundle_id'],
      patientName: json['patient_name'],
      subjectName: json['subject_name'],
      hospitalName: json['hospital_name'],
      pharmacyName: json['pharmacy_name'],
      recordDate: json['record_date'],
      recordList: _recordLists
    );
  }
}

class JRecordList{
  final String recordId;
  final String recordType;
  final String imageUrl;
  final String imageOriginal;

  JRecordList({
    @required this.recordId,
    @required this.recordType,
    @required this.imageUrl,
    @required this.imageOriginal,
  });

  factory JRecordList.fromJson(Map<dynamic, dynamic> json){
    return JRecordList(
      recordId: json['record_id'],
      recordType: json['record_type'],
      imageUrl: json['image_url'],
      imageOriginal: json['image_original'],
    );
  }
}