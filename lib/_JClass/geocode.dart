import 'package:flutter/cupertino.dart';
class JGeocode{
  final String status;
  final String errorMessage;
  final JGeocodeMeta meta; 
  final List<JGeocodeAddressUnit> addresses;

  JGeocode({
    @required this.status,
    @required this.errorMessage,
    @required this.meta,
    @required this.addresses,
  });

  factory JGeocode.fromJson(Map<String, dynamic> json){
    var listJson = json['addresses'] as List;
    List<JGeocodeAddressUnit> _lists = [];

    if(listJson != null)
      _lists = listJson.map((listJson)=>JGeocodeAddressUnit.fromJson(listJson)).toList();


    return JGeocode(
      status: json['status'],
      errorMessage: json['errorMessage'],
      meta: JGeocodeMeta.fromJson(json['meta']),
      addresses: _lists,
    );
  }
}

class JGeocodeMeta{
  final int totalCount;
  final int page;
  final int count;

  JGeocodeMeta({
    @required this.totalCount,
    @required this.page,
    @required this.count
  });

  factory JGeocodeMeta.fromJson(Map<String, dynamic> json){
    return JGeocodeMeta(
      totalCount: json['totalCount'],
      page: json['page'],
      count: json['count'],
    );
  }
}

class JGeocodeAddressUnit{
  final String jibunAddress;
  final String roadAddress;
  final String englishAddress;
  final String x;
  final String y;
  
  JGeocodeAddressUnit({
    @required this.jibunAddress,
    @required this.roadAddress,
    @required this.englishAddress,
    @required this.x,
    @required this.y,
  });

  factory JGeocodeAddressUnit.fromJson(Map<String, dynamic> json){
    return JGeocodeAddressUnit(
      roadAddress: json['roadAddress'],
      jibunAddress: json['jibunAddress'],
      englishAddress: json['englishAddress'],
      x: json['x'],
      y: json['y'],
    );
  }
}