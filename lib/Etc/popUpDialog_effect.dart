import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
//
//푸시 팝업화면(약을 드신 후 어떠신가요)
//

class PopupEffect extends StatelessWidget {
  final Map<String,dynamic> data; 
  PopupEffect(this.data);

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
        height: 350 ,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset('assets/done.svg'),
            SizedBox(height: 10,),
             Text(data['name'] + ' 님' , style: Theme.of(context).textTheme.headline1,),
            Text('약을 드신 후 어떠신가요?', style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center,),
            SizedBox(height: 10,),
            Column(
              children: [
                DefaultButton(text: '좋아졌습니다.', fontsize: 16, fontWeight: FontWeight.normal,
                  onPressed: (){
                    pushResponse(data['result_id'], '1');
                    Navigator.pop(context);
                  },),
                TextButton(
                  child: Text('효과가 없었습니다.', style:TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Color(0xFFC4C4C4),) ),
                  onPressed: (){
                    pushResponse(data['result_id'], '0');
                    Navigator.pop(context);
                  },)
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