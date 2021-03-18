import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';
import 'listen.dart';

const languages = const [
  const Language('English', 'en_US'),
  const Language('Francais', 'fr_FR'),
  const Language('Pусский', 'ru_RU'),
  const Language('Italiano', 'it_IT'),
  const Language('Español', 'es_ES'),
];

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

class SpeechToText extends StatefulWidget {
  final String path;

  const SpeechToText({Key key, this.path}) : super(key: key);

  @override
  _SpeechToTextState createState() => new _SpeechToTextState();
}

class _SpeechToTextState extends State<SpeechToText> {
  SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  bool _needsToSpeak = false;
  String setting;
  String newSetting;
  Position _position;

  FlutterTts flutterTts;
  String language;
  double volume = 0.5;
  double pitch = 0.8;
  double rate = 0.7;

  bool isCurrentLanguageInstalled = false;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWeb => kIsWeb;

  String transcription = '';

  //String _currentLocale = 'en_US';
  Language selectedLang = languages.first;

  Coordinates coordinates;

  _getLocation(double lat, double long) async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    final coordinates = new Coordinates(position.latitude, position.longitude);
    print(coordinates);
    double dist = await Geolocator().distanceBetween(
        lat, long, coordinates.latitude, coordinates.longitude);
    print("dist : $dist");
    return (dist);
  }

  Future<dynamic> calculateDistance(
      double lat, double long, Coordinates myCoordinates) async {
    double dist = await Geolocator().distanceBetween(
        lat, long, myCoordinates.latitude, myCoordinates.longitude);
    return (dist);
  }

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getEngines();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _speak(String text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (text != null) {
      if (text.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(text);
      }
    }
  }

  Future _chooseToSpeak(String text, bool needsToSpeak) async {
    if (needsToSpeak == true) {
      if (_isListening == false) {
        _speak(text);
      }
    } else {
      _stop();
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

//  Future _pause() async {
//    var result = await flutterTts.pause();
//    if (result == 1) setState(() => ttsState = TtsState.paused);
//  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void activateSpeechRecognizer() {
    print('_SpeechToTextState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate('en_US').then((res) {
      setState(() => _speechRecognitionAvailable = res);
    });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference dbRef =
        FirebaseDatabase.instance.reference().child(widget.path);
    DatabaseReference locationRef =
        FirebaseDatabase.instance.reference().child('locations');

    renderCommands(transcription);

    return StreamBuilder(
      stream: dbRef.onValue,
      builder: (context, snap) {
        if (snap.hasData &&
            !snap.hasError &&
            snap.data.snapshot.value != null) {
          Map data = snap.data.snapshot.value;

          _chooseToSpeak(data['name'] + data['distance'].toString() + 'meters',
              _needsToSpeak);

          return new Scaffold(
              body: _buildButton(
            onPressed: () {
              if (_speechRecognitionAvailable && !_isListening) {
//                Vibration.vibrate(pattern: [100, 500, 100, 500]);
                start();
              } else {
//                Vibration.vibrate(pattern: [100, 100, 100, 100]);
                stop();
              }
            },
            label:
                _isListening ? 'Listening...' : 'Listen (${selectedLang.code})',
          ));
        } else
          return Text("No data"); //TODO apare si nu e bine
      },
    );
  }

  List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
      .map((l) => new CheckedPopupMenuItem<Language>(
            value: l,
            checked: selectedLang == l,
            child: new Text(l.name),
          ))
      .toList();

  void _selectLangHandler(Language lang) {
    setState(() => selectedLang = lang);
  }

  Widget _buildButton({String label, VoidCallback onPressed}) =>
      new InkWell(onTap: onPressed, child: showButton());

  Widget showButton() {
    if (_isListening == false) {
      return new Container(
        color: Colors.green[700],
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 70,
                color: Colors.white,
              ),
              Text(
                "Tap to Listen",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    } else {
      return new Container(
        color: Colors.red,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Listening...",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }

  void start() => _speech.activate(selectedLang.code).then((_) {
        return _speech.listen().then((result) {
          print('_SpeechToTextState.start => result $result');
          _stop();
          setState(() {
            _isListening = result;
          });
        });
      });

  void cancel() =>
      _speech.cancel().then((_) => setState(() => _isListening = false));

  void stop() => _speech.stop().then((_) {
        setState(() => _isListening = false);
      });

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    print('_SpeechToTextState.onCurrentLocale... $locale');
    setState(
        () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  void onRecognitionResult(String text) {
    print('_SpeechToTextState.onRecognitionResult... $text');
    if (setting != null) {
      setState(() => newSetting = text);
    } else {
      setState(() => transcription = text);
    }
  }

  void onRecognitionComplete(String text) {
    print('_SpeechToTextState.onRecognitionComplete... $text');
    setState(() => _isListening = false);
  }

  void errorHandler() => activateSpeechRecognizer();

  String correctString(String value) {
    switch (value) {
      case 'zero':
        return '0';
      case 'one':
        return '1';
      case 'two':
        return '2';
      default:
        return value;
    }
  }

  void changePitch(String pitchValue) {
    pitchValue = correctString(pitchValue);
    setState(() {
      _needsToSpeak = false;
      pitch = double.parse(pitchValue);
    });
  }

  void changeRate(String rateValue) {
    rateValue = correctString(rateValue);
    setState(() {
      _needsToSpeak = false;
      rate = double.parse(rateValue);
    });
  }

  void changeVolume(String volumeValue) {
    volumeValue = correctString(volumeValue);
    setState(() {
      _needsToSpeak = false;
      volume = double.parse(volumeValue);
    });
  }

  //todo
  dynamic chooseAction(String text) {
    List<String> words = text.split(' ');
    if (words.length == 1) {
      switch (text) {
        case 'start':
        case 'run':
          return 'start';
          break;
        case 'stop':
        case 'cancel':
          return 'stop';
          break;
        case 'location':
          {
            _getLocation(45, 23);

            break;
          }
        default:
          return null;
          break;
      }
    } else if (words.length > 1) {
      List<dynamic> settings;
      switch (words[0]) {
        case 'beach':
          changePitch(words[words.length - 1]);
          break;
        case 'rate':
        case 'speed':
          changeRate(words[words.length - 1]);
          break;
        case 'volume':
          changeVolume(words[words.length - 1]);
          break;
        case 'language':
          changeVolume(words[words.length - 1]);
          break;
        default:
          return null;
          break;
      }
    }
  }

  void renderCommands(String text) {
    switch (chooseAction(text)) {
      case 'start':
        setState(() => _needsToSpeak = true);
        break;
      case 'stop':
        setState(() => _needsToSpeak = false);
        break;
      default:
        break;
    }
  }
}
