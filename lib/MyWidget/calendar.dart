import 'package:flutter/material.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

// /// My app class to display the date range picker
// class MyCalendarRange extends StatefulWidget {
//   final DateTimeRange _dateTimeRange;
//   MyCalendarRange(this._dateTimeRange);

//   @override
//   MyCalendarRangeState createState() => MyCalendarRangeState(_dateTimeRange);
// }

// /// 달력  AutomaticKeepAliveClientMixin : 초기화X
// class MyCalendarRangeState extends State<MyCalendarRange>  with AutomaticKeepAliveClientMixin{
//   DateTimeRange _dateTimeRange;
//   DateTimeRange dateTimeRangeOrg; //달력 선택시 초기 날짜
//   String _selectedDateFrom;
//   String _selectedDateTo;
//   bool isOk = true; //날짜 start, end 모두 선택했는지

//   MyCalendarRangeState(this._dateTimeRange)
//   {
//     dateTimeRangeOrg = _dateTimeRange; //달력 띄울 때 초기 날짜 기억
//     this._selectedDateFrom = DateFormat('yyyy년 MM월 dd일').format(_dateTimeRange.start).toString();
//     this._selectedDateTo = DateFormat('yyyy년 MM월 dd일').format(_dateTimeRange.end).toString();
//   }

//   void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
//     setState(() {
//       if (args.value.startDate != null && args.value.endDate != null)
//         isOk = true;
//       else
//         isOk = false;
//       if (args.value is PickerDateRange) {
//         _selectedDateFrom =
//             DateFormat('yyyy년 MM월 dd일').format(args.value.startDate).toString();
//         if (args.value.endDate == null) {
//           _selectedDateTo = '';
//           _dateTimeRange = DateTimeRange(
//               start: args.value.startDate, end: args.value.startDate);
//         } else {
//           _selectedDateTo =
//               DateFormat('yyyy년 MM월 dd일').format(args.value.endDate).toString();
//           _dateTimeRange = DateTimeRange(
//               start: args.value.startDate, end: args.value.endDate);
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Dialog(
//       backgroundColor: Colors.white,
//       insetPadding: EdgeInsets.fromLTRB(20, 80, 20, 20),
//       child: Container(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           children: <Widget>[
//             Container(
//               height: 50,
//               child: Row(children: [
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('시작일', style: Theme.of(context).textTheme.subtitle2,),
//                       Text('$_selectedDateFrom', style: Theme.of(context).textTheme.headline5,),
//                     ],
//                   ),
//                 ),
//                 VerticalDivider(),
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text('종료일', style: Theme.of(context).textTheme.subtitle2,),
//                       Text('$_selectedDateTo', style: Theme.of(context).textTheme.headline5,),
//                     ],
//                   ),
//                 ),
//               ],),
//             ),
//             SizedBox(height: 20,),
//             Expanded(
//               child: SfDateRangePicker(
//                 onSelectionChanged: _onSelectionChanged,
//                 monthViewSettings: DateRangePickerMonthViewSettings(
//                   firstDayOfWeek: 7,
//                   viewHeaderStyle: DateRangePickerViewHeaderStyle(
//                     textStyle: Theme.of(context).textTheme.headline3,
//                   ),
//                 ),
//                 maxDate: DateTime.now(),
//                 todayHighlightColor: Theme.of(context).primaryColor,
//                 navigationMode: DateRangePickerNavigationMode.scroll,
//                 navigationDirection: DateRangePickerNavigationDirection.vertical, 
//                 enableMultiView: true, //
//                 selectionRadius: 20.0,
//                 selectionShape: DateRangePickerSelectionShape.circle,
//                 rangeTextStyle:  Theme.of(context).textTheme.bodyText1,
//                 selectionMode: DateRangePickerSelectionMode.range,
//                 initialSelectedRange: PickerDateRange(_dateTimeRange.start, _dateTimeRange.end),
//                 headerStyle: DateRangePickerHeaderStyle(
//                   textAlign: TextAlign.center,
//                   textStyle: Theme.of(context).textTheme.headline2),
//                 yearCellStyle: DateRangePickerYearCellStyle(
//                   textStyle: Theme.of(context).textTheme.bodyText1),
//                 monthCellStyle: DateRangePickerMonthCellStyle(
//                   textStyle: Theme.of(context).textTheme.bodyText1,
//                   disabledDatesTextStyle:  TextStyle(color: Colors.grey, fontSize: 14.0, fontFamily: 'SpoqaHanSansNeo'),
//                   weekendTextStyle: TextStyle(color: Colors.red, fontSize: 14.0, fontFamily: 'SpoqaHanSansNeo') //주말은 빨간 숫자
//                     ),
//               ),
//             ),
//             Container(
//               child: DefaultButton(
//                 color: (isOk) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
//                 text: '확인',
//                 onPressed: () {
//                   if (isOk) //날짜 start, end 모두 선택했을 때
//                     Navigator.of(context).pop(_dateTimeRange); //선택한 날짜 range 넘겨줌
//                 },
//               ),
//             )
//           ],
//         ),
//       ));
//   }

// //초기화X
//   @override
//   bool get wantKeepAlive => true;
// }



/// My app class to display the date range picker
class MyCalendar extends StatefulWidget {
  DateTime _dateTime;
  dynamic dateRangePickerViewEnum;
  MyCalendar(this._dateTime, this.dateRangePickerViewEnum);

  @override
  MyCalendarState createState() => MyCalendarState(_dateTime, dateRangePickerViewEnum);
}

/// 달력  AutomaticKeepAliveClientMixin : 초기화X
class MyCalendarState extends State<MyCalendar>  with AutomaticKeepAliveClientMixin{
  DateTime _dateTime;
  String _strDatetime;
  dynamic dateRangePickerViewEnum;
  MyCalendarState(this._dateTime, this.dateRangePickerViewEnum);

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _dateTime = args.value;
      _strDatetime = DateFormat('yyyy년 MM월 dd일').format(_dateTime).toString();
    });
  }

  @override
  void initState() {
    _dateTime = widget._dateTime;
    _strDatetime = DateFormat('yyyy년 MM월 dd일').format(_dateTime).toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Dialog( 
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.fromLTRB(20, 100, 20, 100),
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SfDateRangePicker(
                view: dateRangePickerViewEnum,
                onSelectionChanged: _onSelectionChanged,
                monthViewSettings: DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 7,
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: Theme.of(context).textTheme.headline3,
                  ),
                ),
                maxDate: DateTime.now(),
                initialSelectedDate: _dateTime,
                initialDisplayDate: _dateTime,
                todayHighlightColor: Theme.of(context).primaryColor,
                navigationMode: DateRangePickerNavigationMode.snap, //
                navigationDirection: DateRangePickerNavigationDirection.vertical, //
                enableMultiView: false, //
                selectionRadius: 18.0,
                selectionShape: DateRangePickerSelectionShape.circle,
                selectionMode: DateRangePickerSelectionMode.single,
                headerHeight: 80,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: Theme.of(context).textTheme.headline1),
                yearCellStyle: DateRangePickerYearCellStyle(
                  leadingDatesTextStyle: Theme.of(context).textTheme.bodyText1 ,
                  textStyle: Theme.of(context).textTheme.bodyText1),
                monthCellStyle: DateRangePickerMonthCellStyle(
                    textStyle: Theme.of(context).textTheme.bodyText1,
                    weekendTextStyle: TextStyle(color: Colors.red, fontSize: 14.0, fontFamily: 'SpoqaHanSansNeo') //주말은 빨간 숫자
                    ),
              ),
            ),
            Container(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      child:Text('선택한 날짜  ', style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.center,),
                    ),
                  ),
                  VerticalDivider(),
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: double.infinity,
                      child:Text(' $_strDatetime', style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.center,),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              child: DefaultButton(
                color: Theme.of(context).primaryColor ,
                text: '확인',
                onPressed: () {
                    Navigator.of(context).pop(_dateTime); //선택한 날짜 range 넘겨줌
                },
              ),
            )
          ],
        ),
      ));
  }

//초기화X
  @override
  bool get wantKeepAlive => true;
}
