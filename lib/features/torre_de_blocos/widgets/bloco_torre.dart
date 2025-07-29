import 'package:flutter/material.dart';

class BlocoDaTorre extends StatelessWidget {
  final Color color;
  const BlocoDaTorre({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 30,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black.withOpacity(0.2), width: 2),
      ),
    );
  }
}