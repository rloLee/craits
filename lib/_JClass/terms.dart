class JTerms{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JTermsInfo info;

  JTerms({
    this.resultCode,
    this.resultMsg,
    this.info,
  });
  
  factory JTerms.fromJson(Map<dynamic, dynamic> json){
    return JTerms(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info: JTermsInfo.fromJson(json['info']),
    );
  }
}

class JTermsInfo{
  final content;

  JTermsInfo({
    this.content
  });

  factory JTermsInfo.fromJson(Map<dynamic, dynamic> json){
    return JTermsInfo(
      content: json['content']
    );
  }
}