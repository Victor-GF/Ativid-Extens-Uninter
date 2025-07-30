import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Color cor;
  final VoidCallback onTap;

  const MenuItemWidget({
    super.key,
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.grey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icone, size: 40, color: cor),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}