import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:craits/_JClass/filterList.dart';
import 'package:http/http.dart' as http;
import 'package:craits/MyWidget/myFilterList.dart';

class MedicineFilterDialog extends StatefulWidget {
  List<JFilterListCategoryUnit> selectedList = [];
  int startPrice; 
  int endPrice;
  Function(List<JFilterListCategoryUnit> selectedList, int startPrice, int endPrice) onApply;

  MedicineFilterDialog({
    @required this.selectedList, 
    this.startPrice, 
    this.endPrice, 
    @required this.onApply});

  @override
  _MedicineFilterDialogState createState() => _MedicineFilterDialogState();
}

class _MedicineFilterDialogState extends State<MedicineFilterDialog> {
  final uri = Uri.parse(commonUri + '/V1/Filter/FilterList.json');
  List<JFilterListCategoryUnit> allList = [];
  List<JFilterListCategoryUnit> selectedList = [];
  List<MyFilterList> myFilterList = [];

  RangeValues _currentRangeValues = const RangeValues(0, 300000);

  Future getFilterData() async{
    var params = {
      'user_auth_id' : user.userAuthId,
      'searchType' : 'MEDICINE'
    };

    final newUri = uri.replace(queryParameters: params);
    http.Response response = await http.get(newUri);
    
    JFilterList filterList;
    if(response.statusCode == 200){
      setState(() {
        filterList = JFilterList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        allList = filterList.categoryList;
        selectedList = allList.map((e) => JFilterListCategoryUnit.clone(e)).toList();
        selectedList.forEach((element) {
          element.filterList = [];
        });
        if(widget.selectedList.length > 0)
        selectedList = widget.selectedList.map((e) => JFilterListCategoryUnit.clone(e)).toList();
      });

    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
    }
  }

@override
  void initState() {
    getFilterData();
    if(widget.startPrice != null && widget.endPrice != null)
      _currentRangeValues = RangeValues(widget.startPrice.toDouble(), widget.endPrice.toDouble());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(0, 200, 0, 0),
      child: Container(
        child: Column(
          children: [
            Container( //상단 바
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: SvgPicture.asset('assets/close.svg') , 
                    onPressed: (){
                      Navigator.pop(context);
                    }),
                  Text('필터', style: Theme.of(context).textTheme.headline5,),
                  TextButton(
                    onPressed: (){
                      setState(() {
                        selectedList.forEach((element) {
                          element.filterList = [];
                        });
                        _currentRangeValues = const RangeValues(0, 300000);
                      });
                      widget.onApply(selectedList, _currentRangeValues.start.round(), _currentRangeValues.end.round());
                      Navigator.pop(context);
                    }, 
                    child: Text('초기화')
                  )
                ],)
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    for(int i = 0; i < allList.length; i++)
                      MyFilterList(
                        headlineText: allList[i].categoryName,
                        listData: allList[i].filterList,
                        selectedListData: selectedList[i].filterList,
                        onChoiceChanged: (list){
                          selectedList[i].filterList = List.from(list);
                        },
                        onItemSearch: (list, text){
                          // if(list.values.any((element) => 
                          //  element.toLowerCase().contains(text.toLowerCase()))){
                              List<JFilterListCategoryUnitFliterUnit> rtnList = [];
                              list.forEach((unit) {
                                if(unit.filterDesc.toLowerCase().contains(text.toLowerCase()))
                                  rtnList.add(unit);
                              });
                              return rtnList;
                          // }
                        },
                      ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('가격', style : Theme.of(context).textTheme.headline1),
                              Text('${_currentRangeValues.start.round().toString()}원 ~ ${_currentRangeValues.end.round().toString()}원'
                              , style : Theme.of(context).textTheme.headline2),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: RangeSlider(
                              values: _currentRangeValues,
                              min: 0,
                              max: 300000,
                              divisions: 300,
                              labels:  RangeLabels(
                                _currentRangeValues.start.round().toString(),
                                _currentRangeValues.end.round().toString(),
                              ),
                              onChanged:(values){
                                setState(() {
                                  _currentRangeValues = values;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              child: MaterialButton(
                child: Text('필터 적용', style: TextStyle(color:Colors.white, fontSize: 16),), 
                  onPressed: (){
                    widget.onApply(selectedList, _currentRangeValues.start.round(), _currentRangeValues.end.round());
                    Navigator.pop(context);
                  }, 
                ), 
              )
        ],),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight:  Radius.circular(20))
      ),
    );
  }
} 