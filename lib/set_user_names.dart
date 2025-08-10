import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'GameLoopPage.dart';
import 'globals.dart';

class SetUserNames extends StatefulWidget {
  const SetUserNames({super.key});

  @override
  State<SetUserNames> createState() => _SetUserNamesState();
}

class _SetUserNamesState extends State<SetUserNames> {
  bool showMic = false;
  int curUserIndex = -1;
  TextEditingController tecName = TextEditingController();
  bool isFound = false;

  @override
  void initState() {
    printD('$numPlayers');
    super.initState();
    if (users.isEmpty) {
      for (int i=0; i<numPlayers; i++) {
        users.add('Игрок номер ${i+1}');
      }
    }
  }

  @override
  void dispose() {
    tecName.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    glSetState = setState;
    return Scaffold(
      appBar: AppBar(title: Text('Укажите имена игроков'),),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Text('Для этого нажмите на нужную строку и чётко скажите имя',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20,),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) => ListTile(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: (){
                      _edit(index);
                    }, icon: Icon(Icons.edit)),
                    IconButton(onPressed: (){
                      users.removeAt(index);
                      numPlayers = users.length;
                      _saveUsers();
                      setState(() {});
                    }, icon: Icon(Icons.remove_circle, color: Colors.red,)),
                  ],
                ),
                leading: Text('${index+1})'),
                tileColor: index%2==0? Colors.grey[200]:Colors.white,
                title: Text(users[index]),
                onTap: (){
                  _changeUserName(index);
                },
              )
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.blueAccent[200]),
            onPressed: _add, icon: Icon(Icons.add, size: 32,)),
          SizedBox(height: 30,),
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.greenAccent[200]),
            onPressed: _done, icon: Icon(Icons.done, size: 32,)),
        ],
      ),
    );
  }

  void _changeUserName(int index) async {
    printD('_changeUserName $index');
    curUserIndex = index;
    await Future.delayed(Duration(milliseconds: 300));
    showMic = true; setState(() {});
    isFound = false;
    speech.listen(
      onResult: resultListener,
      localeId: 'ru_RU', // en_US uk_UA ru_RU
    );
  }

  void resultListener(SpeechRecognitionResult result) async {
    print ('got resultListener result $result');

    if (isFound) {
      return;
    }

    List <String> recognizedWords = result.recognizedWords.toString().toUpperCase().split(' ');
    print ('got recognizedWords $recognizedWords result.finalResult ${result.finalResult}');

    users[curUserIndex] = recognizedWords[0];

    if (users[curUserIndex].length >= 3) {
      speech.stop();
      isFound = true;
    }

    _saveUsers();

    showMic = false;
    setState(() {});
  }


  void _edit(index) async {
    tecName.text = users[index];
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  controller: tecName,
                ),
                SizedBox(height: 30,),
                ElevatedButton(onPressed: (){
                  Navigator.pop(context, 'ok');
                }, child: Text('OK'))
              ],
            ),
          );
        }
    );
    if (result == null) {
      return;
    }
    users[index] = tecName.text.trim();
    _saveUsers();
    setState(() {});
  }

  void _add() async {
    tecName.text = '';
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  controller: tecName,
                ),
                SizedBox(height: 30,),
                ElevatedButton(onPressed: (){
                  Navigator.pop(context, 'ok');
                }, child: Text('OK'))
              ],
            ),
          );
        }
    );
    if (result == null) {
      return;
    }
    users.add(tecName.text.trim());
    _saveUsers();
    setState(() {});
    numPlayers = users.length;
  }

  void _saveUsers() async {
    prefs.setStringList('users', users);
  }

  void _done() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => GameLoopPage())
    );
  }
}
