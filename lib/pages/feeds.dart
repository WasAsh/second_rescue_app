import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rescue_app/core/models/device_info.dart';
import 'package:rescue_app/core/ui_components/info_widget.dart';
import 'package:rescue_app/pages/home.dart';
import 'package:rescue_app/pages/issue_model.dart';

class Feeds extends StatefulWidget {
  final String rescueId;
  Feeds({this.rescueId});

  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  TextEditingController _filterController = TextEditingController() ;
  final String currentResId = currentRes.id;
  bool isLoading = false;
  int issuesCount = 0;
  List<Issue> issues = [];

  Future<QuerySnapshot> filterResult ;
  handleFilter( String query ){
    Future<QuerySnapshot> filteredIssues = issueRef
        .where('city' , isEqualTo: query )
    .where('resType' , isEqualTo: currentRes.rescueType)
        .getDocuments() ;
    setState(() {
      filterResult = filteredIssues ;
    });
  }

  @override
  void initState() {
    super.initState();
    getIssues();
  }

  getIssues() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await issueRef
        .where('resType', isEqualTo: currentRes.rescueType)
        .getDocuments();
    setState(() {
      isLoading = false;
      issuesCount = snapshot.documents.length;
      issues = snapshot.documents.map((doc) => Issue.fromDoc(doc)).toList();
    });
  }

  buildNormalView(){
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
          children: issues ,
        ),
      ),
    );
  }

  buildFilteredView(){
    return FutureBuilder(
      future: filterResult,
      builder: (context , snapshot){
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        }
        List<IssueResult> result = [] ;
        snapshot.data.documents.forEach((doc){
          Issue issue = Issue.fromDoc(doc) ;
          IssueResult issueResult = IssueResult(issue);
          result.add(issueResult);
        });
        return ListView(
          children: result,
        );
      },
    );
  }

  clear(){
    _filterController.clear();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: TextFormField(
           controller: _filterController,
           textDirection: TextDirection.rtl,
           decoration: InputDecoration(
             hintText: 'اكتب اسم المدينة' ,
             filled: true ,
             prefixIcon: Icon(Icons.search , size: 28,) ,
             suffixIcon: IconButton(
               icon: Icon(Icons.clear),
               onPressed: clear,
             ) ,
           ),
           onFieldSubmitted: handleFilter,
         ),
         backgroundColor: Colors.white,
       ),
       body: filterResult == null ? buildNormalView() : buildFilteredView() ,
     );
  }
}

class IssueResult extends StatelessWidget {

  final Issue issue ;
  IssueResult(this.issue) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10))),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: ListView(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                            child: Text(
                              'البيانات بالكامل',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              )
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'الاسم بالكامل: ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              '${issue.fullName}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'رقم الهاتف: ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              '${issue.phone}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'العنوان بالكامل: ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              '${issue.fullAddress}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'الطلب: ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              '$issue',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'نوع الطلب: ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              '${issue.resType}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'نوع الاصابة(اسعاف): ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              '${issue.injuryType ?? 'غير معروف'}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'عدد الاصابات(اسعاف): ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              '${issue.injuryCount ?? 'غير معروف'}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'نوع الحريق(حريق): ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              '${issue.fireType ?? 'غير معروف'}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'مكان الحريق(حريق): ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              '${issue.firePlace ?? 'غير معروف'}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 30,
                  child: CircleAvatar(
                    backgroundColor: Colors.red.shade400,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'الاسم: ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '${issue.fullName}',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xff484848),
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'رقم الهاتف: ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '${issue.phone}',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xff484848),
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'المدينه: ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '${issue.city}',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xff484848),
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'العنوان بالكامل: ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '${issue.fullAddress}',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xff484848),
                              fontWeight: FontWeight.bold
                          ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'نوع الانقاذ: ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '${issue.resType}',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xff484848),
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                Icons.done_outline,
                color: Colors.red,
              ),
              onPressed: () {
                Firestore.instance
                    .collection('inProgress')
                    .document(currentRes.id)
                    .setData({
                  'issueId': issue.issueId,
                  'ownerId': issue.ownerId,
                  'rescueId': currentRes.id,
                  'issue': issue.issue,
                  'fullName': issue.fullName,
                  'phone': issue.phone,
                  'rescueType': issue.resType,
                  'fullAddress': issue.fullAddress,
                  'injuryType': issue.injuryType,
                  'injuryCount': issue.injuryCount,
                  'fireType': issue.fireType,
                  'firePlace': issue.firePlace,
                }).whenComplete(() => {
                  Firestore.instance
                      .collection('issues')
                      .document(issue.issueId)
                      .delete()
                });
              },
            ),
          ],
        ),

      ),
    );
  }
}

