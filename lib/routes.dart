import 'package:flutter/material.dart';
import 'package:sight/custom_route.dart';
import 'package:sight/ip_address.dart';
import 'package:sight/loading.dart';
import 'package:sight/speech_to_text.dart';

class Routing {
  static String path;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/loading':
        return CustomRoute(builder: (_) => Loading());
        break;
      case '/vui':
        return CustomRoute(
            builder: (_) => SpeechToText(
                  path: settings.arguments,
                ));
      default:
        return null;
    }
  }
}
