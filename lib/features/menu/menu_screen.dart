import 'package:atividade_extensionista_uninter/data/models/atividade.dart';
import 'package:flutter/material.dart';

import 'widgets/menu_item_widget.dart';

// Modelo para organizar os dados de cada item do menu
class JogoMenuItem {
  final String titulo;
  final IconData icone;
  final Color cor;
  final Widget tela;

  JogoMenuItem({
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.tela,
  });
}

class MenuPrincipalScreen extends StatelessWidget {
  const MenuPrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const atividades = Atividade.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atividades Lúdicas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: atividades.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final jogo = atividades[index];
          return MenuItemWidget(
            titulo: jogo.label,
            icone: jogo.icon,
            cor: jogo.iconColor,
            onTap: () {
              // Lógica de navegação
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => jogo.screen),
              );
            },
          );
        },
      ),
    );
  }
}