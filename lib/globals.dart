import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

FlutterTts flutterTts = FlutterTts();
List <String> users = [];
int numPlayers = 3;
final SpeechToText speech = SpeechToText();
bool isListening = false;
late SharedPreferences prefs;
var glSetState;
bool isTimer = false;
int timerSec = 30;

initSharedPrefs() async {
  prefs = await SharedPreferences.getInstance();
}

initTts() async {
  flutterTts = FlutterTts();
  if (Platform.isIOS) {
    // print('isIOS!');
    // await flutterTts.setSharedInstance(true);
    // await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
    //     [IosTextToSpeechAudioCategoryOptions.mixWithOthers,],
    //     IosTextToSpeechAudioMode.voicePrompt
    // );
    await flutterTts.setSharedInstance(true);

    await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambient,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers
        ],
        IosTextToSpeechAudioMode.voicePrompt
    );
  } else {
    String defEng = await flutterTts.getDefaultEngine;
    print('android with defEng $defEng');
    if (!defEng.contains('google')) {
      var engines = await flutterTts.getEngines;
      print('engines $engines');
      int gIdx = engines.indexWhere((element) => element.toString().contains('google'));
      await flutterTts.setEngine(engines[gIdx]);
      print('def enginr set to ${engines[gIdx]}');
    }
  }
  await flutterTts.awaitSpeakCompletion(true);
  await flutterTts.setVolume(1);
  await flutterTts.setSpeechRate(0.45);
  await flutterTts.setPitch(1);
  // ru-RU uk-UA en-US
  await flutterTts.setLanguage('ru-RU');
}

Future<void> speak(String text) async {
  await Future.delayed(Duration(milliseconds: 300));
  await flutterTts.speak(text);
}

initSTT() async {
  bool hasSpeech = await speech.initialize(
      onError: errorListener, onStatus: statusListener);
  print('initSpeechState hasSpeech $hasSpeech');
}

void errorListener(SpeechRecognitionError error) {
  print('got STT error $error');
  isListening = false; glSetState((){});
}

void statusListener(String status) {
  print("Received listener status: $status, listening: ${speech.isListening}");
}
