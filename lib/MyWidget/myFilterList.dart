import 'package:craits/_JClass/filterList.dart';
import 'package:flutter/material.dart';

typedef OnChoiceChanged = Function(List<JFilterListCategoryUnitFliterUnit> list);

class MyFilterList extends StatefulWidget {
  final String headlineText;
  final List<JFilterListCategoryUnitFliterUnit> listData;
  final List<JFilterListCategoryUnitFliterUnit> selectedListData;
  //EB Add 
  final OnChoiceChanged onChoiceChanged;
  
  /// filter list on the basis of search field text
  final List<JFilterListCategoryUnitFliterUnit> Function(List<JFilterListCategoryUnitFliterUnit> list, String text) onItemSearch;


  MyFilterList({
    @required this.headlineText,
    @required this.listData,
    @required this.selectedListData,
    this.onChoiceChanged,
    this.onItemSearch,
  });

  @override
  _MyFilterListState createState() => _MyFilterListState();
}

class _MyFilterListState extends State<MyFilterList> {
  List<JFilterListCategoryUnitFliterUnit> _listData;
  List<JFilterListCategoryUnitFliterUnit> _selectedListData;

  @override
    void initState() {
      _listData = widget.listData == null ? []: List.from(widget.listData);
      _selectedListData = widget.selectedListData == null ? [] :  List.from(widget.selectedListData);
      super.initState();
    }


  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Container(
        child: header(),
      ),
      children: [
        Container(
          padding: EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5),
          child: Column(
            children: [
              SearchFieldWidget(
                searchFieldBackgroundColor: Theme.of(context).shadowColor,
                onChanged: (value){
                  setState(() {
                    if (value.isEmpty) {
                      _listData = widget.listData;
                      return;
                    }
                    _listData = widget.onItemSearch(widget.listData, value);
                  });
                },
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 200
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Wrap(
                      children: _buildChoiceList()
                    ),
                  ),
                ),
              ),
          ],
        )
    )]);
  }

  Widget header() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    widget.headlineText,
                    style: Theme.of(context).textTheme.headline1
                  ),
                ),
                SizedBox(width: 5,),
                Container(
                  child: Text(
                    '${_selectedListData.length}',
                    style: Theme.of(context).textTheme.subtitle2,textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildChoiceList() {
    int indexSelected(String seq){
      for(int index = 0; index < _selectedListData.length; index++){
        if(_selectedListData[index].filterSeq == seq){
          return index;
        }
      }
      return -1;
    }

    List<Widget> choices = [];
    _listData.forEach((unit) {
      choices.add(
        myChoiceChip(
          text:unit.filterDesc,
          onSelected: (bool){
            setState(() {
              int index = indexSelected(unit.filterSeq);
              if(index > -1){
                _selectedListData.removeAt(index);
              }
              else{
                _selectedListData.add(unit);
              }
              if (widget.onChoiceChanged != null) {
                widget.onChoiceChanged(_selectedListData);
              }
            });
          },
        selected: indexSelected(unit.filterSeq) > -1? true : false,
        )
      );
    });
    choices.add(
      SizedBox(
        height: 70,
        width: MediaQuery.of(context).size.width,
      ),
    );
    return choices;
  }
}

class myChoiceChip extends StatelessWidget {
  myChoiceChip(
    {
      this.selected,
      this.onSelected,
      this.text,
    }
  );

  final bool selected;
  final Function(bool) onSelected;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: ChoiceChip(
        selected: selected,
        label: Text(text),
        labelStyle: TextStyle(color: Colors.white, fontFamily: 'SpoqaHanSansNeo',),
        backgroundColor: Colors.black45,
        selectedColor: selected? Theme.of(context).primaryColor : Theme.of(context).shadowColor,
        onSelected: onSelected,
      ),
    );
  }
}


class SearchFieldWidget extends StatelessWidget {
  final String searchFieldHintText;
  final Color searchFieldBackgroundColor;
  final Function(String) onChanged;
  final TextStyle searchFieldTextStyle;
  const SearchFieldWidget({
    Key key,
    this.searchFieldHintText,
    this.onChanged,
    this.searchFieldBackgroundColor,
    this.searchFieldTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: searchFieldBackgroundColor),
        child: TextField(
          onChanged: onChanged,
          cursorColor: Theme.of(context).primaryColor,
          cursorHeight: 18,
          style: searchFieldTextStyle ??
            TextStyle(fontSize: 14.0, color: Colors.black87),
          decoration: InputDecoration(
            isDense: true,
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            prefixIconConstraints: BoxConstraints(
              minWidth: 40,
              minHeight: 35
            ),
            prefixIcon: Icon(Icons.search, color: Colors.black38, size: 20,),
            hintText: searchFieldHintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
