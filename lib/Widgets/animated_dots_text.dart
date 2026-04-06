import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedDotsText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const AnimatedDotsText({super.key, required this.text, this.style});

  @override
  State<AnimatedDotsText> createState() => _AnimatedDotsTextState();
}

class _AnimatedDotsTextState extends State<AnimatedDotsText> {
  int _dotCount = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.text, style: widget.style),
        SizedBox(
          width: 18,
          child: Text(dots, style: widget.style),
        ),
      ],
    );
  }
}
