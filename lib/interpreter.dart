import 'package:flutter/cupertino.dart';
import 'package:sight/speech_to_text.dart';

class Interpreter {
  String result;

  Interpreter({this.result});

  Widget function () {
    return SpeechToText();
  }
}
