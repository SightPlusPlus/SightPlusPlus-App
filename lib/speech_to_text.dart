import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sight/loading.dart';
import 'package:vibration/vibration.dart';

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

enum TtsState { playing, stopped, paused, continued }

class _SpeechToTextState extends State<SpeechToText> {
  SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  bool _needsToSpeak = false;
  String setting;
  String newSetting;
  double minDistance = double.infinity;
  String locationSelected;

  FlutterTts flutterTts;
  String language;
  double volume = 0.5;
  double pitch = 0.8;
  double rate = 0.7;

  static const audioPath = "beep.mp3";

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

  _getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      coordinates = new Coordinates(position.latitude, position.longitude);
    });
  }

  Future<dynamic> _calculateDistance(
      double lat, double long, Coordinates myCoordinates) async {
    if (myCoordinates != null) {
      double dist = await Geolocator().distanceBetween(
          lat, long, myCoordinates.latitude, myCoordinates.longitude);
      return (dist);
    }
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

  Future _chooseToSpeak(Map data, bool needsToSpeak) async {
    if (needsToSpeak == true) {
      if (_isListening == false) {
        if (data['priority'] == '4') {
          Vibration.vibrate(pattern: [200, 50, 200, 50, 200, 50]);
        }

        _speak(data['message']);
      }
    } else {
      _stop();
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

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
    DatabaseReference dbRef;
    if (locationSelected == null) {
      dbRef = FirebaseDatabase.instance.reference().child(widget.path);
    } else {
      dbRef = FirebaseDatabase.instance
          .reference()
          .child('locations/' + locationSelected);
    }
    renderCommands(transcription);

    return StreamBuilder(
      stream: dbRef.onValue,
      builder: (context, snap) {
        if (snap.hasData &&
            !snap.hasError &&
            snap.data.snapshot.value != null) {
          Map data = snap.data.snapshot.value;

          _chooseToSpeak(data, _needsToSpeak);

          return new Scaffold(body: _buildButton(
            onPressed: () {
              _getLocation();
              if (_speechRecognitionAvailable && !_isListening) {
                Vibration.vibrate(pattern: [50, 200, 50, 200]);
                start();
              } else {
                Vibration.vibrate(pattern: [50, 80, 50, 80]);
                stop();
              }
            },
          ));
        } else
          return Loading();
      },
    );
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
            searchLocation();
            setState(() {
              _needsToSpeak = true;
            });
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
        setState(() {
          _needsToSpeak = true;
          locationSelected = null;
        });
        break;
      case 'stop':
        setState(() {
          _needsToSpeak = false;
          locationSelected = null;
        });
        break;
      default:
        break;
    }
  }

  List<String> convertCoordinates(String oldCoordinates) {
    List<String> newCoordinates = [];
    int splitIndex;
    for (int index = 0; index < oldCoordinates.length; index++) {
      if (oldCoordinates[index] == '-') {
        oldCoordinates = oldCoordinates.substring(0, index) +
            '.' +
            oldCoordinates.substring(index + 1);
      } else if (oldCoordinates[index] == '+') {
        splitIndex = index;
      }
    }
    newCoordinates.add(oldCoordinates.substring(0, splitIndex));
    newCoordinates.add(oldCoordinates.substring(splitIndex + 1));
    return newCoordinates;
  }

  void searchLocation() {
    DatabaseReference locationRef =
        FirebaseDatabase.instance.reference().child('locations');
    Map<String, dynamic> mapOfMaps;

    locationRef.once().then((DataSnapshot snapshot) {
      mapOfMaps = Map.from(snapshot.value);

      mapOfMaps.forEach((key, value) async {
        List<String> locationCoordinates = convertCoordinates(key);
        double distance = await _calculateDistance(
            double.parse(locationCoordinates[0]),
            double.parse(locationCoordinates[1]),
            coordinates);

        if (distance < minDistance) {
          setState(() {
            minDistance = distance;
            locationSelected = key;
          });
        }
      });
    });
  }
}
