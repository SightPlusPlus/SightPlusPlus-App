# SightPlusPLus - Flutter Application

A flutter application designed for visually impaired people. It works alongside the Client and the Server. It uses voice commands and text to speech technologies to help the user control it as easily as possible. Works on both Android and iOS devices.

## Link to APK

https://liveuclac-my.sharepoint.com/:u:/g/personal/zcabvud_ucl_ac_uk/EQxxIyK-tgZPnFGgm_Zo7zIBs09yk71X4JQooh_0qJq0sg?e=9JUZe1

## How it works

The user uses his/her voice to control the system. When any part of the screen is pressed, the system will start listening also giving haptic and acoustic feedback. When it's started, it reads data from the Firebase Realtime Database where the object the camera sees are stored and updated. The messages are read using a Text to Speech API. The system can run with multiple cameras, that can be either static or mobile. Moreover, it adds reports data to a SQLite local database (stored on the phone).

## How to use it

You need to download and start the [Server](https://github.com/SightPlusPlus/SightPlusPlus-Server) and the [Client](https://github.com/SightPlusPlus/SightPlusPlus-Client) systems.
Download the APK (for Android) or the IPA (for iOS) and install it on your device. You can also download the code and run it on an emulator, or even emulate it on your own device. Now press the screen and tell the system to START, STOP, change SPEED (e.g SPEED 0.6), VOLUME or PITCH, turn on/off the VIBRATION or start the system for the static cameras(by saying location). Double-tap the screen to warn that there was an error with the recognized object.
#### To make the system listen, tap the screen. To make the system report an error, double tap the screen.
## Examples of commands accepted:
#### START/RUN
Starts the remote system. Uses Text to Speech technologies to read messages from the database.
#### STOP
Stops any process.
#### LOCATIONS
Starts the static system.
#### SPEED/RATE X (0.0 - 1.0)
Changes the rate of speaking. Gets values from 0 to 1.
#### PITCH (0.5 - 2.0)
Changes the pitch of the speaking. Gets values from  0.5 to 2.
#### VOLUME (0.0 - 0.5)
Changes the volume of the speaking. Gets values from 0 to 1
#### VIBRATION ON/OFF)
Turns vibration on and off.

## How to work on the code

- You need to install the Flutter SDK. You can do it from here: https://flutter.dev/docs/get-started/install.
- Now you need to set up an editor. We recommend using Android Studio, but it’s up to you.
- You need to install the Flutter and Dart plugins. Now everything should work
- If you need to create a new APK, just type in the terminal (make sure you are in the root folder) flutter build apk.

## Future work

- Add new languages
- Add new functionality such as navigation
- Add video calling feature. The visually impaired person can call a friend or a relative to ask for help in recognizing an object.
- NOTE: The client and the app are both using Firebase. The credentials should be changed.

## Related APIs

+ [firebase](https://pub.dev/packages/firebase)
+ [firebase-core](https://pub.dev/packages/firebase_core)
+ [geolocatior](https://pub.dev/packages/geolocator)
+ [flutter_speech](https://pub.dev/packages/flutter_speech)
+ [firebase-database](https://pub.dev/packages/firebase_database)
+ [vibration](https://pub.dev/packages/vibration)
+ [flutter_tts_improved](https://pub.dev/packages/flutter_tts_improved)
+ [flutter_tts](https://pub.dev/packages/flutter_tts)
+ [geocoder](https://pub.dev/packages/geocoder)
+ [http](https://pub.dev/packages/http)
+ [sqflite](https://pub.dev/packages/sqflite)
+ [intl](https://pub.dev/packages/intl)
