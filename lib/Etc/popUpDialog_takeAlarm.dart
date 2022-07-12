import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
//
//푸시 팝업화면(약 시간 알람)
//
class PopupTakeAlarm extends StatelessWidget {
  final Map<String,dynamic> data; 
  PopupTakeAlarm(this.data);

  @override
  Widget build(BuildContext context) {
    String year = data['dt'].toString().substring(0,4);
    String month = data['dt'].toString().substring(5,7);
    String day = data['dt'].toString().substring(8,10);
    int iHour = DateTime.tryParse(data['dt']).hour;
    String amPm = iHour >= 12 ? 'PM' : 'AM';
    String hour = iHour > 12? (iHour-12).toString().padLeft(2,'0')  : iHour.toString().padLeft(2,'0');
    String minute = data['dt'].toString().substring(14,16);

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
        height: 450,
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset('assets/takeAlarm.svg'),
            Text(data['name'] + ' 님' , style: Theme.of(context).textTheme.headline1,),
            Text('약 복용하셨나요?', style: TextStyle(fontSize: 25.0)),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(          
                  padding: const EdgeInsets.all(5.0), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),     
                    borderRadius: BorderRadius.all(
                      const Radius.circular(4.0),
                    ),  
                  ),
                  child: Text('$year', style: Theme.of(context).textTheme.headline5),
                ),
                Text('년 ', style: Theme.of(context).textTheme.headline5),
                Container(          
                  padding: const EdgeInsets.all(5.0), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),     
                    borderRadius: BorderRadius.all(
                      const Radius.circular(4.0),
                    ),  
                  ),
                  child: Text('$month', style: Theme.of(context).textTheme.headline5),
                ),
                Text('월 ', style: Theme.of(context).textTheme.headline5),
                Container(          
                  padding: const EdgeInsets.all(5.0), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),     
                    borderRadius: BorderRadius.all(
                      const Radius.circular(4.0),
                    ),  
                  ),
                  child: Text('$day', style: Theme.of(context).textTheme.headline5),
                ),
                Text('일 ', style: Theme.of(context).textTheme.headline5),
              ],
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$amPm ', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                Container(          
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),     
                    borderRadius: BorderRadius.all(
                      const Radius.circular(4.0),
                    ),  
                  ),
                  child: Text('${hour.substring(0,1)}', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 8,),
                Container(          
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),     
                    borderRadius: BorderRadius.all(
                      const Radius.circular(4.0),
                    ),  
                  ),
                  child: Text('${hour.substring(1,2)}', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500)),
                ),
                Text(' : ', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500)),
                Container(          
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),     
                    borderRadius: BorderRadius.all(
                      const Radius.circular(4.0),
                    ),  
                  ),
                  child: Text('${minute.substring(0,1)}', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 8,),
                Container(          
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),     
                    borderRadius: BorderRadius.all(
                      const Radius.circular(4.0),
                    ),  
                  ),
                  child: Text('${minute.substring(1,2)}', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Column(
              children: [
                DefaultButton(text: '네. 복용했습니다.', fontsize: 16, fontWeight: FontWeight.normal,
                  onPressed: (){
                    pushResponse(data['result_id'], '1');
                    Navigator.pop(context);
                  },),
                TextButton(
                  child: Text('아니요. 복용하지 않았습니다.', style:TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Color(0xFFC4C4C4),) ),
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
    } 
    catch(_) {
    }
  }
}
