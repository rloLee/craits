import 'package:craits/Common/com.dart';
import 'package:craits/_JClass/terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//
//가입시 이용약관
//
class TermView extends StatelessWidget {
  final String searchType; 
  TermView({Key key, @required this.searchType}) : super(key: key);
  String content = ''; 


  Future getData(BuildContext context) async{
    final uri = Uri.parse(commonUri + '/V1/Auth/Terms.json');
    try{
      var params = {
        'searchType' : searchType
      };
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JTerms _searchId;
      if(response.statusCode == 200){
        _searchId = JTerms.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_searchId.resultCode == 'SUCC'){
          content = _searchId.info.content;
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              content: Text('오류가 발생했습니다.'))
          );
          content =  '';
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        content =  '';
      }
    }
    catch (_){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        content =  '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          title: Text('이용약관'),
          leading: IconButton(
            icon: SvgPicture.asset('assets/close.svg'), 
          onPressed: (){
            Navigator.pop(context);
          })),
        body: FutureBuilder(
          builder: (context, snapshot){
            if(snapshot.connectionState != ConnectionState.done){
              return Center(child: CircularProgressIndicator(
              ));
            }
            else{
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: Text(content, style: Theme.of(context).textTheme.bodyText1,)
                ),
              );
            }
          },
          future: getData(context),
        ),
    );
  }
}