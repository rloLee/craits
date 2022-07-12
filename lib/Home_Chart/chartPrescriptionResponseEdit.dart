import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/Home_Chart/chartDetail.dart';
import 'package:craits/Home_Chart/newMedicineAdd.dart';
import 'package:craits/MyWidget/customDropdown.dart';
import 'package:craits/_JClass/recordResult.dart';
import 'package:craits/MyWidget/calendar.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/recordInfo.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'similarMedicineSelect.dart';
import 'similarHospitalSelect.dart';


Map<String, String> numbers = {};

// ignore: must_be_immutable
class ChartPrescriptionResponseEdit extends StatefulWidget {
  ChartPrescriptionResponseEdit(this.recordInfo, this.onApply){
    recordEditInfo = recordInfo.clone();
  }
  final JRecordInfoPInfo recordInfo;
  final Function onApply;
  JRecordInfoPInfo recordEditInfo;

  @override
  _ChartPrescriptionResponseEditState createState() => _ChartPrescriptionResponseEditState();
}

class _ChartPrescriptionResponseEditState extends State<ChartPrescriptionResponseEdit> {
  DateInfo publishedDate;
  List<JRecordInfoMedicineListUnit> newMedicines = [];

  @override
  void initState() {
    publishedDate = DateInfo(recordEditInfo: widget.recordEditInfo);
    
    //드롭다운리스트(투약량,횟수,일수)
    for(int i = 0; i <= 99; i++){
      numbers[i.toString()] = i.toString();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:AppBar(
        elevation: 1.0,
        title: Text('정보 수정'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'), 
        onPressed: (){
          Navigator.pop(context);
        })),
      body: widget.recordEditInfo !=null
        ? GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: Container(
            color: Color(0xFFF2F4F6),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HospitalInfo(recordEditInfo: widget.recordEditInfo, recordInfo: widget.recordInfo),
                  //기존 의약품목록
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.recordEditInfo.medicineList.length,
                    itemBuilder: (context,i){
                      return MedicineInfo(medicineEditUnit: widget.recordEditInfo.medicineList[i], medicineUnit: widget.recordInfo.medicineList[i],);
                  }),
                  //새로추가한의약품목록
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: newMedicines.length,
                    itemBuilder: (context,i){
                      return NewMedicineInfo(
                        medicineEditUnit: newMedicines[i], 
                        onDelete:(){
                          setState(() {
                            newMedicines.removeAt(i);
                          });
                        }
                      );
                  }),
                  Container(
                    color: Colors.white,
                    alignment: Alignment.centerRight,
                    child: MaterialButton(
                      padding: EdgeInsets.zero,
                      child: Text('의약품 추가', style: Theme.of(context).textTheme.button,),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> NewMedicineAdd(onApply: (medicine){
                          JRecordInfoMedicineListUnit newMedicine = JRecordInfoMedicineListUnit(
                            seq: '',
                            id: medicine.id,
                            name: medicine.name,
                            match: 'Y',
                            doseSize: '0',
                            doseDays: '0',
                            doseNumber: '0',
                          );
                          setState(() {
                            newMedicines.add(newMedicine);
                          });
                        })));
                      },
                    ),
                  ),
                  publishedDate,
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 15, 15, 15),
                    child: DefaultButton(
                      text: '저장완료',
                      onPressed: (){
                        postData();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        : Container(
          width: double.infinity,
          child: Center(
            child: CircularProgressIndicator(
              ),
              widthFactor: 0.5,
              heightFactor: 2,
          ),
        ),
    );
  }

  
  Future postData() async{
    try{
      final uri = Uri.parse(commonUri + '/V1/MedicalRecord/RegisterRecord.json');
      
      Map<dynamic, dynamic> paramInfo = {
        'user_auth_id' : user.userAuthId,
        'record_id' : widget.recordInfo.recordId,
      };
      
      widget.recordEditInfo.medicineList.addAll(newMedicines);
      paramInfo.addAll(widget.recordEditInfo.toJson());

      showDialog(
        barrierDismissible: false,
        context: context, builder: (context) //Indigator 보여주기
      => AlertDialog( 
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        content: SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(child: CircularProgressIndicator()),
              Text('저장 중입니다.', style: Theme.of(context).textTheme.bodyText1,)
            ],
          ),),
        )
      );

      ///////////////http Post
      var body = json.encode(paramInfo);
      http.Response response = await http.post(uri, 
        headers: {"Content-Type": "application/json"},
        body: body
      ).timeout(timeoutDuration);

      Navigator.pop(context); //Indigator 닫기

      JRecordResult _recordResult;
      if(response.statusCode == 200){
        _recordResult = JRecordResult.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_recordResult.resultCode == 'SUCC'){
          if(_recordResult.info.bundleId.isNotEmpty){
            Navigator.pop(context); //닫기
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChartDetail(searchBundleId: _recordResult.info.bundleId, tabIndex: 0,)));
          }
          else 
            Navigator.pop(context); //닫기
          widget.onApply(); //피드-진료기록 새로고침
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              content: Text('오류가 발생했습니다.'))
            );
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
      }
    } on TimeoutException catch(_){
      Navigator.pop(context); //닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
      
    } catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }
}

class TextFieldInfo extends StatelessWidget {
  final String title;
  final String initText;
  final TextInputType inputType;
  final TextEditingController controller = TextEditingController();

  TextFieldInfo({
    @required this.title,
    @required this.initText,
    this.inputType = TextInputType.text
  }){
    controller.text = initText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
          SizedBox(height: 5,),
          TextField(
            controller: controller,
            keyboardType: inputType,
            cursorColor: Theme.of(context).primaryColor,
            style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
            decoration: InputDecoration(
              contentPadding:EdgeInsets.fromLTRB(10, 10, 10, 0),
              filled: true,
              fillColor: Color(0xFFF3F3F3),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFEAEAEA),
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
        ],
      ),
    );
  }

  setText(String text){
    controller.text = text;
  }

  String finalText(){
    return controller.text;
  }
}

class MedicineInfo extends StatefulWidget {
  MedicineInfo({
    @required this.medicineEditUnit, 
    @required this.medicineUnit, 
  });
  final JRecordInfoMedicineListUnit medicineEditUnit;
  final JRecordInfoMedicineListUnit medicineUnit;

  @override
  _MedicineInfoState createState() => _MedicineInfoState();
}

class _MedicineInfoState extends State<MedicineInfo> {
  String match;
  String valueChooseDoseSizeMatch = 'Y';
  String valueChooseDoseNumberMatch = 'Y';
  String valueChooseDoseDaysMatch = 'Y';

  @override
  void initState() {
    super.initState();
    match = widget.medicineUnit.match;
    
    if(widget.medicineEditUnit.doseSize == '0')
      valueChooseDoseSizeMatch = 'N';

    if(widget.medicineEditUnit.doseNumber == '0')
      valueChooseDoseNumberMatch = 'N';

    if(widget.medicineEditUnit.doseDays == '0')
      valueChooseDoseDaysMatch = 'N';
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('의약품명', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
          SizedBox(height: 5,),
          MaterialButton(
            padding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 45),
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFFF3F3F3),
                border: Border.all(
                  color: (match == 'Y')
                  ? const Color (0xFFEAEAEA)
                  : const Color(0xFFEC7676),
                )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(widget.medicineEditUnit.name?? '', style: TextStyle(color: (match == 'Y')
                                    ? const Color(0xFF262626)
                                    : const Color(0xFFEC7676), 
                              fontWeight: FontWeight.w500),
                              ),
                      ),
                        SvgPicture.asset('assets/arrowRight.svg',),
                    ],
                  ),
            ),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context)=> SimilarMedicineSelect(
                  medicine: widget.medicineUnit,
                  onApply: (similarMedicine){
                    setState(() {
                      widget.medicineEditUnit.id = similarMedicine.id;
                      widget.medicineEditUnit.name = similarMedicine.name;
                      match = 'Y';
                    });
                  },)
              ));
            }
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('투약량', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                    SizedBox(height: 5,),
                    Container(
                      width: double.infinity,
                      height: 45,
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color(0xFFF3F3F3),
                        border: Border.all(
                          color:  Color(0xFFEAEAEA)
                        )),
                        child: CustomDropdown(
                          items: numbers,
                          dropdownButtonStyle: DropdownButtonStyle(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                          ),
                          dropdownStyle: DropdownStyle(
                            height: 150,
                            elevation: 5,
                            padding: EdgeInsets.all(10),
                          ),
                          dropdownItemStyle: DropdownItemStyle(
                            height: 30,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                            highlightColor: Theme.of(context).primaryColor.withOpacity(0.1)
                          ),
                          icon: SvgPicture.asset('assets/arrowDown.svg'),
                          child: Text(widget.medicineEditUnit.doseSize, style: Theme.of(context).textTheme.bodyText1),
                          onChange: (value, key) {
                            setState(() {
                              widget.medicineEditUnit.doseSize = key;
                              valueChooseDoseSizeMatch = 'Y';
                            });
                          },
                        )
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('횟수', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                    SizedBox(height: 5,),
                    Container(
                      width: double.infinity,
                      height: 45,
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color(0xFFF3F3F3),
                        border: Border.all(
                          color:  Color(0xFFEAEAEA)
                        )),
                        child: CustomDropdown(
                          items: numbers,
                          dropdownButtonStyle: DropdownButtonStyle(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                          ),
                          dropdownStyle: DropdownStyle(
                            height: 150,
                            elevation: 5,
                            padding: EdgeInsets.all(10),
                          ),
                          dropdownItemStyle: DropdownItemStyle(
                            height: 30,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                            highlightColor: Theme.of(context).primaryColor.withOpacity(0.1)
                          ),
                          icon: SvgPicture.asset('assets/arrowDown.svg'),
                          child: Text(widget.medicineEditUnit.doseNumber, style: Theme.of(context).textTheme.bodyText1),
                          onChange: (value, key) {
                            setState(() {
                              widget.medicineEditUnit.doseNumber = key;
                              valueChooseDoseNumberMatch = 'Y';
                            });
                          },
                        )
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15,),
              //횟수 valueChooseDoseDaysMatch
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('일수', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                    SizedBox(height: 5,),
                    Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color(0xFFF3F3F3),
                        border: Border.all(
                          color: (valueChooseDoseDaysMatch == 'Y')? Color(0xFFEAEAEA) : Color(0xFFEC7676)
                        )),
                        child: CustomDropdown(
                          items: numbers,
                          dropdownButtonStyle: DropdownButtonStyle(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                          ),
                          dropdownStyle: DropdownStyle(
                            height: 150,
                            elevation: 5,
                            padding: EdgeInsets.all(10),
                          ),
                          dropdownItemStyle: DropdownItemStyle(
                            height: 30,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                            highlightColor: Theme.of(context).primaryColor.withOpacity(0.1)
                          ),
                          icon: SvgPicture.asset('assets/arrowDown.svg'),
                          child: Text(widget.medicineEditUnit.doseDays, style: Theme.of(context).textTheme.bodyText1),
                          onChange: (value, key) {
                            setState(() {
                              widget.medicineEditUnit.doseDays = key;
                              valueChooseDoseDaysMatch = 'Y';
                            });
                          },
                        )
                    ),
                  ],
                ),
              ),
          ],)
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class NewMedicineInfo extends StatefulWidget {
  NewMedicineInfo({
    @required this.medicineEditUnit, 
    @required this.onDelete, 
  });
  JRecordInfoMedicineListUnit medicineEditUnit;
  final Function onDelete;

  @override
  _NewMedicineInfoState createState() => _NewMedicineInfoState();
}

class _NewMedicineInfoState extends State<NewMedicineInfo> {
  String match;
  String valueChooseDoseSizeMatch = 'Y';
  String valueChooseDoseNumberMatch = 'Y';
  String valueChooseDoseDaysMatch = 'Y';

  @override
  void initState() {
    super.initState();
    
    if(widget.medicineEditUnit.doseSize == '0')
      valueChooseDoseSizeMatch = 'N';

    if(widget.medicineEditUnit.doseNumber == '0')
      valueChooseDoseNumberMatch = 'N';

    if(widget.medicineEditUnit.doseDays == '0')
      valueChooseDoseDaysMatch = 'N';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Text('의약품명', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
            MaterialButton(
              padding: EdgeInsets.zero,
              minWidth: 0,
              height: 0,
              child: SvgPicture.asset('assets/close.svg', ),
              onPressed: widget.onDelete
            ) ,
          ],),
          SizedBox(height: 5,),
          Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 45),
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color(0xFFF3F3F3),
              border: Border.all(color:Color(0xFFEAEAEA))),
            child: Text(widget.medicineEditUnit.name, style: TextStyle(color: Color(0xFF262626), fontWeight: FontWeight.w500, fontSize: 14.0 ), ),
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              //투약량 valueChooseDoseSize
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('투약량', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                    SizedBox(height: 5,),
                    Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color(0xFFF3F3F3),
                        border: Border.all(
                          color: (valueChooseDoseSizeMatch == 'Y')? Color(0xFFEAEAEA) : Color(0xFFEC7676)
                        )),
                        child: CustomDropdown(
                          items: numbers,
                          dropdownButtonStyle: DropdownButtonStyle(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                          ),
                          dropdownStyle: DropdownStyle(
                            height: 150,
                            elevation: 5,
                            padding: EdgeInsets.all(10),
                          ),
                          dropdownItemStyle: DropdownItemStyle(
                            height: 30,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                            highlightColor: Theme.of(context).primaryColor.withOpacity(0.1)
                          ),
                          icon: SvgPicture.asset('assets/arrowDown.svg'),
                          child: Text(widget.medicineEditUnit.doseSize, style: Theme.of(context).textTheme.bodyText1),
                          onChange: (value, key) {
                            setState(() {
                              widget.medicineEditUnit.doseSize = key;
                              valueChooseDoseSizeMatch = 'Y';
                            });
                          },
                        )
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15,),
              //횟수 valueChooseDoseNumberMatch
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('횟수', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                    SizedBox(height: 5,),
                    Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color(0xFFF3F3F3),
                        border: Border.all(
                          color: (valueChooseDoseNumberMatch == 'Y')? Color(0xFFEAEAEA) : Color(0xFFEC7676)
                        )),
                        child: CustomDropdown(
                          items: numbers,
                          dropdownButtonStyle: DropdownButtonStyle(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                          ),
                          dropdownStyle: DropdownStyle(
                            height: 150,
                            elevation: 5,
                            padding: EdgeInsets.all(10),
                          ),
                          dropdownItemStyle: DropdownItemStyle(
                            height: 30,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                            highlightColor: Theme.of(context).primaryColor.withOpacity(0.1)
                          ),
                          icon: SvgPicture.asset('assets/arrowDown.svg'),
                          child: Text(widget.medicineEditUnit.doseNumber, style: Theme.of(context).textTheme.bodyText1),
                          onChange: (value, key) {
                            setState(() {
                              widget.medicineEditUnit.doseNumber = key;
                              valueChooseDoseNumberMatch = 'Y';
                            });
                          },
                        )
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15,),
              //횟수 valueChooseDoseDaysMatch
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('일수', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                    SizedBox(height: 5,),
                    Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color(0xFFF3F3F3),
                        border: Border.all(
                          color: (valueChooseDoseDaysMatch == 'Y')? Color(0xFFEAEAEA) : Color(0xFFEC7676)
                        )),
                        child: CustomDropdown(
                          items: numbers,
                          dropdownButtonStyle: DropdownButtonStyle(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                          ),
                          dropdownStyle: DropdownStyle(
                            height: 150,
                            elevation: 5,
                            padding: EdgeInsets.all(10),
                          ),
                          dropdownItemStyle: DropdownItemStyle(
                            height: 30,
                            textStyle: Theme.of(context).textTheme.bodyText1,
                            highlightColor: Theme.of(context).primaryColor.withOpacity(0.1)
                          ),
                          icon: SvgPicture.asset('assets/arrowDown.svg'),
                          child: Text(widget.medicineEditUnit.doseDays, style: Theme.of(context).textTheme.bodyText1),
                          onChange: (value, key) {
                            setState(() {
                              widget.medicineEditUnit.doseDays = key;
                              valueChooseDoseDaysMatch = 'Y';
                            });
                          },
                        )
                    ),
                  ],
                ),
              ),
          ],)
        ],
      ),
    );
  }
}



class HospitalInfo extends StatefulWidget {
  HospitalInfo({
    @required this.recordEditInfo, 
    @required this.recordInfo
    });
  final JRecordInfoPInfo recordEditInfo;
  final JRecordInfoPInfo recordInfo;

  @override
  _HospitalInfoState createState() => _HospitalInfoState();
}

class _HospitalInfoState extends State<HospitalInfo> {
  String match;

@override
  void initState() {
    match = widget.recordInfo.hospitalMatch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('병원 이름', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
          SizedBox(height: 5,),
          MaterialButton(
            padding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 45),
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFFF3F3F3),
                border: Border.all(
                  color: (match == 'Y')
                  ? const Color(0xFFEAEAEA)
                  : const Color(0xFFEC7676),
                )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(widget.recordEditInfo.hospitalName?? '', style: TextStyle(color: (match == 'Y')
                                    ? const Color(0xFF262626)
                                    : const Color(0xFFEC7676), 
                              fontWeight: FontWeight.w500), ),
                      ),
                        SvgPicture.asset('assets/arrowRight.svg',),
                    ],
                  ),
            ),
              onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context)=> SimilarHospitalSelect(
                  hospitalName: widget.recordInfo.hospitalName,
                  hospitalList: widget.recordInfo.hospitalList, 
                  onApply: (similarHospital){
                    setState(() {
                      widget.recordEditInfo.hospitalId = similarHospital.id;
                      widget.recordEditInfo.hospitalName = similarHospital.name;
                      widget.recordEditInfo.hospitalAddr = similarHospital.addr;
                      widget.recordEditInfo.hospitalTel = similarHospital.tel;
                      match = 'Y';
                    });
                  })
                  )
              );
            }
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              SvgPicture.asset('assets/location.svg', width:12),
              SizedBox(width:10),
              Flexible(child: Text(widget.recordEditInfo.hospitalAddr?? '', style: Theme.of(context).textTheme.subtitle2,)),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              SvgPicture.asset('assets/tel.svg', width:12),
              SizedBox(width:10),
              Flexible(child: Text(widget.recordEditInfo.hospitalTel?? '', style: Theme.of(context).textTheme.subtitle2,)),
            ],
          )
        ],
      ),
    );
  }
}

class DateInfo extends StatefulWidget {
  final JRecordInfoPInfo recordEditInfo;
   DateInfo({@required this.recordEditInfo});

  @override
  _DateInfoState createState() => _DateInfoState();
}

class _DateInfoState extends State<DateInfo> {
  String strDate;

  @override
  void initState() {
    strDate = widget.recordEditInfo.publishedDate;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('처방일자', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
          SizedBox(height: 5,),
          MaterialButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: EdgeInsets.all(7.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strDate, style: TextStyle(fontSize: 14.0, color: Color(0xFF262626), fontWeight: FontWeight.w500), textAlign: TextAlign.start,),
                ]
              ),
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),  
                color: const Color(0xFFF3F3F3),
                border: Border.all(
                  color: const Color(0xFFEAEAEA)
                )
              ),
            ),
            onPressed: () async{
              DateTime _dateTime = DateTime.tryParse(strDate) ?? DateTime.now();
              final result = await showDialog(context: context, builder: (context) => MyCalendar(_dateTime, DateRangePickerView.month));
              setState(() {
                if(result != null){
                  strDate = DateFormat('yyyy-MM-dd').format(result).toString();
                  widget.recordEditInfo.publishedDate = strDate;
                }
              });
            }
          ),
        ],
      ),
    );
  }
}