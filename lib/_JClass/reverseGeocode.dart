import 'package:flutter/cupertino.dart';
class JReverseGeocode{
  final JReverseGeocodeStatus status;
  final List<JReverseGeocodeResults> results;
  
  JReverseGeocode({
    @required this.status,
    @required this.results,
  });

  factory JReverseGeocode.fromJson(Map<String, dynamic> json){
    var listJson = json['results'] as List;
    List<JReverseGeocodeResults> _lists = [];

    if(listJson != null)
      _lists = listJson.map((listJson)=>JReverseGeocodeResults.fromJson(listJson)).toList();


    return JReverseGeocode(
      status: JReverseGeocodeStatus.fromJson(json['status']),
      results: _lists,
    );
  }
}

class JReverseGeocodeStatus{
  final int code;
  final String name;
  final String message;

  JReverseGeocodeStatus({
    @required this.code,
    @required this.name,
    @required this.message
  });

  factory JReverseGeocodeStatus.fromJson(Map<String, dynamic> json){
    return JReverseGeocodeStatus(
      code: json['code'],
      name: json['name'],
      message: json['message'],
    );
  }
}

class JReverseGeocodeResults{
  final String name;
  final JReverseGeocodeResultsCode code;
  final JReverseGeocodeResultsRegion region;
  
  JReverseGeocodeResults({
    @required this.name,
    @required this.code,
    @required this.region,
  });

  factory JReverseGeocodeResults.fromJson(Map<String, dynamic> json){
    return JReverseGeocodeResults(
      name: json['name'],
      code: JReverseGeocodeResultsCode.fromJson(json['code']),
      region: JReverseGeocodeResultsRegion.fromJson(json['region']),
    );
  }
}

class JReverseGeocodeResultsCode{
  final String id;
  final String type;
  final String mappingId;

  JReverseGeocodeResultsCode({
    @required this.id,
    @required this.type,
    @required this.mappingId,
  });

  factory JReverseGeocodeResultsCode.fromJson(Map<String, dynamic> json){
    return JReverseGeocodeResultsCode(
      id: json['id'],
      type: json['type'],
      mappingId: json['mappingId'],
    );
  }
}

class JReverseGeocodeResultsRegion{
  final JReverseGeocodeResultsRegionArea area0;
  final JReverseGeocodeResultsRegionArea area1;
  final JReverseGeocodeResultsRegionArea area2;
  final JReverseGeocodeResultsRegionArea area3;
  final JReverseGeocodeResultsRegionArea area4;

  JReverseGeocodeResultsRegion({
    @required this.area0,
    @required this.area1,
    @required this.area2,
    @required this.area3,
    @required this.area4,
  });

  factory JReverseGeocodeResultsRegion.fromJson(Map<String, dynamic> json){
    return JReverseGeocodeResultsRegion(
      area0: JReverseGeocodeResultsRegionArea.fromJson(json['area0']),
      area1: JReverseGeocodeResultsRegionArea.fromJson(json['area1']),
      area2: JReverseGeocodeResultsRegionArea.fromJson(json['area2']),
      area3: JReverseGeocodeResultsRegionArea.fromJson(json['area3']),
      area4: JReverseGeocodeResultsRegionArea.fromJson(json['area4']),
    );
  }

}

class JReverseGeocodeResultsRegionArea{
  final String name;

  JReverseGeocodeResultsRegionArea({
    @required this.name
  });

  factory JReverseGeocodeResultsRegionArea.fromJson(Map<String, dynamic> json){
    return JReverseGeocodeResultsRegionArea(name: json['name']);
  }
}