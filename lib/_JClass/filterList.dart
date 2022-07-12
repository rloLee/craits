import 'package:flutter/cupertino.dart';

class JFilterList{

  final dynamic resultCode;
  final dynamic resultMsg;
  final List<JFilterListCategoryUnit> categoryList;

  JFilterList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.categoryList,
  });

  factory JFilterList.fromJson(Map<dynamic, dynamic> json){
    var listJson = json['category_list'] as List;
    List<JFilterListCategoryUnit> _lists = [];
    if(listJson != null)
      _lists = listJson.map((listJson) => JFilterListCategoryUnit.fromJson(listJson)).toList();

    return JFilterList(
      resultCode: json['resultCode'], 
      resultMsg: json['resultMsg'], 
      categoryList: _lists,
    );
  }
}

class JFilterListCategoryUnit{
  final dynamic no;
  final dynamic categorySeq;
  final dynamic categoryName;
   List<JFilterListCategoryUnitFliterUnit> filterList;

  JFilterListCategoryUnit({
    @required this.no,
    @required this.categorySeq,
    @required this.categoryName,
    @required this.filterList,
  });

  factory JFilterListCategoryUnit.fromJson(Map<dynamic, dynamic> json){
    var listJson = json['filter_list'] as List;
    List<JFilterListCategoryUnitFliterUnit> _lists = [];
    if(listJson != null)
      _lists = listJson.map((listJson) => JFilterListCategoryUnitFliterUnit.fromJson(listJson)).toList();

    return JFilterListCategoryUnit(
      no: json['no'], 
      categorySeq: json['category_seq'], 
      categoryName: json['category_name'], 
      filterList: _lists,
    );
  }

  factory JFilterListCategoryUnit.clone(JFilterListCategoryUnit source){
    return JFilterListCategoryUnit(
      no: source.no,
      categorySeq: source.categorySeq,
      categoryName: source.categoryName,
      filterList: source.filterList.map((e) => JFilterListCategoryUnitFliterUnit.clone(e)).toList()
    );
  }
  
  // JFilterListCategoryUnit clone() {
  //   final jsonResponse = json.decode(json.encode(this));
  //   return JFilterListCategoryUnit.fromJson(jsonResponse as Map<dynamic, dynamic>);
  // }

  // Map<dynamic, dynamic> toJson()=>
  // {
  //   'no' : no,
  //   'categorySeq' : categorySeq,
  //   'categoryName' : categoryName,
  //   'filterList' : filterList.map((e) => e.clone().toJson()).toList(),
  // };
}

class JFilterListCategoryUnitFliterUnit{
  final dynamic no;
  final dynamic filterSeq;
  final dynamic filterDesc;

  JFilterListCategoryUnitFliterUnit({
    @required this.no,
    @required this.filterSeq,
    @required this.filterDesc,
  });

  factory JFilterListCategoryUnitFliterUnit.fromJson(Map<dynamic, dynamic> json){
    return JFilterListCategoryUnitFliterUnit(
      no: json['no'], 
      filterSeq: json['filter_seq'], 
      filterDesc: json['filter_desc']
    );
  }
  
  factory JFilterListCategoryUnitFliterUnit.clone(JFilterListCategoryUnitFliterUnit source){
    return JFilterListCategoryUnitFliterUnit(
      no: source.no,
      filterSeq: source.filterSeq,
      filterDesc: source.filterDesc,
    );
  }
  // JFilterListCategoryUnitFliterUnit clone() {
  //   final jsonResponse = json.decode(json.encode(this));
  //   return JFilterListCategoryUnitFliterUnit.fromJson(jsonResponse as Map<dynamic, dynamic>);
  // }

  // Map<dynamic, dynamic> toJson()=>
  // {
  //   'no' : no,
  //   'filterSeq' : filterSeq,
  //   'filterDesc' : filterDesc,
  // };
}