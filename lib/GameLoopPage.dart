import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';

import 'globals.dart';

bool isListening = false;

class GameLoopPage extends StatefulWidget {
  final numPlayers;
  GameLoopPage(this.numPlayers);

  @override
  _GameLoopPageState createState() => _GameLoopPageState(numPlayers);
}

class _GameLoopPageState extends State<GameLoopPage> {
  int numPlayers;
  bool isFound = false;

  _GameLoopPageState(this.numPlayers);

  double picSize = 200.0;
//  List <Color> colorsList = [Colors.green, Colors.blue, Colors.red, Colors.yellow];
//  List <String> imgList = ['leftFoot.gif', 'rightFoot.gif', 'leftHand.gif', 'rightHand.gif'];
//  List <String> bodyParts = ['Левая нога', 'Правая нога', 'Левая рука', 'Правая рука'];
//  List <String> colorNames = ['Зелёный', 'Синий', 'Красный', 'Жёлтый'];
  List <String> fullImgList = [
    'greenLeftFoot.gif', 'greenRightFoot.gif', 'greenLeftHand.gif', 'greenRightHand.gif',
    'blueLeftFoot.gif', 'blueRightFoot.gif', 'blueLeftHand.gif', 'blueRightHand.gif',
    'redLeftFoot.gif', 'redRightFoot.gif', 'redLeftHand.gif', 'redRightHand.gif',
    'yellowLeftFoot.gif', 'yellowRightFoot.gif', 'yellowLeftHand.gif', 'yellowRightHand.gif',
  ];
  List <String> fullImgListNames = [
    'Левая нога на Зелёный', 'Правая нога на Зелёный', 'Левая рука на Зелёный', 'Правая рука на Зелёный',
    'Левая нога на Синий', 'Правая нога на Синий', 'Левая рука на Синий', 'Правая рука на Синий',
    'Левая нога на Красный', 'Правая нога на Красный', 'Левая рука на Красный', 'Правая рука на Красный',
    'Левая нога на Жёлтый', 'Правая нога на Жёлтый', 'Левая рука на Жёлтый', 'Правая рука на Жёлтый',
  ];
  int _count = 0, _lastKey = 0; //_colorCount = 0,
  static const int refreshPeriodMS = 300;
  int numLoopsToFindResult = 15, numLoop = 0;
  bool speakingMode = false;
  int playerNumber = 1;
  String playerTask = '';

  final SpeechToText speech = SpeechToText();
  bool showMic = false;//, isListening = false;
  double level=0;

  var rng = new Random();

  @override
  void initState() {
    initTtsAndStt();
    super.initState();
    Future.delayed(const Duration(milliseconds: refreshPeriodMS), randomizerLoop);
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    speech.errorListener = null;
    speech.statusListener = null;
    super.dispose();
  }

  randomizerLoop(){
    print('randomizerLoop');
    int _newCount = rng.nextInt(16);
    print('got new count $_newCount');
    numLoop++;
    _lastKey = _count; // + (_colorCount+1)*16
    if (numLoop < numLoopsToFindResult) {
      Future.delayed(const Duration(milliseconds: refreshPeriodMS), randomizerLoop);
    } else {
      Future.delayed(const Duration(milliseconds: refreshPeriodMS), (){
        startSpeakAndWaitMode(_newCount);
      });
    }
    setState(() {
      _count = _newCount;
    });
  }

  startSpeakAndWaitMode(_newCount) async {
    print('startSpeakAndWaitMode');
    numLoop = 0;
    setState(() {
      //playerTask = bodyParts[_newCount] + ' на ' + colorNames[_newColorCount] + '!';
      playerTask = fullImgListNames[_newCount] + '!';
    });
    await _speakSync('Игрок № $playerNumber');
    await _speakSync(playerTask);
    startListening();
  }

  void initTtsAndStt() async {
    await initSTT();
  }

  initSTT() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    print('initSpeechState hasSpeech $hasSpeech');
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received GLP error status: $error, listening: ${speech.isListening}");
    setState(() {
      isListening = false;
      print('isListening $isListening');
    });
    Future.delayed(Duration(milliseconds: 900), startListening);
  }

  void statusListener(String status) {
    //print("Received GLP listener status: $status, listening: ${speech.isListening}");
  }

  void startListening() async {
    print('startListening');
    await Future.delayed(Duration(milliseconds: 300));
    isListening = true;
    isFound = false;
    setState(() {
      showMic = true;
    });
    speech.listen(
      onResult: resultListener,
      // listenFor: Duration(seconds: 60),
      // pauseFor: Duration(seconds: 3),
      localeId: 'ru_RU', // en_US uk_UA ru_RU
      // onSoundLevelChange: soundLevelListener,
      cancelOnError: false,
      partialResults: true,
      // onDevice: true,
      // listenMode: ListenMode.confirmation,
      // sampleRate: 44100,
    );
  }

  // void soundLevelListener(double level) {
  //   setState(() {
  //     this.level = level;
  //   });
  // }

  void resultListener(SpeechRecognitionResult result) async {
    print ('got result $result');
    if (isFound) {
      return;
    }

    List <String> recognizedWords = result.recognizedWords.toString().toUpperCase().split(' ');
    print ('got recognizedWords $recognizedWords result.finalResult ${result.finalResult}');

    if (!result.finalResult) {
      print('not final result \n $recognizedWords');
      if (recognizedWords.indexOf('ПОВТОРИ') > -1) {
        print('found for ПОВТОРИ');
        speech.stop();
        isListening = false;
        isFound = true;
        return;
      } else if (recognizedWords.indexOf('ПРОИГРАЛ') > -1) {
        print('found for ПРОИГРАЛ');
        speech.stop();
        isListening = false;
        _playerLeft();
        isFound = true;
        return;
      } else if (recognizedWords.contains('НОВЫЙ') && recognizedWords.contains('ИГРОК')) {
        print('found for НОВЫЙ ИГРОК');
        speech.stop();
        isListening = false;
        _playerAdd();
        isFound = true;
        return;
      }
      recognizedWords.forEach((cmd) {
        if (cmd == 'OK' || cmd == 'О\'КЕ' || cmd == 'ОКЕЙ' || cmd == 'ДАЛЬШЕ' || cmd == 'СЛЕДУЮЩИЙ') {
          isFound = true;
          print('found for $cmd');
        }
      });
      if (isFound) {
        speech.stop();
        isListening = false;
        startNextPlayerLoop();
        return;
      }
    } else {
      isListening = false;
      setState(() {
        showMic = false;
      });
      if (recognizedWords.indexOf('OK') > -1 || recognizedWords.indexOf('О\'КЕЙ') > -1
          || recognizedWords.indexOf('ОКЕЙ') > -1
          || recognizedWords.indexOf('ДАЛЬШЕ') > -1 || recognizedWords.indexOf('ОК') > -1
          || recognizedWords.indexOf('СЛЕДУЮЩИЙ') > -1) {
        print('start new random loop');
        startNextPlayerLoop();
      } else if (recognizedWords.contains('НОВЫЙ') && recognizedWords.contains('ИГРОК')) {
        print('НОВ ИГР');
        _playerAdd();
      } else if (recognizedWords.indexOf('ПРОИГРАЛ') > -1) {
        print('ПРОИГРАЛ');
        _playerLeft();
      } else if (recognizedWords.indexOf('ПОВТОРИ') > -1) {
        print('repeat');
        repeatAndStartListeningAgain();
      } else {
        print('no keywords. StartListening again.');
        print(recognizedWords);
        startListening();
      }
    }
  }

  repeatAndStartListeningAgain() async {
    await _speakSync('Игрок № $playerNumber');
    await _speakSync(playerTask);
    startListening();
  }

  Future<void> _speakSync(String _text) async {
    await speak(_text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showMic? 'Жду команду' : 'Вращаем барабан!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Количество игроков $numPlayers',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40,),
            Text('Задание для игрока', textScaleFactor: 2, textAlign: TextAlign.center,),
            SizedBox(height: 10,),
            Text('№ $playerNumber',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 16,),
            Center(
              child: Container(
                height: picSize*1.1,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: refreshPeriodMS),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    //return ScaleTransition(child: child, scale: animation);
                    //return FadeTransition(child: child, opacity: animation);
                    //return RotationTransition(child: child, turns: animation);
                    //final offsetAnimation = Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0)).animate(animation);
                    //return ClipRect(child: SlideTransition(child: child, position: offsetAnimation));

                    final inAnimation =
                      Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                          .animate(animation);
                    final outAnimation =
                      Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0))
                          .animate(animation);

                    if (child.key == ValueKey(_lastKey)) {
                      return ClipRect(
                        child: SlideTransition(
                          position: inAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: child,
                          ),
                        ),
                      );
                    } else {
                      return ClipRect(
                        child: SlideTransition(
                          position: outAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: child,
                          ),
                        ),
                      );
                    }
                    //return ClipRect(child: SlideTransition(child: child, position: offsetAnimation));
                  },
                  child: Container(
                    key: ValueKey<int>(_count), // + (_colorCount+1)*16
                    width: picSize, height: picSize,
                      child: Image.asset('images/${fullImgList[_count]}')
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            showMic?
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(playerTask.replaceAll(' на ', '\n на '),
                    style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 26,),
                  Center(
                    child: GestureDetector(
                        onTap: (){
                          startNextPlayerLoop();
                        },
                        child: ActiveMic()  //Icon(Icons.mic, color: Colors.blueAccent, size: 50,)
                    ),
                  ),
                  SizedBox(height: 26,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Окей - следующий игрок',
                        style: TextStyle(
                            fontSize: 18,
                          color: Colors.white
                        ),
                      ),
                    ),
                    onPressed: startNextPlayerLoop,
                  ),
                  SizedBox(height: 30,)
                ],
              )
                :
              SizedBox(height: 275,)
            ,
          ],
        ),
      ),
    );
  }

  _playerLeft(){
    numPlayers --;
    if (numPlayers<2) {
      numPlayers = 2;
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Количество игроков $numPlayers',
              style: TextStyle(fontSize: 32),
            )
        )
    );
    randomizerLoop();
  }

  _playerAdd(){
    numPlayers ++;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Количество игроков $numPlayers',
              style: TextStyle(fontSize: 32),
            )
        )
    );
    randomizerLoop();
  }

  startNextPlayerLoop(){
    playerNumber++;
    if (playerNumber > numPlayers) {
      playerNumber = 1;
    }
    setState(() {
      showMic = false;
      playerTask = '';
    });
    randomizerLoop();
  }

  showAlertPage(String msg) {
    showAboutDialog(
      context: context,
      applicationName: 'Alert',
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 15), child: Center(child: Text(msg)))
      ],
    );
  }

}


class ActiveMic extends StatefulWidget {
  final double? size;
  final Color? bgOff;
  const ActiveMic({Key? key, this.size, this.bgOff}) : super(key: key);

  @override
  _ActiveMicState createState() => _ActiveMicState();
}

class _ActiveMicState extends State<ActiveMic> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  double size = 36;
  Color bgOff = Colors.white;

  @override
  void initState() {
    bgOff = widget.bgOff ?? Colors.blueAccent;
    super.initState();
    size = widget.size ?? 70;
    controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(controller);
    animation.addListener((){
      setState(() {});
    });
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      isListening?
      Opacity(
        opacity: animation.value,
        child: ClipOval(
          child: Container(
            padding: const EdgeInsets.all(5),
            color: bgOff,
            child: Icon(Icons.mic, color: Colors.redAccent[100], size: size,),
          ),
        ),
      )
          :
      ClipOval(
        child: Container(
          padding: const EdgeInsets.all(5),
          color: bgOff,
          child: Icon(Icons.mic, color: Colors.green[50], size: size,),
        ),
      );
  }
}
