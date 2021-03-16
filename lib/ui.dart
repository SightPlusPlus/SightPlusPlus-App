//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_speech/flutter_speech.dart';
//import 'listen.dart';
//import 'package:flutter_tts_improved/flutter_tts_improved.dart';
//
//const languages = const [
//  const Language('English', 'en_US'),
//  const Language('Francais', 'fr_FR'),
//  const Language('Pусский', 'ru_RU'),
//  const Language('Italiano', 'it_IT'),
//  const Language('Español', 'es_ES'),
//];
//
//class Language {
//  final String name;
//  final String code;
//
//  const Language(this.name, this.code);
//}
//
//class SpeechToText extends StatefulWidget {
//  @override
//  _SpeechToTextState createState() => new _SpeechToTextState();
//}
//
//class _SpeechToTextState extends State<SpeechToText> {
//  FlutterTtsImproved tts = FlutterTtsImproved();
//  SpeechRecognition _speech;
//  bool _speechRecognitionAvailable = false;
//  bool _isListening = false;
//  String transcription = '';
//  bool _active = false;
//  Color _color = Colors.green;
//
//  String _currentLocale = 'en_US';
//  Language selectedLang = languages.first;
//
//  @override
//  initState() {
//    super.initState();
//    activateSpeechRecognizer();
//  }
//
//  // Platform messages are asynchronous, so we initialize in an async method.
//  void activateSpeechRecognizer() {
//    print('...');
//    _speech = new SpeechRecognition();
//    _speech.setAvailabilityHandler(onSpeechAvailability);
//    _speech.setRecognitionStartedHandler(onRecognitionStarted);
//    _speech.setRecognitionResultHandler(onRecognitionResult);
//    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
//    _speech.setErrorHandler(errorHandler);
//    _speech.activate(_currentLocale).then((res) {
//      setState(() => _speechRecognitionAvailable = res);
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    if(transcription.isNotEmpty) {
//      Listen listen = new Listen();
////      Listen listen = new Listen(transcript: transcription);
//      listen.choose();
//    }
//
//    return new Scaffold(
//        backgroundColor: _color,
//        body: InkWell(
//          child: Center(
//            child: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: [
//                  !_active
//                      ? Icon(Icons.mic_none_outlined,
//                          color: Colors.white, size: 70)
//                      : SizedBox(),
//                  SizedBox(width: 10),
//                  _active
//                      ? Text(
//                          'Listening...',
//                          style: TextStyle(fontSize: 70, color: Colors.white),
//                        )
//                      : Text(
//                          'Listen',
//                          style: TextStyle(fontSize: 70, color: Colors.white),
//                        ),
//                ]),
//          ),
//          onTap: _speechRecognitionAvailable && !_isListening
//              ? () => takeAction(_active = true)
//              : () => takeAction(_active = false),
//        ));
//  }
//
//  void takeAction(bool active) {
//    if (active == true) {
//      _color = Colors.red;
////      tts.speak("I am listening");
//      sleep1();
//      start();
//    } else {
//      _color = Colors.green;
//      stop();
//      sleep1();
////      tts.speak("Listening stopped");
//    }
//  }
//
//  List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
//      .map((l) => new CheckedPopupMenuItem<Language>(
//            value: l,
//            checked: selectedLang == l,
//            child: new Text(l.name),
//          ))
//      .toList();
//
//  void _selectLangHandler(Language lang) {
//    setState(() => selectedLang = lang);
//  }
//
//  void start() => _speech.activate(selectedLang.code).then((_) {
//        return _speech.listen().then((result) {
//          print('...');
//
//          setState(() {
//            _isListening = result;
//          });
//        });
//      });
//
//  void cancel() =>
//      _speech.cancel().then((_) => setState(() => _isListening = false));
//
//  void stop() => _speech.stop().then((_) {
//        setState(() => _isListening = false);
//      });
//
//  void onSpeechAvailability(bool result) =>
//      setState(() => _speechRecognitionAvailable = result);
//
//  void onCurrentLocale(String locale) {
//    print('...');
//
//    setState(
//        () => selectedLang = languages.firstWhere((l) => l.code == locale));
//  }
//
//  void onRecognitionStarted() {
//    setState(() => _isListening = true);
//  }
//
//  void onRecognitionResult(String text) {
//    print('...');
//
//    setState(() => transcription = text);
//  }
//
//  void onRecognitionComplete(String text) {
//    print('...');
//
//    setState(() => _isListening = false);
//  }
//
//  void errorHandler() {
//    activateSpeechRecognizer();
//  }
//
//  Future sleep1() {
//    return new Future.delayed(const Duration(seconds: 1), () => "1");
//  }
//}
