import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sight/convert_coordinates.dart';
import 'package:sight/loading.dart';
import 'package:sight/models/record.dart';
import 'package:sight/objects_db.dart';
import 'package:vibration/vibration.dart';

// Languages
const languages = const [
  const Language('English', 'en_US'),
];

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

class SpeechToText extends StatefulWidget {
  //  Path to the database child
  final String path;

  const SpeechToText({Key key, this.path}) : super(key: key);

  @override
  _SpeechToTextState createState() => new _SpeechToTextState();
}

enum TtsState { playing, stopped, paused, continued }

class _SpeechToTextState extends State<SpeechToText> {
  //  Initialization of the var needed for
  //  The speech to text part (speech recognition)
  SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  bool _needsToSpeak = false;

  //  Initialization of the var needed for the speaking part (text to speech)
  FlutterTts flutterTts;
  String language;
  double volume = 0.5;
  double pitch = 0.8;
  double speed = 0.7;

  //  Initialization of the var needed for
  //  Changing the settings (volume, speed, pitch)
  String setting;
  String newSetting;
  bool vibration = true;

  //  Initialization of the var needed for the location part
  double minDistance = double.infinity;
  String locationSelected;
  Coordinates coordinates;

  // Initialization  for SQLite Reports database
  bool _isRemote;
  String wasError = 'false';
  ObjectsDb _objectsDb = new ObjectsDb();

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWeb => kIsWeb;

  Language selectedLang = Language('English', 'en_US');

  //  String that contains the last message the speech recognition understood
  String transcription = '';

  /// function that initialize the Text to Speech
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

  /// Function that gets the location of the user
  /// Called whenever the user presses the "Listening Button"
  /// Used for the Static Cameras
  _getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      coordinates = new Coordinates(position.latitude, position.longitude);
    });
  }

  /// Function used to calculate the distance between 2 locations (given by coordinates)
  /// Called when the user says "Location"
  /// Used to calculate the closest location from the database
  /// Which is used to choose the location from there the Static Stream will start
  ///
  /// Returns [dist] - the distance
  Future<dynamic> _calculateDistance(
      double lat, double long, Coordinates myCoordinates) async {
    if (myCoordinates != null) {
      double dist = await Geolocator().distanceBetween(
          lat, long, myCoordinates.latitude, myCoordinates.longitude);
      return (dist);
    }
  }

  /// Function that uses the Text to Speech API and speaks [text]
  Future _speak(String text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(speed);
    await flutterTts.setPitch(pitch);

    if (text != null) {
      if (text.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(text);
      }
    }
  }

  /// Function that adds a report into the SQLite database
  ///
  /// The report will contain:
  /// [name] of the recognised object
  /// [time] (hour) at which the object was recognised
  /// [date] at which the object was recognised
  /// [location] the location where the object was recognised
  /// [error] a String that changes the value from 'false' to 'true'
  /// when the user reports that the system made a mistake
  /// [remote] 'true' is the system is working with remote cameras or
  /// 'false' if it's working with remote cameras
  void addReport(String name) {
    var now = DateTime.now();
    String time = DateFormat('kk:mm:ss').format(now);
    String date = DateFormat('dd/MM/yyyy').format(now);
    Record record = new Record(
        object: name,
        time: time,
        date: date,
        location: coordinates.toString(),
        error: wasError,
        remote: _isRemote.toString());
    _objectsDb.addToDb(record);
  }

  /// Function that that chooses when the system needs to speak
  ///
  /// [data] - contains the messages which can be spoken
  /// [needsToSpeak] - true when it's time for the system to speak, false otherwise
  Future _chooseToSpeak(Map data, bool needsToSpeak) async {
    if (needsToSpeak == true) {
      if (_isListening == false) {
        if (data['priority'] == '4') {
          customVibration(duration: 50, error: false, warning: true);
        }
        _speak(data['message']);
        addReport(data['name']);
      }
    } else {
      _stopSpeak();
    }
  }

  /// Function that stops the Text to Speech from speaking
  Future _stopSpeak() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
    initTts();
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  /// Platform messages are asynchronous, so we initialize in an async method
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

  /// Function that starts the Speech to Text
  void startSpeechToText() => _speech.activate(selectedLang.code).then((_) {
        return _speech.listen().then((result) {
          _stopSpeak();
          setState(() {
            _isListening = result;
          });
        });
      });

  /// Function that cancels the Speech to Text
  void cancel() =>
      _speech.cancel().then((_) => setState(() => _isListening = false));

  /// Function that stops the Speech to Text
  void stop() => _speech.stop().then((_) {
        setState(() => _isListening = false);
      });

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    setState(
        () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  /// Function that sets either the [transcript] or the [newSetting]
  /// Used to differentiate the moments when the system needs
  /// a change in the settings or needs to be started/stopped
  void onRecognitionResult(String text) {
    print('_SpeechToTextState.onRecognitionResult... $text');
    if (setting != null) {
      setState(() => newSetting = text);
    } else {
      setState(() => transcription = text);
    }
  }

  void onRecognitionComplete(String text) {
    setState(() => _isListening = false);
  }

  void errorHandler() {
    setState(() {
      _isListening = false;
    });
    activateSpeechRecognizer();
  }

  /// Function that converts the literal value of numbers into digits
  /// Gets [value] (e.g. 'one')
  /// Returns the numeric value of it (e.g. '1')
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

  /// Function to update the preferences for the pitch
  /// Gets [pitchValue] and sets it as the new value of the pitch
  void changePitch(String pitchValue) {
    pitchValue = correctString(pitchValue);
    setState(() {
      _needsToSpeak = false;
      pitch = double.parse(pitchValue);
    });
  }

  /// Function to update the preferences for the speed (rate)
  /// Gets [speedValue] and sets it as the new value of the speed (rate)
  void changeSpeed(String speedValue) {
    speedValue = correctString(speedValue);
    setState(() {
      _needsToSpeak = false;
      speed = double.parse(speedValue);
    });
  }

  /// Function to update the preferences for the volume
  /// Gets [volumeValue] and sets it as the new value of the volume
  void changeVolume(String volumeValue) {
    volumeValue = correctString(volumeValue);
    setState(() {
      _needsToSpeak = false;
      volume = double.parse(volumeValue);
    });
  }

  /// Function to update switches the vibration on and off
  /// Gets [vibrationValue] and decides if the user wants to use vibration or not
  void changeVibration(String vibrationValue) {
    if (vibrationValue == 'on') {
      setState(() {
        vibration = true;
      });
    } else if (vibrationValue == 'off' || vibrationValue == 'of') {
      setState(() {
        vibration = false;
      });
    }
  }

  /// Function that decides what the system should do
  /// Allows the user to use more words for certain tasks (start/play/run)
  void chooseAction(String text) {
    List<String> words = text.split(' ');
    switch (words[0]) {
      case 'start':
      case 'run':
      case 'play':
        setState(() {
          _isRemote = true;
          _needsToSpeak = true;
          locationSelected = null;
        });
        break;
      case 'stop':
      case 'cancel':
        setState(() {
          _needsToSpeak = false;
          locationSelected = null;
        });
        break;
      case 'location':
        {
          _isRemote = false;
          searchLocation();
          setState(() {
            _needsToSpeak = true;
          });
          break;
        }
      case 'pitch':
        changePitch(words[words.length - 1]);
        break;
      case 'speed':
      case 'speed':
        changeSpeed(words[words.length - 1]);
        break;
      case 'volume':
        changeVolume(words[words.length - 1]);
        break;
      case 'vibration':
        changeVibration(words[words.length - 1]);
        break;
      default:
        return null;
        break;
    }
  }

  /// Function that does the search for the closest location
  void searchLocation() {
    DatabaseReference locationRef =
        FirebaseDatabase.instance.reference().child('locations');
    Map<String, dynamic> mapOfMaps;

    locationRef.once().then((DataSnapshot snapshot) {
      mapOfMaps = Map.from(snapshot.value);

      mapOfMaps.forEach((key, value) async {
        ConvertCoordinates convertCoordinates =
            new ConvertCoordinates(oldCoordinates: key);
        List<String> locationCoordinates =
            convertCoordinates.convertCoordinates();
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

  /// Function that builds the button widget
  Widget _buildButton({VoidCallback onPressed}) => new InkWell(
      onTap: onPressed, child: showButton(), onDoubleTap: errorOccurred);

  void errorOccurred() {
    if (!_isListening) {
      _getLocation();
      customVibration(duration: 500, error: true, warning: false);
      setState(() {
        wasError = 'true';
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          wasError = 'false';
        });
      });
    }
  }

  /// Function for a custom vibration pattern
  void customVibration({int duration, bool error, bool warning}) {
    if (vibration) {
      if (error) {
        Vibration.vibrate(pattern: [50, duration, 50, duration, 50, duration]);
      } else if (warning) {
        Vibration.vibrate(
            pattern: [200, duration, 200, duration, 200, duration]);
      } else {
        Vibration.vibrate(pattern: [50, duration, 50, duration]);
      }
    }
  }

  /// Function that shows different states for the button
  /// It can be either green (when the system is now listening)
  /// of red (when the system is listening)
  Widget showButton() {
    if (_isListening == false) {
      return new Container(
        color: wasError == 'false' ? Colors.green[700] : Colors.black,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              wasError == 'true'
                  ? SizedBox()
                  : Icon(
                      Icons.play_circle_outline,
                      size: 70,
                      color: Colors.white,
                    ),
              Text(
                wasError == 'false' ? "Tap to Listen" : 'Error reported!',
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

  @override
  Widget build(BuildContext context) {
    chooseAction(transcription);

    // reference to the database
    DatabaseReference dbRef;
    if (locationSelected == null) {
      dbRef = FirebaseDatabase.instance.reference().child(widget.path);
    } else {
      dbRef = FirebaseDatabase.instance
          .reference()
          .child('locations/' + locationSelected);
    }

    return StreamBuilder(
      stream: dbRef.onValue,
      builder: (context, snap) {
        if (snap.hasData &&
            !snap.hasError &&
            snap.data.snapshot.value != null) {
          Map data = snap.data.snapshot.value;

          _chooseToSpeak(data, _needsToSpeak);

          return new Scaffold(
            body: _buildButton(
              onPressed: () {
                _getLocation();
                if (_speechRecognitionAvailable && !_isListening) {
                  customVibration(duration: 200, error: false, warning: false);
                  startSpeechToText();
                } else {
                  customVibration(duration: 80, error: false, warning: false);
                  stop();
                }
              },
            ),
          );
        } else
          return Loading();
      },
    );
  }
}
