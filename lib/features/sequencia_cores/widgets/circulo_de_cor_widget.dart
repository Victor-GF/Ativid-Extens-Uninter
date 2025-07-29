import 'package:flutter/material.dart';
import 'dart:math';

class CirculoDeCorWidget extends StatefulWidget {
  final Color? cor;
  final Widget? child;
  final Border? borda;

  const CirculoDeCorWidget({
    super.key,
    this.cor,
    this.child,
    this.borda,
  });

  @override
  State<CirculoDeCorWidget> createState() => CirculoDeCorWidgetState();
}

class CirculoDeCorWidgetState extends State<CirculoDeCorWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void playShakeAnimation() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final xOffset = 10 * sin(pi * 4 * _controller.value);
        return Transform.translate(
          offset: Offset(xOffset, 0),
          child: child,
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: widget.cor ?? Colors.grey.shade800,
          shape: BoxShape.circle,
          border: widget.borda,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}