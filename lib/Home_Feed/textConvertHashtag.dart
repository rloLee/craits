import 'package:flutter/material.dart';
import 'package:craits/_JClass/feedList.dart';
import 'feed_comment.dart';
import 'package:craits/search/search.dart';


class TextConvertHashTag extends StatefulWidget {
  final String text;
  final bool clickable;
  final JFeedListUnit feed;
  final Function onDelete;
  TextConvertHashTag({
    @required this.text, @required this.feed, @required this.clickable, this.onDelete});

  @override
  _TextConvertHashTagState createState() => _TextConvertHashTagState();
}

class _TextConvertHashTagState extends State<TextConvertHashTag> {
  bool bfolded = false;
  String textShowed;

  List<InlineSpan> textSpans ;
  final RegExp regex = RegExp(r"\#[a-zA-Zㄱ-ㅎ가-힣0-9\_]+" );
  Iterable<Match> matches;
  
  void setText(){
    textSpans = [];
    matches = regex.allMatches(textShowed);
    int start = 0;
    setState(() {
      for (final Match match in matches) {
        textSpans.add(TextSpan(text: textShowed.substring(start, match.start), style: TextStyle(fontSize: 14.0, color: Color(0xFF262626), fontFamily: 'NotoSansCJKkr',)));
        textSpans.add(WidgetSpan(
          child: GestureDetector(
            onTap: (){
              if(widget.clickable)
                Navigator.push(context, MaterialPageRoute(builder: (context) => Search(hashTagText: match.group(0),)));
              else
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Search(hashTagText: match.group(0),)));

              // print('${match.group(0)}');
            },
            child: Text('${match.group(0)}', style: TextStyle(fontSize: 14.0, color: Color(0xFF469BA7 ), fontWeight: FontWeight.normal, fontFamily: 'NotoSansCJKkr',), textAlign: TextAlign.end,))));
        start = match.end;
      }
      textSpans.add(TextSpan(text: textShowed.substring(start, textShowed.length), style: TextStyle(fontSize: 14.0, color: Color(0xFF262626), fontFamily: 'NotoSansCJKkr',)));
      if(bfolded)
        textSpans.add(TextSpan(text: '...더보기', style: TextStyle(fontSize: 13.0, color: Color(0xFF959595), fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKkr',)));

    });
  }

  @override
    void initState() {
      super.initState();
      if(widget.clickable){
        if(widget.text.length > 50)
          {
            textShowed = widget.text.substring(0, 50);
            bfolded = true;
            }
        else 
          textShowed = widget.text;
      }
      else 
          textShowed = widget.text;
      setText();
    }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text.rich( 
        TextSpan(children: textSpans,),),
        onTap: (){
          if(bfolded)
            setState(() {
              textShowed = widget.text;
              matches = regex.allMatches(textShowed);
              bfolded = false;
              setText();
            });
          else{
            if(widget.clickable) 
              Navigator.push(context, MaterialPageRoute(builder: (context) => FeedComment(feed: widget.feed, onDelete: widget.onDelete,)));
          }
        },
    );
  }
}
