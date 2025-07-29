import 'package:flutter/material.dart';
import 'dart:math';

// A classe modelo continua a mesma
class RodadaSequencia {
  final List<Color?> sequencia;
  final Color corCorreta;
  final List<Color> opcoes;

  RodadaSequencia({
    required this.sequencia,
    required this.corCorreta,
    required this.opcoes,
  });
}

class GeradorDeSequencia {
  final _random = Random();

  // ALTERAÇÃO: O método agora gera uma sequência de 6 itens
  RodadaSequencia gerarNovaRodada({required List<Color> coresDisponiveis}) {
    // 1. PREPARAÇÃO
    coresDisponiveis.shuffle();
    // Agora pegamos 3 cores para padrões mais complexos
    final colorA = coresDisponiveis[0];
    final colorB = coresDisponiveis[1];
    final colorC = coresDisponiveis[2];

    // 2. CRIAÇÃO DO PADRÃO LÓGICO (para 6 itens)
    final tipoDePadrao = _random.nextInt(2); // Sorteia entre 2 tipos de padrão
    late final List<Color> sequenciaCompleta;

    switch (tipoDePadrao) {
      case 0: // Padrão ABCABC
        sequenciaCompleta = [colorA, colorB, colorC, colorA, colorB, colorC];
        break;
      default: // Padrão AABBCC
        sequenciaCompleta = [colorA, colorA, colorB, colorB, colorC, colorC];
        break;
    }

    // 3. DEFINIÇÃO DO DESAFIO
    final indiceFaltando = _random.nextInt(6); // Sorteia um índice de 0 a 5
    final corCorreta = sequenciaCompleta[indiceFaltando];

    // 4. GERAÇÃO DAS OPÇÕES (continua com 3 opções)
    final List<Color> opcoes = [corCorreta];
    while (opcoes.length < 3) {
      final corAleatoria = coresDisponiveis[_random.nextInt(coresDisponiveis.length)];
      if (!opcoes.contains(corAleatoria)) {
        opcoes.add(corAleatoria);
      }
    }
    opcoes.shuffle();

    // 5. CRIAÇÃO DA SEQUÊNCIA VISUAL
    final List<Color?> sequenciaVisual = List.from(sequenciaCompleta);
    sequenciaVisual[indiceFaltando] = null;
    
    return RodadaSequencia(
      sequencia: sequenciaVisual,
      corCorreta: corCorreta,
      opcoes: opcoes,
    );
  }
}