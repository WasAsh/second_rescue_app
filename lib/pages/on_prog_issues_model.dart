import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rescue_app/core/models/device_info.dart';
import 'package:rescue_app/core/ui_components/info_widget.dart';
import 'package:rescue_app/models/case.dart';
import 'package:rescue_app/pages/home.dart';

class Issue1 extends StatefulWidget {
  final String issueId;
  final String ownerId;
  final String issue;
  final String fullAddress;
  final String resType;
  final String city;
  final String phone;
  final String fullName;
  final String fireType;
  final String firePlace;
  final String injuryCount;
  final String injuryType;

  Issue1(
      {this.issueId,
      this.ownerId,
      this.issue,
      this.city,
      this.fullAddress,
      this.resType,
      this.phone,
      this.fullName,
      this.fireType,
      this.firePlace,
      this.injuryCount,
      this.injuryType});

  factory Issue1.fromDoc(DocumentSnapshot doc) {
    return Issue1(
      issueId: doc['issueId'],
      ownerId: doc['ownerId'],
      issue: doc['issue'],
      fullAddress: doc['fullAddress'],
      resType: doc['resType'],
      phone: doc['phone'],
      city: doc['city'],
      fullName: doc['fullName'],
      fireType: doc['fireType'],
      firePlace: doc['firePlace'],
      injuryCount: doc['injuryCount'],
      injuryType: doc['injuryType'],
    );
  }

  @override
  _Issue1State createState() => _Issue1State(
        issueId: this.issueId,
        ownerId: this.ownerId,
        issue: this.issue,
        fullAddress: this.fullAddress,
        resType: this.resType,
        phone: this.phone,
        fullName: this.fullName,
        city: this.city,
        fireType: this.fireType,
        firePlace: this.firePlace,
        injuryCount: this.injuryCount,
        injuryType: this.injuryType,
      );
}

class _Issue1State extends State<Issue1> {
  final String issueId;
  final String ownerId;
  final String issue;
  final String fullAddress;
  final String resType;
  final String city;
  final String phone;
  final String fullName;
  final String fireType;
  final String firePlace;
  final String injuryCount;
  final String injuryType;

  _Issue1State(
      {this.issueId,
      this.ownerId,
      this.issue,
      this.fullAddress,
      this.resType,
      this.phone,
      this.fullName,
      this.city,
      this.fireType,
      this.firePlace,
      this.injuryCount,
      this.injuryType});

  buildIssueTop(DeviceInfo infoWidget) {
    return FutureBuilder(
      future: caseRef.document(ownerId).get(),
      builder: (context, snapShot) {
        if (!snapShot.hasData) {
          return SizedBox();
        }
        Case caseA = Case.fromDocument(snapShot.data);
        print(caseA.displayName);
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
                context: context,
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
                            style: infoWidget.titleButton
                                .copyWith(color: Colors.red),
                          )),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                'الاسم بالكامل: ',
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '${caseA.displayName}',
                                style: infoWidget.subTitle,
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
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '${caseA.phone}',
                                style: infoWidget.subTitle,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                'الايميل: ',
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '${caseA.email}',
                                style: infoWidget.subTitle,
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
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '$fullAddress',
                                style: infoWidget.subTitle,
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
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '$issue',
                                style: infoWidget.subTitle,
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
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '${resType ?? 'غير معرف'}',
                                style: infoWidget.subTitle,
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
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '${injuryType ?? 'غير معروف'}',
                                style: infoWidget.subTitle,
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
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '${injuryCount ?? 'غير معروف'}',
                                style: infoWidget.subTitle,
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
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '${fireType ?? 'غير معروف'}',
                                style: infoWidget.subTitle,
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
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '${firePlace ?? 'غير معروف'}',
                                style: infoWidget.subTitle,
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
                    width: infoWidget.screenWidth * 0.12 //
                    ,
                    height: infoWidget.screenWidth * 0.12,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(
                        caseA.photoUrl,
                      ),
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
                    fullName == null
                        ? SizedBox()
                        : Row(
                            children: <Widget>[
                              Text(
                                'الاسم: ',
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '$fullName',
                                style: infoWidget.subTitle,
                              ),
                            ],
                          ),
                    phone == null
                        ? SizedBox()
                        : Row(
                            children: <Widget>[
                              Text(
                                'رقم الهاتف: ',
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '$phone',
                                style: infoWidget.subTitle,
                              ),
                            ],
                          ),
                    city == null
                        ? SizedBox()
                        : Row(
                            children: <Widget>[
                              Text(
                                'المدينه: ',
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '$city',
                                style: infoWidget.subTitle,
                              ),
                            ],
                          ),
                    fullAddress == null
                        ? SizedBox()
                        : Row(
                            children: <Widget>[
                              Text(
                                'العنوان بالكامل: ',
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '$fullAddress',
                                style: infoWidget.subTitle,
                              ),
                            ],
                          ),
                    resType == null
                        ? SizedBox()
                        : Row(
                            children: <Widget>[
                              Text(
                                'نوع الانقاذ: ',
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.red),
                              ),
                              Text(
                                '$resType',
                                style: infoWidget.subTitle,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  Firestore.instance
                      .collection('done')
                      .document(currentRes.id)
                      .setData({
                    'issueId': issueId,
                    'ownerId': ownerId,
                    'rescueId': currentRes.id,
                    'issue': issue,
                    'fullName': fullName,
                    'email': caseA.email,
                    'phone': caseA.phone,
                    'fullAddress': fullAddress,
                    'injuryType': injuryType,
                    'injuryCount': injuryCount,
                    'fireType': fireType,
                    'firePlace': firePlace,
                  }).whenComplete(() => {
                            Firestore.instance
                                .collection('inProgress')
                                .document(currentRes.id)
                                .delete()
                          });
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            buildIssueTop(infoWidget),
            Divider(
              thickness: 2,
            ),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }
}
