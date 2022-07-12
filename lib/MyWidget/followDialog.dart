import 'dart:convert';
import 'package:craits/_JClass/response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Common/com.dart';

class FollowDialog extends StatefulWidget {
  final String id;
  final String name;
  final String flag; //"Y" : 등록 / "N" : 취소
  FollowDialog(this.id, this.name, this.flag);

  @override
  _FollowDialogState createState() => _FollowDialogState();
}

class _FollowDialogState extends State<FollowDialog> {
  final uri = Uri.parse(commonUri + '/V1/Follow/RegisterFollow.json');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(20),
      elevation: 0.0,
      backgroundColor: Colors.white,
      actionsOverflowButtonSpacing: 20,
      insetPadding: EdgeInsets.fromLTRB(0,0,0,0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          const Radius.circular(20.0),
        ),
      ),
      title: Column(
        children: [
        Container(
          padding:EdgeInsets.all(5), 
          child: Text(
            widget.flag == 'Y'
            ? '팔로우'
            : '언팔로우', 
          style: Theme.of(context).textTheme.headline4)),
        Container(
          padding:EdgeInsets.all(5), 
          child: Text(
            widget.flag == 'Y'
            ?'${widget.name} 님을 팔로우 하시겠습니까?'
            :'${widget.name} 님을 언팔로우 하시겠습니까?',
          style: Theme.of(context).textTheme.bodyText1)),
        ],
      ),
      actions: [
        Container(
          child: TextButton( child:Text('취소', style: Theme.of(context).textTheme.bodyText1), 
          onPressed: (){
            Navigator.pop(context);
          },)),
        Container(
        child: TextButton(
          child:Text(
            widget.flag == 'Y'
            ? '팔로우'
            : '언팔로우', 
          style: Theme.of(context).textTheme.headline6), 
          onPressed:  (){
            updateFollow(context);
          },)),
      ],
    );
  }

  void updateFollow(BuildContext context) async{
    String value = await follow();
    Navigator.pop(context, value);
  }

  Future<String> follow() async {
    try{
      var params = {
        'user_auth_id' : user.userAuthId,
        'flag' : widget.flag, //"Y" : 등록 / "N" : 취소
        'follow_user_id' : widget.id
      };
      
      showDialog(
        barrierDismissible: false,
        context: context, builder: (_) //Indigator 보여주기
      => AlertDialog( 
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            const Radius.circular(20.0),
          ),
        ),
        content: SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(child: CircularProgressIndicator()),
            ],
          ),),
        )
      );

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      Navigator.pop(context); //Indigator 닫기

      JResponse _updateFollow;
      if(response.statusCode == 200){
        _updateFollow =JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        return _updateFollow.resultCode;
      }
      else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
        return null;
      }
    }
    catch(_)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      return null;
    }
  }
}