import 'package:flutter/material.dart';

class BastaoWidget extends StatelessWidget {
  final double altura;
  final Color cor;

  const BastaoWidget({
    super.key,
    required this.altura,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: altura,
      width: 50,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.3), width: 2),
      ),
    );
  }
}