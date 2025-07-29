import 'dart:math';
import 'dart:ui'; // Precisamos deste para o efeito de blur
import 'package:flutter/material.dart';

class Cartao extends StatefulWidget {
  final int number;
  final bool isFlipped;
  final bool isMatched;
  final VoidCallback onTap;

  const Cartao({
    super.key,
    required this.number,
    required this.isFlipped,
    required this.isMatched,
    required this.onTap,
  });

  @override
  State<Cartao> createState() => _CartaoState();
}

class _CartaoState extends State<Cartao> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.isFlipped) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant Cartao oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isMatched ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final isFront = _controller.value >= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _buildCardFace(),
                )
              : _buildCardBack(),
          );
        },
      ),
    );
  }

  // A frente da carta: cor vibrante e número
  Widget _buildCardFace() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo.shade400,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isMatched ? Colors.green.shade400 : Colors.white24,
          width: widget.isMatched ? 4 : 2,
        ),
      ),
      child: Center(
        child: Text(
          widget.number.toString(),
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // O verso da carta: Efeito de vidro fosco (Glassmorphism)
  Widget _buildCardBack() {
    return ClipRRect( // ClipRRect é essencial para o efeito de blur funcionar nos cantos
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Center(
            child: Icon(
              Icons.auto_awesome, // Ícone de "brilho", mais abstrato
              size: 50,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}