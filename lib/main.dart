import 'package:flutter/services.dart';
import 'package:tw_roller2/About.dart';
import 'GameLoopPage.dart';
import 'package:flutter/material.dart';
import 'globals.dart';

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

  int numPlayers = 3;
  bool speakingMode = false;

  bool showMic = false;
  double level=0;

  @override
  initState() {
    super.initState();
    initTtsAndSttAndFirstSpeech();
  }

  void initTtsAndSttAndFirstSpeech() async {
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
    await speak('Я понимаю такие команды:');
    await speak('Окей -- следующий игрок');
    await speak('Проиграл -- игрок выбывает');
    await speak('Новый игрок -- игрок добавляется');
    await speak('"А ну повтори!" -- повторить задание');
    await Future.delayed(Duration(milliseconds: 1200));
    await speak('Для начала нажми "Старт"!');
    speakingMode = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, textScaleFactor: 1.4, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: TextButton(
          onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => About())
            );
          },
          child: Text('?', style: TextStyle(
            color: Colors.white,
            fontSize: 32,
          ),),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(6),
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 18,
              color: Colors.black
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(10.0),
              children: <Widget>[
                buildSmileIcon(),
                Text(
                  '\nПривет!',
                  textScaleFactor: 1.3, textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                    'Я понимаю такие команды:',
                    textScaleFactor: 1.3, textAlign: TextAlign.center
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('"Новый игрок"', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                    ),),
                    Text(' - плюс игрок,', style: TextStyle(
                        fontSize: 18
                    ),),
                  ],
                ),
                SizedBox(height: 12,),
                Wrap(
                  alignment: WrapAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
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
                    textScaleFactor: 1.3, textAlign: TextAlign.center
                ),
                SizedBox(height: 20),
                Text('Игроков:',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
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
                        child: Icon(Icons.exposure_minus_1),
                        heroTag: 'decrease',
                      ),
                    ),
                    SizedBox(width: 15,),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('$numPlayers', textScaleFactor: 2.2,),
                    ),
                    SizedBox(width: 15,),
                    Container(
                      margin: EdgeInsets.all(10),
                      width: 40, height: 40,
                      child: FloatingActionButton(
                        onPressed: (){
                          setState(() {
                            numPlayers++;
                          });
                        },
                        child: Icon(Icons.exposure_plus_1),
                        heroTag: 'increase',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                  onPressed: (){
                    print('start with $numPlayers');
                    goToStartGamePage();
                  },
                  child: Text('Старт!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        //fontWeight: FontWeight.bold
                      )
                  ),
                ),
                SizedBox(height: 10,),
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

  goToStartGamePage() {
    print('start game for $numPlayers');
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => GameLoopPage(numPlayers))
    ).then((result) async {
      print('cb from push');
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
