import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tw_roller2/About.dart';
import 'GameLoopPage.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
import 'new_rotation.dart';
import 'new_rotation1.dart';
import 'set_user_names.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp()));
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Твистер-роллер',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Твистер-роллер'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool speakingMode = false;
  bool showMic = false;
  double level=0;
  bool isStarted = false;

  @override
  initState() {
    super.initState();
    initTtsAndSttAndFirstSpeech();
    glFillBodyPositions();
    _getSharedPrefs();
  }

  void initTtsAndSttAndFirstSpeech() async {
    initSTT();
    await initTts();
    await firstSpeech();
  }

  bool isNumeric(String s) {
    return int.tryParse(s) != null;
  }

  firstSpeech() async {
    speakingMode = true;
    setState(() {});
    await speak('Привет! Я - интерактивный помощник для игры в Твистер.');
    if (isStarted) { return; }
    await speak('Я понимаю такие команды:');
    if (isStarted) { return; }
    await speak('Окей -- следующий игрок');
    if (isStarted) { return; }
    await speak('Проиграл -- игрок выбывает');
    if (isStarted) { return; }
    await speak('"А ну повтори!" -- повторить задание');
    if (isStarted) { return; }
    await Future.delayed(Duration(milliseconds: 1000));
    await speak('Для начала нажми "Старт"!');
    if (isStarted) { return; }
    speakingMode = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Text(widget.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        leading: IconButton(
          onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => About())
            );
          },
          icon: Icon(Icons.help, size: 36,),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(6),
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 16,
              color: Colors.black
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(10.0),
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    if (kDebugMode) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => DrumCarousel())
                      );
                    }
                  },
                  child: buildSmileIcon()
                ),
                Text(
                  '\nПривет!',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                    'Я понимаю такие команды:',
                    textAlign: TextAlign.center
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('"Окей!"', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                    ),),
                    Text(' - следующий игрок,', style: TextStyle(
                        fontSize: 18
                    ),),
                  ],
                ),
                SizedBox(height: 12,),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('"Проиграл"', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                    ),),
                    Text(' - игрок выбывает,', style: TextStyle(
                        fontSize: 18
                    ),),
                  ],
                ),
                SizedBox(height: 12,),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('"А ну повтори!"', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24
                    ),),
                    Text(' - повторить задание', style: TextStyle(
                        fontSize: 18
                    ),),
                  ],
                ),
                SizedBox(height: 18),
                Text(
                    'Для начала игры задай количество игроков и нажми "Старт"!',
                    textAlign: TextAlign.center
                ),
                SizedBox(height: 12),
                Text('Игроков:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      width: 40, height: 40,
                      child: FloatingActionButton(
                        onPressed: (){
                          setState(() {
                            numPlayers--;
                          });
                        },
                        tooltip: 'уменьшить',
                        child: Icon(Icons.remove),
                        heroTag: 'decrease',
                      ),
                    ),
                    SizedBox(width: 15,),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('$numPlayers', style: TextStyle(fontSize: 32),),
                    ),
                    SizedBox(width: 15,),
                    Container(
                      margin: EdgeInsets.all(10),
                      width: 40, height: 40,
                      child: FloatingActionButton(
                        onPressed: (){
                          setState(() {
                            numPlayers++;
                            if (users.isNotEmpty && numPlayers > users.length) {
                              users.add('Игрок номер $numPlayers');
                            }
                          });
                        },
                        child: Icon(Icons.add),
                        heroTag: 'increase',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                  onPressed: (){
                    printD('start with $numPlayers');
                    isStarted = true;
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SetUserNames())
                    );
                  },
                  child: Text('Старт',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        //fontWeight: FontWeight.bold
                      )
                  ),
                ),
                SizedBox(height: 30),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[100]),
                //   onPressed: _setUserNames,
                //   child: Text('указать имена игроков', textAlign: TextAlign.center,
                //       style: TextStyle(
                //         color: Colors.pink,
                //         fontSize: 24,
                //         //fontWeight: FontWeight.bold
                //       )
                //   ),
                // ),
                // SizedBox(height: 20,),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Таймер: '),
                    Switch(value: isTimer, onChanged: (newVal){
                      isTimer = !isTimer;
                      prefs.setBool('isTimer', isTimer);
                      setState(() {});
                    }),
                    if (isTimer) Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: (){
                            timerSec-=5;
                            if (timerSec<=5) {
                              timerSec = 5;
                            }
                            prefs.setInt('timerSec', timerSec);
                            setState(() {});
                          }, icon: Icon(Icons.remove),
                          style: IconButton.styleFrom(backgroundColor: Colors.greenAccent[100]),
                        ),
                        Text('$timerSec сек.', style: TextStyle(fontSize: 24),),
                        IconButton(
                          onPressed: (){
                            timerSec+=5;
                            prefs.setInt('timerSec', timerSec);
                            setState(() {});
                          },
                          icon: Icon(Icons.add),
                          style: IconButton.styleFrom(backgroundColor: Colors.greenAccent[200]),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 40,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSmileIcon() {
    return speakingMode? Image.asset('images/speakingSmile2.gif', width: 80, height: 80,)
        : Image.asset('images/notSpeakingSmile.jpg', width: 80, height: 80,);
  }

  goToStartGamePage() {
    flutterTts.stop();
    printD('start game for $numPlayers');
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => GameLoopPage())
    ).then((result) async {
      printD('cb from push');
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _setUserNames() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SetUserNames())
    );
    setState(() {});
  }

  void _getSharedPrefs() async {
    await initSharedPrefs();
    users = prefs.getStringList('users') ?? [];
    printD('got users $users');
    isTimer = prefs.getBool('isTimer') ?? false;
    timerSec = prefs.getInt('timerSec') ?? timerSec;
    if (users.isNotEmpty) {
      numPlayers = users.length;
    }
    setState(() {});
  }
}
