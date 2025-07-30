import 'package:atividade_extensionista_uninter/features/bastoes/bastoes_screen.dart';
import 'package:atividade_extensionista_uninter/features/guardiao_das_formas/guardiao_das_formas_screen.dart';
import 'package:atividade_extensionista_uninter/features/jogo_da_memoria/jogo_da_memoria.dart';
import 'package:atividade_extensionista_uninter/features/sequencia_cores/sequencia_cores_screen.dart';
import 'package:atividade_extensionista_uninter/features/torre_de_blocos/torre_de_blocos.dart';
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
    // Lista com todos os nossos jogos
    final List<JogoMenuItem> jogos = [
      JogoMenuItem(
        titulo: 'Jogo da Memória',
        icone: Icons.memory,
        cor: Colors.blue.shade400,
        tela: const JogoDaMemoriaScreen(),
      ),
      JogoMenuItem(
        titulo: 'Torre de Blocos',
        icone: Icons.view_column_rounded,
        cor: Colors.orange.shade400,
        tela: const TorreDeBlocosScreen(),
      ),
      JogoMenuItem(
        titulo: 'Bastões Coloridos',
        icone: Icons.sort_by_alpha_rounded,
        cor: Colors.purple.shade400,
        tela: const BastoesScreen(),
      ),
      JogoMenuItem(
        titulo: 'Guardião das Formas',
        icone: Icons.category_rounded,
        cor: Colors.red.shade400,
        tela: const GuardiaoDasFormasScreen(),
      ),
      JogoMenuItem(
        titulo: 'Sequência das Cores',
        icone: Icons.palette_rounded,
        cor: Colors.teal.shade400,
        tela: const SequenciaCoresScreen(),
      ),
    ];

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
        itemCount: jogos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final jogo = jogos[index];
          return MenuItemWidget(
            titulo: jogo.titulo,
            icone: jogo.icone,
            cor: jogo.cor,
            onTap: () {
              // Lógica de navegação
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => jogo.tela),
              );
            },
          );
        },
      ),
    );
  }
}