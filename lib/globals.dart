import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
int timerSec = 15;

List <String> fullImgList = [
  'greenLeftFoot.gif', 'greenRightFoot.gif', 'greenLeftHand.gif', 'greenRightHand.gif',
  'blueLeftFoot.gif', 'blueRightFoot.gif', 'blueLeftHand.gif', 'blueRightHand.gif',
  'redLeftFoot.gif', 'redRightFoot.gif', 'redLeftHand.gif', 'redRightHand.gif',
  'yellowLeftFoot.gif', 'yellowRightFoot.gif', 'yellowLeftHand.gif', 'yellowRightHand.gif',
];

List <BodyPos> bodyPositions = [];

glFillBodyPositions(){
  bodyPositions.add(BodyPos('greenLeftFoot.gif', 'Левая нога на Зелёный'));
  bodyPositions.add(BodyPos('greenRightFoot.gif', 'Правая нога на Зелёный'));
  bodyPositions.add(BodyPos('greenLeftHand.gif', 'Левая рука на Зелёный'));
  bodyPositions.add(BodyPos('greenRightHand.gif', 'Правая рука на Зелёный'));

  bodyPositions.add(BodyPos('blueLeftFoot.gif', 'Левая нога на Синий'));
  bodyPositions.add(BodyPos('blueRightFoot.gif', 'Правая нога на Синий'));
  bodyPositions.add(BodyPos('blueLeftHand.gif', 'Левая рука на Синий'));
  bodyPositions.add(BodyPos('blueRightHand.gif', 'Правая рука на Синий'));

  bodyPositions.add(BodyPos('redLeftFoot.gif', 'Левая нога на Красный'));
  bodyPositions.add(BodyPos('redRightFoot.gif', 'Правая нога на Красный'));
  bodyPositions.add(BodyPos('redLeftHand.gif', 'Левая рука на Красный'));
  bodyPositions.add(BodyPos('redRightHand.gif', 'Правая рука на Красный'));

  bodyPositions.add(BodyPos('yellowLeftFoot.gif', 'Левая нога на Жёлтый'));
  bodyPositions.add(BodyPos('yellowRightFoot.gif', 'Правая нога на Жёлтый'));
  bodyPositions.add(BodyPos('yellowLeftHand.gif', 'Левая рука на Жёлтый'));
  bodyPositions.add(BodyPos('yellowRightHand.gif', 'Правая рука на Жёлтый'));
}

class BodyPos {
  String name='', img='';
  BodyPos(this.img, this.name);
  @override
  String toString() {
    return '$name $img';
  }
}

initSharedPrefs() async {
  prefs = await SharedPreferences.getInstance();
}

initTts() async {
  flutterTts = FlutterTts();
  if (Platform.isIOS) {
    // printD('isIOS!');
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
    printD('android with defEng $defEng');
    if (!defEng.contains('google')) {
      var engines = await flutterTts.getEngines;
      printD('engines $engines');
      int gIdx = engines.indexWhere((element) => element.toString().contains('google'));
      await flutterTts.setEngine(engines[gIdx]);
      printD('def enginr set to ${engines[gIdx]}');
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
  printD('initSpeechState hasSpeech $hasSpeech');
}

void errorListener(SpeechRecognitionError error) {
  printD('got STT error $error');
  isListening = false; glSetState((){});
}

void statusListener(String status) {
  printD("Received listener status: $status, listening: ${speech.isListening}");
}

printD(s) {
  if (kDebugMode) {
    print(s);
  }
}

showAlertPage(context, String msg, [double tsf=1]) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(msg, textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 30,),
              ElevatedButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('OK')),
            ],
          ),
        );
      }
  );
}
