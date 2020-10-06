import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rescue_app/core/models/device_info.dart';
import 'package:rescue_app/core/ui_components/info_widget.dart';
import 'package:rescue_app/models/rescue_man.dart';
import 'package:rescue_app/pages/create_account.dart';
import 'package:rescue_app/pages/done_feeds.dart';
import 'package:rescue_app/pages/feeds.dart';
import 'package:rescue_app/pages/on_prog_feeds.dart';
import 'package:rescue_app/pages/splash_screen.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final caseRef = Firestore.instance.collection('case');
final rescueRef = Firestore.instance.collection('rescue');
final issueRef = Firestore.instance.collection('issues');
final StorageReference storageRef = FirebaseStorage.instance.ref();
final DateTime timeStamp = DateTime.now();
Rescue currentRes;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  final GlobalKey<ScaffoldState> mainKey = GlobalKey<ScaffoldState>();
  List<String> type = ['الرئيسية', 'الطلبات', 'قيد التنفيذ', 'منتهيه'];
  PageController _pageController;
  bool isAuth = false;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  int pageIndex = 0;
  String phone, fullName;
  List<String> rescueTypeItems = <String>['شرطي', 'مسعف', 'رجل اطفاء'];
  var selectedRescue;

  //ensure that user signed in or not
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    //1
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      print('Error is $err');
    });
    //2
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      print('Error is $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFireStore();
      setState(() {
        isAuth = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        isAuth = false;
      });
    }
  }

  login() {
    googleSignIn.signIn();
  }

  signOut() {
    googleSignIn.signOut();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  //create user in firestore
  createUserInFireStore() async {
    final GoogleSignInAccount rescue = googleSignIn.currentUser;
    DocumentSnapshot doc = await rescueRef.document(rescue.id).get();

    if (!doc.exists) {
      final resType = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      rescueRef.document(rescue.id).setData({
        'id': rescue.id,
        'displayName': rescue.displayName,
        'fullName': null,
        'photoUrl': rescue.photoUrl,
        'email': rescue.email,
        'rescueType': resType,
        'phone': null,
        'timeStamp': timeStamp,
      });
      doc = await rescueRef.document(rescue.id).get();
    }
    currentRes = Rescue.fromDocument(doc);
    print(currentRes.email);
  }

  Widget _iconNavBar({IconData iconPath, String title, DeviceInfo infoWidget}) {
    return title == null
        ? Icon(
            iconPath,
            color: Colors.white,
          )
        : Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Column(
              children: <Widget>[
                Icon(
                  iconPath,
                  color: Colors.white,
                ),
                title == null
                    ? SizedBox()
                    : Text(
                        title,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? MediaQuery.of(context).size.width * 0.035
                                : MediaQuery.of(context).size.width * 0.024,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
              ],
            ),
          );
  }

  Widget _drawerListTile(
      {String name,
      IconData icon = Icons.settings,
      String imgPath,
      bool isIcon = false,
      DeviceInfo infoWidget,
      Function onTap}) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        dense: true,
        title: Text(
          name,
          style: infoWidget.titleButton.copyWith(color: Colors.red),
        ),
        leading: isIcon
            ? Icon(
                icon,
                color: Colors.red,
              )
            : Image.asset(
                imgPath,
                color: Colors.red,
              ),
      ),
    );
  }

//draw widgets
  Widget buildAuthScreen() {
    return InfoWidget(
      builder: (context, infoWidget) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            key: mainKey,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                type[_page],
                style: infoWidget.titleButton,
              ),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
            ),
            drawer: Container(
              width: infoWidget.orientation == Orientation.portrait
                  ? infoWidget.screenWidth * 0.6
                  : infoWidget.screenWidth * 0.59,
              height: infoWidget.screenHeight,
              child: Drawer(
                child: ListView(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      accountName:
                          Text("${googleSignIn.currentUser.displayName}"),
                      accountEmail: Text("${googleSignIn.currentUser.email}"),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          "${googleSignIn.currentUser.displayName.substring(0, 1).toUpperCase()}",
                          style: TextStyle(fontSize: 40.0),
                        ),
                      ),
                    ),
                    _drawerListTile(
                        isIcon: true,
                        name: "الرئيسية",
                        icon: Icons.home,
                        infoWidget: infoWidget,
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _page = 0;
                          });
                          _pageController.jumpToPage(_page);
                        }),
                    _drawerListTile(
                        name: "الطلبات",
                        isIcon: true,
                        icon: Icons.feedback,
                        infoWidget: infoWidget,
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _page = 1;
                          });
                          _pageController.jumpToPage(_page);
                        }),
                    _drawerListTile(
                        name: "قيد التنفيذ",
                        isIcon: true,
                        icon: Icons.play_circle_filled,
                        infoWidget: infoWidget,
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _page = 2;
                          });
                          _pageController.jumpToPage(_page);
                        }),
                    _drawerListTile(
                        name: "المنتهية",
                        isIcon: true,
                        icon: Icons.check_circle,
                        infoWidget: infoWidget,
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _page = 3;
                          });
                          _pageController.jumpToPage(_page);
                        }),
                    _drawerListTile(
                        name: "تسجيل الخروج",
                        isIcon: true,
                        icon: Icons.exit_to_app,
                        infoWidget: infoWidget,
                        onTap: signOut),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: CurvedNavigationBar(
              height: infoWidget.screenHeight >= 960 ? 70 : 55,
              key: _bottomNavigationKey,
              backgroundColor: Colors.white,
              color: Colors.red,
              items: <Widget>[
                _page != 0
                    ? _iconNavBar(
                        infoWidget: infoWidget,
                        title: 'الرئيسية',
                        iconPath: Icons.home)
                    : _iconNavBar(infoWidget: infoWidget, iconPath: Icons.home),
                _page != 1
                    ? _iconNavBar(
                        infoWidget: infoWidget,
                        title: 'الطلبات',
                        iconPath: Icons.feedback)
                    : _iconNavBar(
                        infoWidget: infoWidget, iconPath: Icons.feedback),
                _page != 2
                    ? _iconNavBar(
                        infoWidget: infoWidget,
                        title: 'قيد التنفيذ',
                        iconPath: Icons.play_circle_filled)
                    : _iconNavBar(
                        infoWidget: infoWidget,
                        iconPath: Icons.play_circle_filled),
                _page != 3
                    ? _iconNavBar(
                        infoWidget: infoWidget,
                        title: 'المنتهية',
                        iconPath: Icons.check_circle)
                    : _iconNavBar(
                        infoWidget: infoWidget, iconPath: Icons.check_circle),
              ],
              onTap: (index) {
                setState(() {
                  _page = index;
                });
                _pageController.jumpToPage(_page);
              },
            ),
            body: Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _page = index;
                  });
                  final CurvedNavigationBarState navBarState =
                      _bottomNavigationKey.currentState;
                  navBarState.setPage(_page);
                },
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.only(top: 12.0, right: 2.0, left: 2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('مرحباً بك :',
                                textAlign: TextAlign.center,
                                style: infoWidget.title),
                            Text(
                                ' من فضلك قم بتحديث ملفك الشخصي عند اول استخدام للتطبيق ',
                                textAlign: TextAlign.center,
                                style: infoWidget.subTitle),
                            FlatButton(
                              color: Colors.red,
                              child: Text(
                                'تعديل البيانات',
                                style: infoWidget.titleButton,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    context: context,
                                    builder: (context) {
                                      return ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight:
                                                infoWidget.screenHeight * 0.85),
                                        child: Column(
                                          textDirection: TextDirection.rtl,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(top: 25),
                                              child: Center(
                                                child: Text(
                                                    'تعديل البيانات الشخصية',
                                                    style: infoWidget
                                                        .titleButton
                                                        .copyWith(
                                                            color: Colors.red)),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Container(
                                                child: Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    children: <Widget>[
                                                      TextFormField(
                                                        validator: (val) {
                                                          if (val
                                                                      .trim()
                                                                      .length <
                                                                  6 ||
                                                              val.isEmpty) {
                                                            return ('الرقم المدخل غير صحيح');
                                                          } else if (val
                                                                  .trim()
                                                                  .length >
                                                              15) {
                                                            return ('الرقم المدخل غير صحيح');
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        onSaved: (val) =>
                                                            phone = val,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          icon:
                                                              Icon(Icons.phone),
                                                          labelText:
                                                              'رقم الهاتف',
                                                          labelStyle: TextStyle(
                                                              fontSize: 12),
                                                          hintText:
                                                              '01234567890',
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextFormField(
                                                        validator: (val) {
                                                          if (val
                                                                      .trim()
                                                                      .length <
                                                                  6 ||
                                                              val.isEmpty) {
                                                            return ('الاحرف قليلة جدا');
                                                          } else if (val
                                                                  .trim()
                                                                  .length >
                                                              30) {
                                                            return ('الاحرف كثيرة جدا');
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        onSaved: (val) =>
                                                            fullName = val,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          icon: Icon(
                                                              Icons.person),
                                                          labelText:
                                                              'الاسم بالكامل',
                                                          labelStyle: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              child: Container(
                                                height: 50,
                                                width: 350,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'تأكيد',
                                                    style:
                                                        infoWidget.titleButton,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                final form =
                                                    _formKey.currentState;
                                                if (form.validate()) {
                                                  form.save();
//                                          SnackBar snackBar = SnackBar(content: Text('Welcome !'),);
//                                          _scaffoldKey.currentState.showSnackBar(snackBar) ;
                                                  await rescueRef
                                                      .document(currentRes.id)
                                                      .updateData({
                                                    'fullName': fullName,
                                                    'phone': phone,
                                                  });
                                                  Navigator.pop(context);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Feeds(rescueId: currentRes?.id),
                  OnProgressFeeds(rescueId: currentRes?.id),
                  DoneFeeds(rescueId: currentRes?.id),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildUnAuthScreen() {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          alignment: Alignment.center,
          /*decoration: BoxDecoration(
            color: Colors.white,
//            image: DecorationImage(
//              image: NetworkImage("https://i.pinimg.com/564x/48/38/cf/4838cff15e2a9475e8eafe3b6bd26196.jpg"),
//              fit: BoxFit.cover,
//            ),
          ),*/
//        decoration: BoxDecoration(
//          gradient: LinearGradient(
//            begin: Alignment.topRight ,
//            end: Alignment.bottomLeft ,
//            colors: [
//              Colors.grey ,
//              Colors.red.shade700,
//            ],
//          ),
//        ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              /*Image.network(
                'https://mlwrgkwihpcc.i.optimole.com/s7BSVHY.ed7v~4dab4/w:auto/h:auto/q:auto/https://www.marquiscenters.com/wp-content/uploads/2019/05/location-2.png',
                height: 150,
                width: 90,
                fit: BoxFit.fill,
              ),*/
              Image.asset('img/homeimg.jpg'),
              Text(
                'نظام الطوارئ 218',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              /*ColorizeAnimatedTextKit(
                  totalRepeatCount: 9,
                  pause: Duration(milliseconds: 1000),
                  isRepeatingAnimation: true,
                  speed: Duration(seconds: 1),
                  text: [' 218 Rescue App '],
                  textStyle: TextStyle(fontSize: 25, fontFamily: "Horizon"),
                  colors: [
                    //Colors.black87,
                    // Colors.grey[400],
                    Colors.red,
//                    Colors.grey[400],
                    Colors.white30,
                  ],
                  textAlign: TextAlign.start,
                  alignment:
                      AlignmentDirectional.topStart // or Alignment.topLeft
                  ),*/
              SizedBox(
                height: 10,
              ),
              Text(
                'تطبيق المنقذ ',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              /*ColorizeAnimatedTextKit(
                  totalRepeatCount: 9,
                  pause: Duration(milliseconds: 1000),
                  isRepeatingAnimation: true,
                  speed: Duration(seconds: 1),
                  text: [' تطبيق المنقذ '],
                  textStyle: TextStyle(fontSize: 20, fontFamily: "Horizon"),
                  colors: [
                    Colors.white30,

                    Colors.grey[400],
//                    Colors.red,
//                    Colors.grey[400],
                    Colors.black87,
                  ],
                  textAlign: TextAlign.start,
                  alignment:
                      AlignmentDirectional.topStart // or Alignment.topLeft
                  ),*/
//              Text(
//                ,
//                style: TextStyle(
//                  fontSize: 20,
//                  fontWeight: FontWeight.bold,
//                  color: Colors.black38,
//                ),
//              ),
              Spacer(),
              Text(
                'تسجيل الدخول باستخدام حساب غوغل',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  login();
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('img/google.png'),
                    fit: BoxFit.cover,
                  )),
                ),
              ),
              SizedBox(
                height: 120,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
