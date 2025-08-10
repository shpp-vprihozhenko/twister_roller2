import 'package:flutter/material.dart';
import 'dart:math';

import 'globals.dart';


class CardDrum extends StatefulWidget {
  const CardDrum({super.key});

  @override
  _CardDrumState createState() => _CardDrumState();
}

class _CardDrumState extends State<CardDrum>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final int cardCount = 8;
  double cardWidth = 150;
  double radius = 180;
  double rotation = 0; // current rotation

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _animation = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ))
      ..addListener(() {
        setState(() {
          rotation = _animation.value;
        });
      });
  }

  void _rotateDrum() {
    double oldRotation = rotation;
    double turns = Random().nextInt(fullImgList.length) + 3; // 3 to 8 half-turns
    double targetRotation =
        oldRotation + turns * (pi / 3); // pi/4 = 45° per card

    _animation = Tween<double>(begin: oldRotation, end: targetRotation)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          rotation = _animation.value;
        });
      });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: SizedBox(
          height: 300,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(fullImgList.length, (index) {
              final angle = (2 * pi / fullImgList.length) * index + rotation;
              final x = cos(angle) * radius;
              final y = sin(angle) * 20; // small vertical wobble
              final scale = 1 + (y.abs() / 100);

              return Transform.translate(
                offset: Offset(x, 0),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: scale.clamp(0.3, 1.0),
                    child: Container(
                      width: cardWidth,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.primaries[index % Colors.primaries.length],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset('images/${fullImgList[index]}', width: 200, height: 250,),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _rotateDrum,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
