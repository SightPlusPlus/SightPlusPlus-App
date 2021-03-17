import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sight/ip_address.dart';
import 'package:sight/read.dart';
import 'package:sight/speech_to_text.dart';
import 'package:sight/testul.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeechToText(path: 'users/82-77-72-26/object')

//        home: Home(
//        path: 'users/82-77-72-26/object',
//      ),
    ));
