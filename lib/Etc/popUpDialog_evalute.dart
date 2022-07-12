import 'dart:convert';

import 'package:craits/Common/com.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//
//진료기록 – 평가하기버튼 클릭시 팝업 화면
//

class PopupEvalute extends StatefulWidget {
  final  String bundleId;
  PopupEvalute({@required this.bundleId});
  @override
  State<PopupEvalute> createState() => _PopupEvaluteState();
}

class _PopupEvaluteState extends State<PopupEvalute> {
  bool bAche = false;
  bool bEffect = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          const Radius.circular(8.0),
        ),
      ),
      child: Container(
        width: 300,
        height: 250 ,
        child: Column(
          children: [
            Expanded(
              child: Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('약 복용 후 속쓰림이 있나요?', style: Theme.of(context).textTheme.headline4,),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            setState(() {
                              bAche = true;
                            });
                          },
                          child: Row(
                            children:[
                              (bAche)?
                                Icon(Icons.check_circle, color: Theme.of(context).primaryColor,)
                              : Icon(Icons.circle_outlined, color: Color(0xFFC4C4C4),),
                              SizedBox(width: 5 ,),
                              Text('예', style: TextStyle(fontSize: 16.0),),
                            ]
                          ),
                        ),
                        SizedBox(width: 30,),
                        InkWell(
                          onTap: (){
                            setState(() {
                              bAche = false;
                            });
                          },
                          child: Row(
                            children:[
                              (!bAche)?
                                Icon(Icons.check_circle, color: Theme.of(context).primaryColor,)
                              :
                                Icon(Icons.circle_outlined, color: Color(0xFFC4C4C4), ),
                            SizedBox(width: 5 ,),
                            Text('아니요', style: TextStyle(fontSize: 16.0),),
                            ]
                          ),
                        ),
                    ],),
                    Divider(height: 40,),
                    Text('효과가 있나요?', style: Theme.of(context).textTheme.headline4),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            setState(() {
                              bEffect = true;
                            });
                          },
                          child: Row(
                            children:[
                              (bEffect)?
                                Icon(Icons.check_circle, color: Theme.of(context).primaryColor,)
                              :
                                Icon(Icons.circle_outlined, color: Color(0xFFC4C4C4), ),
                            SizedBox(width: 5 ,),
                            Text('예', style: TextStyle(fontSize: 16.0),),
                            ]
                          ),
                        ),
                        SizedBox(width: 30,),
                        InkWell(
                          onTap: (){
                            setState(() {
                              bEffect = false;
                            });
                          },
                          child: Row(
                            children:[
                              (!bEffect)?
                                Icon(Icons.check_circle, color: Theme.of(context).primaryColor,)
                              :
                                Icon(Icons.circle_outlined, color: Color(0xFFC4C4C4), ),
                            SizedBox(width: 5 ,),
                            Text('아니요', style: TextStyle(fontSize: 16.0),),
                            ]
                          ),
                        ),
                    ],),
                  ],
                ),
              ),
            ),
            Container(
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: 
                    const Radius.circular(8.0),
                  ),
                ),
                minWidth: double.infinity,
                height: 48,
                color: Theme.of(context).primaryColor, 
                padding: EdgeInsets.zero,
                disabledColor: Theme.of(context).disabledColor,
                child: Text('확인', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white),),
                onPressed:  (){
                  pushResponse();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  pushResponse() async{
    try {
      final uri = Uri.parse(commonUri + '/V1/MedicalRecord/EvaluteBundle.json'); 
      List<Map<dynamic,dynamic>> evaluteValues = [
        {'evalute_type': '1', 'evalute_value' : bAche? '0':'1'},
        {'evalute_type': '2', 'evalute_value' : bEffect? '0':'1'}
      ];
      Map<dynamic, dynamic> params = {
        'user_auth_id' : user.userAuthId,
        'bundle_id' : widget.bundleId,
        'evalute_values': evaluteValues.map((e) => e).toList()
      };
      
      // JEvaluteBundle a = JEvaluteBundle(evaluteValues: [
      //   JEvaluteValues(evaluteType: '1', evaluteValue: bAche? '0':'1'),
      //   JEvaluteValues(evaluteType: '2', evaluteValue: bEffect? '0':'1'),
      // ]);

      /////////////http Post
      var body = json.encode(params);
      http.post(uri, 
        headers: {"Content-Type": "application/json"},
        body: body
      ).timeout(timeoutDuration);
    } 
    catch(_) {

    }
  }
}
class JEvaluteBundle{
  final List<JEvaluteValues> evaluteValues;

  JEvaluteBundle({
    @required this.evaluteValues,
  });
  
  Map<dynamic, dynamic> toJson()=>
  {
    'evalute_values' : evaluteValues.map((e) => e.toJson()).toList(),
  };
}

  class JEvaluteValues{
    final String evaluteType;
    final String evaluteValue;

    JEvaluteValues({
      @required this.evaluteType,
      @required this.evaluteValue,
    });
      
    Map<dynamic, dynamic> toJson()=>
    {
      'evalute_type' : evaluteType,
      'evalute_value' : evaluteValue,
    };
  }