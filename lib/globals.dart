import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

FlutterTts flutterTts = FlutterTts();

initTts() async {
  flutterTts = FlutterTts();
  if (Platform.isIOS) {
    print('isIOS!');
    await flutterTts.setSharedInstance(true);
    await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.defaultMode
    );
  }
  await flutterTts.setVolume(1);
  await flutterTts.setSpeechRate(0.45);
  await flutterTts.setPitch(1);
  // ru-RU uk-UA en-US
  await flutterTts.setLanguage('ru-RU');
  await flutterTts.awaitSpeakCompletion(true);
}

Future<void> speak(String text) async {
  await flutterTts.speak(text);
}
