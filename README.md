# SightPlusPLus - Flutter Application

A flutter application designed for visually impaired people. It works alongside the Client and the Server. It uses voice commands and text to speech technologies to help the user control it as easily as possible. Works on both Android and iOS devices.

## How it works

The user uses his/her voice to control the system. When any part of the screen is pressed, the system will start listening also giving haptic and acoustic feedback. When it's started, it reads data from the Firebase Realtime Database where the object the camera sees are stored and updated. The messages are read using a Text to Speech API. The system can run with multiple cameras, that can be either static or mobile. Moreover, it adds reports data to a SQLite local database (stored on the phone).

## How to use it

You need to download and start the [Server](https://github.com/SightPlusPlus/SightPlusPlus-Server) and the [Client](https://github.com/SightPlusPlus/SightPlusPlus-Client) systems.
Download the APK (for Android) or the IPA (for iOS) and install it on your device. You can also download the code and run it on an emulator, or even emulate it on your own device. Now press the screen and tell the system to START, STOP, change SPEED (e.g SPEED 0.6), VOLUME or PITCH, turn on/off the VIBRATION or start the system for the static cameras(by staying location). Double-tap the screen to work that there was an error with the recognized object.

Examples of commands accepted (START/RUN, STOP, LOCATIONS, SPEED/RATE X (0.0 - 1.0), PITCH (0.5 - 2.0), VOLUME (0.0 - 0.5), VIBRATION ON/OFF).

## Future work

- Add new languages
- Add new functionality such as navigation
- Add video calling feature. The visually impaired person can call a friend or a relative to ask for help in recognizing an object.
