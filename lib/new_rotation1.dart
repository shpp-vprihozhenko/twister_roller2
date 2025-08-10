import 'dart:math';
import 'package:flutter/material.dart';

import 'globals.dart';


class DrumCarousel extends StatefulWidget {
  const DrumCarousel({Key? key}) : super(key: key);

  @override
  State<DrumCarousel> createState() => _DrumCarouselState();
}

class _DrumCarouselState extends State<DrumCarousel>
    with SingleTickerProviderStateMixin {


  late AnimationController _controller;
  late Animation<double> _animation;
  int currentIndex = 0;
  int targetIndex = 0;
  int totalSteps = 0;

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
          currentIndex = targetIndex % bodyPositions.length;
        }
      });
    bodyPositions.shuffle();
    spinTo(3);
  }

  void spinTo(int index) {
    int steps = bodyPositions.length + (index - currentIndex); // 12 steps + offset to target
    if (steps < 0) steps += bodyPositions.length; // wrap around
    totalSteps = steps;
    targetIndex = (currentIndex + steps) % bodyPositions.length;

    _controller.reset();
    _animation = Tween<double>(begin: 0, end: steps.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic))
      ..addListener(() => setState(() {}));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCard(int index, double offset) {
    double scale = 1 - (offset.abs() * 0.3);
    double opacity = (1 - (offset.abs() * 0.5)).clamp(0.0, 1.0);
    double perspective = offset * 0.4;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(offset * 120, 0), // move horizontally
        child: Transform.scale(
          scale: scale,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(perspective),
            alignment: Alignment.center,
            child: Image.asset('images/${bodyPositions[index].img}', width: 200, height: 250,),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = _animation.value;
    double fractionalIndex = (currentIndex + progress) % bodyPositions.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
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
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.rotate_right),
        onPressed: () {
          // Example: spin to card index 3
          bodyPositions.shuffle();
          spinTo(3);
          printD('bodyPositions ${bodyPositions[3]}');
        },
      ),
    );
  }
}
