import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:craits/mainHome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
//
//푸시 팝업화면(주차장 무료여부)
//

class PopupParkFree extends StatelessWidget {
  final Map<String,dynamic> data; 
  PopupParkFree({Key key, this.data});

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
        height: 350,
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset('assets/park.svg', ),
            SizedBox(height: 10,),
            Text(data['name'] + ' 님' , style: Theme.of(context).textTheme.headline1,),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: '이용하신 병원의',style: TextStyle(fontSize: 18.0, color: Color(0xFF262626), fontFamily: 'SpoqaHanSansNeo',), ),
                  TextSpan(text: '\n',style: TextStyle(fontSize: 18.0)),
                  TextSpan(text: '주차장은 ',style: TextStyle(fontSize: 18.0, color: Color(0xFF262626), fontFamily: 'SpoqaHanSansNeo',), ),
                  TextSpan(text: '무료',style: TextStyle(fontSize: 18.0, color: Theme.of(context).primaryColor, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.w700), ),
                  TextSpan(text: '인가요?',style: TextStyle(fontSize: 18.0, color: Color(0xFF262626), fontFamily: 'SpoqaHanSansNeo',), ),
                ])),
            SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: DefaultButton(
                    text: '아니요', fontsize: 18.0, fontWeight: FontWeight.normal,
                    color: Colors.white, 
                    fontColor: Theme.of(context).primaryColor,
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    onPressed: (){
                      pushResponse(data['result_id'], '0');
                      Navigator.pop(context);
                    },),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: DefaultButton(
                    text: '네', fontsize: 18.0, fontWeight: FontWeight.normal,
                    onPressed: (){
                      pushResponse(data['result_id'], '1');
                      Navigator.pop(context);
                    },),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  pushResponse(String resultId, String value) async{
    try {
      final uri = Uri.parse(commonUri+ '/V1/Push/PushResponse.json'); 
      var params = {
        'user_auth_id' : user.userAuthId,
        'result_id' : resultId,
        'result_value' : value,
      };
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      print(response);
    } 
    catch(_) {

    }
  }

}