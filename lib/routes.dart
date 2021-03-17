//import 'package:covidhelper_v2/components/loading_screen.dart';
//import 'package:covidhelper_v2/components/navigation/feedback.dart';
//import 'package:covidhelper_v2/components/navigation/settings.dart';
//import 'package:covidhelper_v2/components/vulnerable/cart.dart';
//import 'package:covidhelper_v2/components/vulnerable/get_products.dart';
//import 'package:covidhelper_v2/pages/admin_panel.dart';
//import 'package:covidhelper_v2/pages/loading.dart';
//import 'package:covidhelper_v2/pages/register/register_address.dart';
//import 'package:covidhelper_v2/pages/vendor/vendor_home.dart';
//import 'package:covidhelper_v2/pages/volunteer/home_volunteer/home.dart';
//import 'package:covidhelper_v2/pages/vulnerables_main.dart';
//import 'package:flutter/material.dart';
//
//import 'components/change_name.dart';
//import 'components/change_password.dart';
//import 'components/update_user.dart';
//import 'components/vulnerable/personal_details.dart';
//import 'models/address.dart';
//import 'pages/login.dart';
//import 'pages/register/custom_route.dart';
//import 'pages/register/register_back.dart';
//import 'pages/register/register_choose.dart';
//import 'pages/register/register_email.dart';
//import 'pages/register/register_name.dart';
//import 'pages/register/register_password.dart';
//import 'pages/register/register_phone.dart';
//
//class Routing {
//  static String email;
//  static String name;
//  static String phoneNumber;
//  static String password;
//  static AddressCoordAndText address;
//  static String userValue;
//
//  static Route<dynamic> generateRoute(RouteSettings settings) {
//    final args = settings.arguments;
//    switch (settings.name) {
//      case '/loading':
//        return CustomRoute(builder: (_) => Loading());
//        break;
//      case '/admin_panel':
//        return CustomRoute(
//            builder: (_) => AdminPanel(data: settings.arguments));
//        break;
//      case '/admin_panel/change_name':
//        return CustomRoute(
//            builder: (_) => ChangeName(data: settings.arguments));
//        break;
//      case '/admin_panel/change_password':
//        return CustomRoute(
//            builder: (_) => ChangePassword(data: settings.arguments));
//        break;
//      case '/admin_panel/user/update_details':
//        return CustomRoute(
//            builder: (_) => UpdateInfoUser(data: settings.arguments));
//        break;
//      case '/vulnerable_main':
//        return CustomRoute(
//            builder: (_) => VulnerablesMain(data: settings.arguments));
//        break;
//      case '/vulnerable_main/shopping_cart':
//        return CustomRoute(
//            builder: (_) => ShoppingCart(data: settings.arguments,));
//        break;
//      case '/vulnerable_main/get_products':
//        return CustomRoute(builder: (_) => GetProducts());
//        break;
//      case '/vulnerable_main/personal_details':
//        return CustomRoute(
//            builder: (_) => PersonalDetails(data: settings.arguments));
//        break;
//      case '/login':
//        return CustomRoute(builder: (_) => Login());
//        break;
//      case '/volunteer_home':
//        return CustomRoute(builder: (_) => Home(data: settings.arguments));
//        break;
//      case '/vendor_home':
//        return CustomRoute(builder: (_) => VendorHome(data: settings.arguments));
//        break;
//      case '/settings':
//        return CustomRoute(builder: (_) => Settings(data: settings.arguments));
//        break;
//      case '/feedback':
//        return CustomRoute(
//            builder: (_) => PersonFeedback(data: settings.arguments));
//        break;
//      case '/register_choose':
//        return CustomRoute(builder: (_) => RegisterChoose());
//        break;
//      case '/login':
//        return CustomRoute(builder: (_) => Login());
//        break;
//      case '/register_email':
//        Routing.userValue = args;
//        return CustomRoute(builder: (_) => RegisterEmail());
//        break;
//      case '/register_password':
//        Routing.email = args;
//        return CustomRoute(builder: (_) => RegisterPassword());
//        break;
//      case '/register_name':
//        Routing.password = args;
//        return CustomRoute(builder: (_) => RegisterName());
//        break;
//      case '/register_phone':
//        Routing.name = args;
//        return CustomRoute(builder: (_) => RegisterPhone(userValue: Routing.userValue,));
//        break;
//      case '/register_address':
//        Routing.phoneNumber = args;
//        return CustomRoute(builder: (_) => RegisterAddress());
//        break;
//      case '/loading_screen_vendor':
//        Routing.address = args;
//        RegisterBack registerBack = new RegisterBack(
//            name: Routing.name,
//            email: Routing.email,
//            phoneNumber: Routing.phoneNumber,
//            address: address.addressText,
//            long: address.long,
//            lat: address.lat,
//            password: Routing.password,
//            userValue: Routing.userValue);
//        new LoadingScreen(registerBack: registerBack);
//        return CustomRoute(
//            builder: (_) => LoadingScreen(registerBack: registerBack));
//      case '/loading_screen':
//        RegisterBack registerBack = new RegisterBack(
//            name: Routing.name,
//            email: Routing.email,
//            phoneNumber: Routing.phoneNumber,
//            password: Routing.password,
//            userValue: Routing.userValue);
//        new LoadingScreen(registerBack: registerBack);
//        return CustomRoute(
//            builder: (_) => LoadingScreen(registerBack: registerBack));
//        break;
//      case '/volunteer_home':
//        return CustomRoute(builder: (_) => Home(data: settings.arguments));
//        break;
//      case '/vendor_home':
//        return CustomRoute(builder: (_) => VendorHome(data: settings.arguments));
//        break;
//      case '/home':
//        if (Routing.userValue == 'vendor') {
//          return CustomRoute(builder: (_) => VendorHome(data: settings.arguments));
////        return CustomRoute(builder: (_) => Home(volunteer: args));
//        } else if (Routing.userValue == 'volunteer') {
//          return CustomRoute(builder: (_) => Home(data: settings.arguments));
//          // return CustomRoute(builder: (_) => Home(volunteer: args));
//        }
//        break;
//      default:
//        return null;
//    }
//  }
//}
