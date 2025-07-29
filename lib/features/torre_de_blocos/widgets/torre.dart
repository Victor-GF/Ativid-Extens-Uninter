import 'package:flutter/material.dart';
import 'bloco_torre.dart';
import 'dart:math';

class Torre extends StatefulWidget {
  final int altura;
  final Color cor;
  final VoidCallback onTap;

  const Torre({
    super.key,
    required this.altura,
    required this.cor,
    required this.onTap,
  });

  @override
  State<Torre> createState() => TorreState();
}

class TorreState extends State<Torre> with TickerProviderStateMixin {
  late final AnimationController _acertoController;
  late final AnimationController _erroController;

  @override
  void initState() {
    super.initState();
    _acertoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _erroController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _acertoController.dispose();
    _erroController.dispose();
    super.dispose();
  }

  // Métodos para serem chamados pela tela principal
  void animarAcerto() {
    _acertoController.forward(from: 0);
  }

  void animarErro() {
    _erroController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_acertoController, _erroController]),
        builder: (context, child) {
          double yOffset = 0;
          double xOffset = 0;
          if (_acertoController.isAnimating) {
            yOffset = -15 * sin(_acertoController.value * pi); // Animação de pulo
          }
          if (_erroController.isAnimating) {
            xOffset = 10 * sin(_erroController.value * 2 * pi); // Animação de tremor
          }
          return Transform.translate(
            offset: Offset(xOffset, yOffset),
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: List.generate(
            widget.altura,
            (index) => BlocoDaTorre(color: widget.cor),
          ),
        ),
      ),
    );
  }
}