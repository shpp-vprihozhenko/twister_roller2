import 'dart:math';
import 'package:flutter/material.dart';

import 'globals.dart';

class RouletteDemo extends StatefulWidget {
  const RouletteDemo({super.key});

  @override
  State<RouletteDemo> createState() => _RouletteDemoState();
}

class _RouletteDemoState extends State<RouletteDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _angle = 0; // current rotation
  double _speed = 0; // rotation speed (radians/frame)
  List <Widget> cards = [];
  double picWidth = 100, picHeight = 130;
  @override
  void initState() {
    fullImgList.forEach((img){
      cards.add(Image.asset('images/$img', width: picWidth, height: picHeight,));
    });
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(days: 1))
      ..addListener(_tick)
      ..repeat();
  }

  void _tick() {
    setState(() {
      _angle += _speed;
      if (_speed > 0) {
        _speed *= 0.99; // friction
        if (_speed < 0.001) _speed = 0; // stop
      }
    });
  }

  void spinRoulette() {
    setState(() {
      _speed = 0.3; // initial speed (higher = faster spin)
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final cards = List.generate(
    //     8,
    //         (i) => Card(
    //       color: Colors.primaries[i % Colors.primaries.length],
    //       child: SizedBox(
    //         width: 80,
    //         height: 120,
    //         child: Center(
    //             child: Text(
    //               "Card $i",
    //               style: const TextStyle(color: Colors.white),
    //             )),
    //       ),
    //     )
    // );

    return Scaffold(
      appBar: AppBar(title: const Text("Roulette Cards")),
      body: Center(
        child: Transform.rotate(
          angle: _angle,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(cards.length, (index) {
              final angle = (2 * pi / cards.length) * index;
              return Transform.translate(
                offset: Offset(250 * cos(angle), 250 * sin(angle)),
                child: cards[index],
              );
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: spinRoulette,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
