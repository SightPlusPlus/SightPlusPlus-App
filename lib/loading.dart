//import 'package:flutter/material.dart';
//
//class Loading extends StatefulWidget {
//  @override
//  _LoadingState createState() => _LoadingState();
//}
//
//class _LoadingState extends State<Loading> {
//  void loading() async {
//    FirebaseAuth _auth = FirebaseAuth.instance;
//    FirebaseUser user;
//    User currentUser;
//    user = await _auth.currentUser();
//    Firestore _db = Firestore.instance;
//
//    await Future.delayed(Duration(seconds: 2), () {});
//
//    if (user != null) {
//      currentUser = await FirestoreService().getUser(user);
//      var userData =
//      await _db.collection("Users").document(currentUser.uid).get();
//      var userInfo = await _db
//          .collection(userData['user_value'])
//          .document(currentUser.uid)
//          .get();
//
//      Map<String, dynamic> retrievedData = new Map<String, dynamic>();
//      retrievedData['userInfo'] = userInfo;
//
//      if (userData['user_value'] == 'Vulnerables') {
//        retrievedData['route'] = '/vulnerable_main';
//        retrievedData['type'] = "vulnerable";
//        retrievedData['vendors'] = FirestoreService().vendors;
//      } else if (userData['user_value'] == "Admins") {
//        retrievedData['route'] = '/admin_panel';
//        retrievedData['type'] = "admin";
//      } else if (userData['user_value'] == 'volunteer') {
//        var _currentOrder = await FirestoreService().getCurrentOrder(currentUser.uid);
//
//        if (_currentOrder.documents.length == 0) {
//          volunteer_orders = null;
//        } else {
//          volunteer_orders = Map<String,dynamic>();
//          volunteer_orders = _currentOrder.documents[0].data;
//        }
//
//        retrievedData['route'] = '/volunteer_home';
//        retrievedData['type'] = 'volunteer';
//      } else if (userData['user_value'] == 'vendor') {
//        retrievedData['route'] = '/vendor_home';
//        retrievedData['type'] = "vendor";
//      }
//
//      Navigator.pushNamedAndRemoveUntil(
//          context, retrievedData['route'], (route) => false,
//          arguments: retrievedData);
//    } else {
//      Navigator.pushNamedAndRemoveUntil(context, '/register_choose', (route) => false);
//    }
//  }
//
//  @override
//  void initState() {
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    loading();
//    return StartingLoading();
//  }
//}
