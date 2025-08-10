import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:async';
import 'globals.dart';

/*
старт - опред нов результат
форм рандом ряд картинок + результат
  как лист с офсетами, -номерКарт*пикСайз-офСет
старт анимации 0..1
показ картинок -
*/

class GameLoopPage extends StatefulWidget {
  GameLoopPage();

  @override
  _GameLoopPageState createState() => _GameLoopPageState();
}

class _GameLoopPageState extends State<GameLoopPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;
  int currentIndex = 0;
  int targetIndex = 0;
  int totalSteps = 0;

  bool isFound = false;
  double picSize = 200.0;
//  List <Color> colorsList = [Colors.green, Colors.blue, Colors.red, Colors.yellow];
//  List <String> imgList = ['leftFoot.gif', 'rightFoot.gif', 'leftHand.gif', 'rightHand.gif'];
//  List <String> bodyParts = ['Левая нога', 'Правая нога', 'Левая рука', 'Правая рука'];
//  List <String> colorNames = ['Зелёный', 'Синий', 'Красный', 'Жёлтый'];

  // List <String> fullImgListNames = [
  //   'Левая нога на Зелёный', 'Правая нога на Зелёный', 'Левая рука на Зелёный', 'Правая рука на Зелёный',
  //   'Левая нога на Синий', 'Правая нога на Синий', 'Левая рука на Синий', 'Правая рука на Синий',
  //   'Левая нога на Красный', 'Правая нога на Красный', 'Левая рука на Красный', 'Правая рука на Красный',
  //   'Левая нога на Жёлтый', 'Правая нога на Жёлтый', 'Левая рука на Жёлтый', 'Правая рука на Жёлтый',
  // ];

  int numLoopsToFindResult = 15, numLoop = 0;
  bool speakingMode = false;
  int playerNumber = 1;
  String playerTask = '';

  bool showMic = false;
  double level=0;
  var rng = new Random();

  List <Widget> toScroll = [];
  double lengthToScroll = 0;

  int backTimerCounter = timerSec;
  String timerTask = '';

  bool isPlayerRemoved = false;
  bool isNewLoop = false, isFirstSpin = true;
  BodyPos currentTask = BodyPos('','');
  bool isSpinning = false, isFinished = false;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isSpinning = false;
          currentIndex = targetIndex % bodyPositions.length;
          printD('currentIndex $currentIndex');
          printD(bodyPositions[3]);
          currentTask = bodyPositions[3];
          playerTask = currentTask.name;
          showMic = true;
          setState(() {});
          _startSpeakAndListen();
        }
      });
    numPlayers = users.length;
    spinTo(3);
  }

  void spinTo(int index) {
    bodyPositions.shuffle();
    int steps = bodyPositions.length + (index - currentIndex); // 12 steps + offset to target
    if (steps < 0) steps += bodyPositions.length; // wrap around
    totalSteps = steps;
    targetIndex = (currentIndex + steps) % bodyPositions.length;

    _controller.reset();
    _animation = Tween<double>(begin: 0, end: steps.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic))
      ..addListener(() => setState(() {}));
    isSpinning = true;
    _controller.forward();
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCard(int index, double offset) {
    double scale = 1.25 - (offset.abs() * 0.5);
    double opacity = (1 - (offset.abs() * 0.5));
    if (opacity < 0 || opacity > 1) {
      return SizedBox();
    }
    double perspective = offset * 0.4;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(offset * 150, 0), // move horizontally
        child: Transform.scale(
          scale: scale,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(perspective),
            alignment: Alignment.center,
            child: Image.asset('images/${bodyPositions[index].img}', width: 250, height: 300,),
          ),
        ),
      ),
    );
  }

  _startSpeakAndListen() async {
    if (isFinished) {
      printD('no _startSpeakAndListen, game finished');
      return;
    }
    printD('startSpeakAndListenMode $currentTask');
    numLoop = 0;
    playerTask = currentTask.name + '!';
    setState(() {});
    printD('playerTask $playerTask');
    if (speech.isListening) {
      await speech.stop();
    }
    flutterTts.stop();
    printD('speak new task $playerTask');
    await Future.delayed(Duration(milliseconds: 300));
    if (users.isNotEmpty) {
      await speak('${users[playerNumber-1]}');
    } else {
      await speak('Игрок № $playerNumber');
    }
    await speak(playerTask);
    setState(() {});
    if (isTimer) {
      backTimerCounter = timerSec;
      timerTask = '$playerTask$playerNumber';
      Future.delayed(Duration(seconds: 1), _updateBackTimer);
    }
    _startListening();
  }

  void _startListening() async {
    printD('startListening');
    isListening = true;
    isFound = false;
    showMic = true;
    setState(() {});
    await Future.delayed(Duration(milliseconds: 200));
    speech.listen(
      onResult: resultListener,
      // listenFor: Duration(seconds: 60),
      // pauseFor: Duration(seconds: 3),
      localeId: 'ru_RU', // en_US uk_UA ru_RU
      // onSoundLevelChange: soundLevelListener,
      // onDevice: true,
      // listenMode: ListenMode.confirmation,
      // sampleRate: 44100,
    );
  }

  void resultListener(SpeechRecognitionResult result) async {
    print ('got resultListener result $result');
    if (isFound && !result.finalResult) {
      return;
    }

    List <String> recognizedWords = result.recognizedWords.toString().toUpperCase().split(' ');
    print ('got recognizedWords $recognizedWords result.finalResult ${result.finalResult}');

    if (!result.finalResult) {
      printD('not final result \n $recognizedWords');
      if (recognizedWords.contains('ПОВТОРИ') || recognizedWords.contains('ПОВТОРИМ') ) {
        printD('found for ПОВТОРИ');
        isListening = false;
        speech.stop();
        isFound = true;
        setState(() {});
        //repeatAndStartListeningAgain();
        return;
      } else if (recognizedWords.indexOf('ПРОИГРАЛ') > -1) {
        printD('found for ПРОИГРАЛ');
        speech.stop();
        isListening = false;
        setState(() {});
        //_playerLeft();
        isFound = true;
        return;
      } else if (recognizedWords.contains('НОВЫЙ') && recognizedWords.contains('ИГРОК')) {
        printD('found for НОВЫЙ ИГРОК');
        speech.stop();
        isListening = false;
        setState(() {});
        //_playerAdd();
        isFound = true;
        return;
      }
      recognizedWords.forEach((cmd) {
        if (cmd == 'OK' || cmd == 'О\'КЕ' || cmd == 'ОКЕЙ' || cmd == 'ДАЛЬШЕ' || cmd == 'СЛЕДУЮЩИЙ') {
          isFound = true;
          printD('found for $cmd');
        }
      });
      if (isFound) {
        speech.stop();
        isListening = false;
        _startNextPlayerLoop();
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
        printD('start new random loop');
        _startNextPlayerLoop();
      } else if (recognizedWords.contains('ПРОИГРАЛ')) {
        printD('ПРОИГРАЛ');
        _playerLeft();
      } else if (recognizedWords.contains('ПОВТОРИ') || recognizedWords.contains('ПОВТОРИМ')) {
        printD('repeat final');
        repeatAndStartListeningAgain();
      } else {
        printD('no keywords. StartListening again.');
        printD(recognizedWords);
        _startListening();
      }
    }
  }

  repeatAndStartListeningAgain() async {
    printD('repeatAndStartListeningAgain');
    printD('stop speech');
    await speech.stop();
    isListening = false;
    setState(() {});
    printD('start speaking');
    await Future.delayed(Duration(milliseconds: 300));
    if (users.isNotEmpty) {
      await speak('${users[playerNumber-1]}');
    } else {
      await speak('Игрок № $playerNumber');
    }
    printD('start speaking2');
    await speak(playerTask);
    printD('ok, starting');
    _startListening();
  }

  @override
  Widget build(BuildContext context) {
    glSetState = setState;
    double progress = _animation.value;
    double fractionalIndex = (currentIndex + progress) % bodyPositions.length;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
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
            SizedBox(height: 12,),
            Text('Задание для игрока', style: TextStyle(fontSize: 24), textAlign: TextAlign.center,),
            SizedBox(height: 8,),
            if (playerNumber>0 && playerNumber<=users.length) Text(users.isEmpty? '№ $playerNumber':'${users[playerNumber-1]}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8,),
            SizedBox(
              width: 400,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: List.generate(bodyPositions.length, (i) {
                  double offset = (i - fractionalIndex);
                  // Wrap around to keep cards close
                  if (offset > bodyPositions.length / 2) offset -= bodyPositions.length;
                  if (offset < -bodyPositions.length / 2) offset += bodyPositions.length;
                  return _buildCard(i, offset);
                }),
              ),
            ),
            SizedBox(height: 8,),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            await speech.stop();
                            await Future.delayed(Duration(milliseconds: 300));
                            _startListening();
                          },
                          child: ActiveMic()  //Icon(Icons.mic, color: Colors.blueAccent, size: 50,)
                      ),
                      if (isTimer && backTimerCounter > 0) Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 30,),
                          ClipOval(
                            child: Container(
                              color: Colors.yellowAccent[200],
                              padding: EdgeInsets.all(15),
                              child: Text('$backTimerCounter', style: TextStyle(
                                fontSize: 24
                              ),)
                            ),
                          ),
                        ],
                      ),
                    ],
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
                    onPressed: _startNextPlayerLoop,
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Проиграл',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white
                        ),
                      ),
                    ),
                    onPressed: _playerLeft,
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('А ну повтори!',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white
                        ),
                      ),
                    ),
                    onPressed: repeatAndStartListeningAgain,
                  ),
                  SizedBox(height: 50),
                ],
              )
                :
              SizedBox(height: 475,)
            ,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.rotate_right),
        onPressed: () {
          // Example: spin to card index 3
          spinTo(3);
          printD('bodyPositions ${bodyPositions[3]}');
        },
      ),
    );
  }

  _playerLeft(){
    if (users.isNotEmpty) {
      users.removeAt(playerNumber-1);
      isPlayerRemoved = true;
    }
    numPlayers = users.length;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Количество игроков $numPlayers',
              style: TextStyle(fontSize: 32),
            )
        )
    );
    if (numPlayers == 1) {
      _showVictoryAndExit();
      return;
    }
    printD('_playerLeft ok playerNumber $playerNumber numPlayers $numPlayers');
    _startNextPlayerLoop();
  }

  _startNextPlayerLoop() async {
    printD('_startNextPlayerLoop');
    if (speech.isListening) {
      await speech.stop();
      showMic = false;
      setState(() {});
    }
    await Future.delayed(Duration(milliseconds: 200));
    playerNumber++;
    printD('s playerNumber $playerNumber ws numPlayers $numPlayers');
    if (playerNumber > numPlayers) {
      playerNumber = 1;
    }
    setState(() {
      showMic = false;
      playerTask = '';
      backTimerCounter = 0;
    });
    numLoop = 0;
    isNewLoop = true;
    spinTo(3);
  }

  _nextByTimer() async {
    if (isSpinning) {
      printD('spinning, wait');
      return;
    }
    printD('Увы. Следующий игрок.');
    speech.stop();
    await flutterTts.stop();
    await Future.delayed(Duration(milliseconds: 300));
    await speak('Следующий игрок');
    await Future.delayed(Duration(milliseconds: 500));
    _startNextPlayerLoop();
  }
  
  _updateBackTimer() async {
    //printD('_updateBackTimer');
    if (isFinished) {
      return;
    }
    if (timerTask != '$playerTask$playerNumber') {
      printD('new task. No _updateBackTimer');
      return;
    }
    backTimerCounter--;
    //printD('_updateBackTimer $backTimerCounter');
    if (mounted) {
      setState(() {});
    }
    if (backTimerCounter > 0) {
      Future.delayed(Duration(seconds: 1), _updateBackTimer);
      return;
    }
    _nextByTimer();
  }

  void _showVictoryAndExit() async {
    speech.stop();
    showMic = false;
    isFinished = true;
    setState(() {});
    await showAlertPage(context, 'Ура! \n ${users.first} победил!');
    users = prefs.getStringList('users') ?? [];
    Navigator.pop(context);
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
