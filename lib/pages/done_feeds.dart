import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rescue_app/core/ui_components/info_widget.dart';
import 'package:rescue_app/pages/done_feeds_model.dart';
import 'package:rescue_app/pages/home.dart';



class DoneFeeds extends StatefulWidget {

  final String rescueId ;
  DoneFeeds({this.rescueId});


  @override
  _DoneFeedsState createState() => _DoneFeedsState();
}

class _DoneFeedsState extends State<DoneFeeds> {

  final String currentResId =currentRes.id ;
  bool isLoading = false ;
  int issuesCount = 0 ;
  List<Issue2> issues = [] ;

  @override
  void initState() {
    super.initState();
    getDoneIssues();
  }

  getDoneIssues() async {
    setState(() {
      isLoading = true ;
    });
    QuerySnapshot snapshot  = await Firestore.instance.collection('done').where('rescueId' , isEqualTo: currentRes.id).getDocuments();
    setState(() {
      isLoading = false ;
      issuesCount = snapshot.documents.length ;
      issues = snapshot.documents.map((doc) => Issue2.fromDoc(doc)).toList();
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
