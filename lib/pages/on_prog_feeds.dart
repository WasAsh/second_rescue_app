import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rescue_app/core/ui_components/info_widget.dart';
import 'package:rescue_app/pages/home.dart';
import 'package:rescue_app/pages/issue_model.dart';
import 'package:rescue_app/pages/on_prog_issues_model.dart';


class OnProgressFeeds extends StatefulWidget {

  final String rescueId ;
  OnProgressFeeds({this.rescueId});

  @override
  _OnProgressFeedsState createState() => _OnProgressFeedsState();
}

class _OnProgressFeedsState extends State<OnProgressFeeds> {

  final String currentResId =currentRes.id ;
  bool isLoading = false ;
  int issuesCount = 0 ;
  List<Issue1> issues = [] ;

  @override
  void initState() {
    super.initState();
    getInProgIssues();
  }

  getInProgIssues() async {
    setState(() {
      isLoading = true ;
    });
    QuerySnapshot snapshot  = await Firestore.instance.collection('inProgress').where('rescueId' , isEqualTo: currentRes.id).getDocuments();
    setState(() {
      isLoading = false ;
      issuesCount = snapshot.documents.length ;
      issues = snapshot.documents.map((doc) => Issue1.fromDoc(doc)).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context,infoWidget)=>isLoading?Column(
        mainAxisAlignment: MainAxisAlignment.center ,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(backgroundColor: Colors.red,)
        ],
      ):Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          children: issues,
        ),
      ),
    );
  }
}
