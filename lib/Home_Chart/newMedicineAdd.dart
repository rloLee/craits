import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/_JClass/medicineList.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/recordInfo.dart';
import 'package:http/http.dart' as http;

//
//진료기록쓰기 사진 등록 후 응답 정보수정  화면(~ResponseEdit)에서 ‘의약품 추가’ 클릭 시 화면
//

class NewMedicineAdd extends StatelessWidget {
  final Function(JRecordInfoMedicineSimilarListUnit similarMedicine) onApply;
  NewMedicineAdd({
    @required this.onApply
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar:AppBar(
            elevation: 1.0,
            title: Text('의약품명'),
            iconTheme: IconThemeData(
              color: Colors.black87
            ),
          ), 
          body: InputSelect(onApply),
      ),
    );
  }
}

class InputSelect extends StatefulWidget {
  final Function(JRecordInfoMedicineSimilarListUnit similarMedicine) onApply;
  InputSelect(this.onApply);

  @override
  _InputSelectState createState() => _InputSelectState();
}

class _InputSelectState extends State<InputSelect> {
  int selectedIndex = -1;
  bool bLoading = false;
  JMedicineList medicineList; 
  JRecordInfoMedicineSimilarListUnit medicine;
  String oldText;

  Future getName(String text) async{
    final uri = Uri.parse(commonUri + '/V1/Medicine/MedicineList.json');
    try{
      setState(() {
        bLoading = true;
      });
      var params = {
        'user_auth_id' : user.userAuthId,
        'searchKeyword' : text, //검색어
        'searchFilterSeqs' : '', //"필터 seq 배열 : 선택된 필터 항목 배열[1, 2, 3, 4 ... 99]"
        'searchPrices': '', // 배열 [최소가격,최대가격]
        'searchPageNo' : '1',
        'searchPageSize' : '5', //페이지 크기 (기본 : 10)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(Duration(seconds: 10));

      JMedicineList _medicineList;
      if(response.statusCode == 200){
        _medicineList = JMedicineList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        setState(() {
          bLoading = false;
        });
      }
      setState(() {
        medicineList = _medicineList;
      });
      
      setState(() {
        bLoading = false;
      });
    } on TimeoutException catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
      setState(() {
        bLoading = false;
      });
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text('직접 입력해 주세요.', style: Theme.of(context).textTheme.headline1,),
              SizedBox(height: 20,),
              TextField(
                onChanged: (value){
                  if(oldText != value){
                    setState(() {
                      selectedIndex = -1;
                      medicine = null;
                      oldText = value;
                    });
                    if(value.length > 0)
                      getName(value);
                    else
                      setState(() {
                        medicineList = null;
                      });
                  }
                },
                cursorColor: Theme.of(context).primaryColor,
                cursorHeight: 20,
                style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                decoration: InputDecoration(
                  contentPadding:EdgeInsets.all(10),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: const Color(0xFFEAEAEA),
                      width: 1
                      ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFFEAEAEA),
                      width: 1
                      ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              if(bLoading)
                FractionallySizedBox(
                  widthFactor: 1,
                  child: Center(
                    child: CircularProgressIndicator(
                    ),
                  ),
                )
              else
                Expanded(
                  child: (medicineList != null && medicineList.info != null)?
                    ListView.builder(
                      itemCount: medicineList.info.list.length,
                      itemBuilder: (context, index){
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title:  MaterialButton(
                            padding: EdgeInsets.zero,
                            child: Container(
                              constraints: BoxConstraints(minHeight: 50),
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color:  Colors.white,
                                border: Border.all(
                                  color: (selectedIndex == index)
                                  ? Theme.of(context).primaryColor
                                  : Color(0xFFEAEAEA),
                                )),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(medicineList.info.list[index].medicineNm, style: TextStyle(color: (selectedIndex == index)
                                                ? Theme.of(context).primaryColor 
                                                : const Color(0xFF9F9F9F), 
                                          fontWeight: FontWeight.w500), ),
                                      ),
                                    ],
                                  ),
                            ),
                            onPressed: (){
                              FocusScope.of(context).unfocus();
                              setState(() {
                                selectedIndex = index;
                                medicine = JRecordInfoMedicineSimilarListUnit(
                                  id: medicineList.info.list[index].id, 
                                  name: medicineList.info.list[index].medicineNm,  
                                  similar: null
                                  );
                              });
                            }
                          )
                        );
                    }) : Container(),
                ),
              ],
            ),
          ),
        ),
        MaterialButton(
          minWidth: double.infinity,
          height: 48,
          color: Theme.of(context).primaryColor, 
          padding: EdgeInsets.zero,
          disabledColor: Theme.of(context).disabledColor,
          child: Text('확인', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white),),
          onPressed: 
            medicine != null ?
            (){
              widget.onApply(medicine);
              Navigator.pop(context);
            }
            : null,
        ),
      ],
    );
  }
}