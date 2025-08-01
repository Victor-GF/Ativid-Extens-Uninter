import 'package:atividade_extensionista_uninter/features/bastoes/bastoes_screen.dart';
import 'package:atividade_extensionista_uninter/features/guardiao_das_formas/guardiao_das_formas_screen.dart';
import 'package:atividade_extensionista_uninter/features/jogo_da_memoria/jogo_da_memoria.dart';
import 'package:atividade_extensionista_uninter/features/sequencia_cores/sequencia_cores_screen.dart';
import 'package:atividade_extensionista_uninter/features/torre_de_blocos/torre_de_blocos.dart';
import 'package:flutter/material.dart';

enum Atividade {
  jogoDaMemoria(
    id: 'jogo_da_memoria',
    label: 'Jogo da Memória',
    icon: Icons.memory,
    iconColor: Color(0xFF42A5F5), 
    screen: JogoDaMemoriaScreen(),
  ),
  torreDeBlocos(
    id: 'torre_de_blocos',
    label: 'Torre de Blocos',
    icon: Icons.view_column_rounded,
    iconColor: Color(0xFFFFA726), 
    screen: TorreDeBlocosScreen(),
  ),
  bastoesColoridos(
    id: 'bastoes_coloridos',
    label: 'Bastões Coloridos',
    icon: Icons.sort_by_alpha_rounded,
    iconColor: Color(0xFFAB47BC),
    screen: BastoesScreen(),
  ),
  guardiaoDasFormas(
    id: 'guardiao_das_formas',
    label: 'Guardião das Formas',
    icon: Icons.category_rounded,
    iconColor: Color(0xFFEF5350), 
    screen: GuardiaoDasFormasScreen(),
  ),
  sequenciaDasCores(
    id: 'sequencia_das_cores',
    label: 'Sequência das Cores',
    icon: Icons.palette_rounded,
    iconColor: Color(0xFF26A69A), 
    screen: SequenciaCoresScreen(),
  );

  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  final StatefulWidget screen;

  const Atividade({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.screen,
  });
}