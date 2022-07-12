import 'package:flutter/material.dart';
import 'home_feed.dart';
import '../Home_Chart/home_chart.dart';
import 'package:craits/MyWidget/myAppBar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScrollController scrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 62,
          elevation: 1.0,
          flexibleSpace: MyAppBar(),
          bottom: TabBar(
            indicatorWeight: 3.0, 
            tabs: <Widget>[
              Tab(text:'피드',),
              Tab(text:'진료기록'),
            ],
          ),
        ),
        backgroundColor: Colors.white10,
        body: TabBarView(
          children: <Widget>[
            HomeMyFeed(),
            HomeMyChart(),
          ],
        ),
    ));
  }
}

