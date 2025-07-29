import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'widgets/bastao_widget.dart';

class BastoesScreen extends StatefulWidget {
  const BastoesScreen({super.key});

  @override
  State<BastoesScreen> createState() => _BastoesScreenState();
}

class _BastoesScreenState extends State<BastoesScreen> {
  final List<double> _alturasCorretas = [60.0, 95.0, 130.0, 165.0];
  final List<Color> _cores = [Colors.teal, Colors.pink, Colors.orange, Colors.purple];

  late List<double> _bastoesEmJogo;
  late ConfettiController _confettiController;
  bool _vitoria = false;

  // ALTERAÇÃO: Nova variável para controlar a ordem do desafio
  late bool _ordemCrescente;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _iniciarRodada();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _iniciarRodada() {
    final random = Random();
    setState(() {
      _bastoesEmJogo = List<double>.from(_alturasCorretas)..shuffle();
      _confettiController.stop();
      _vitoria = false;
      
      // ALTERAÇÃO: Define aleatoriamente o objetivo da rodada
      _ordemCrescente = random.nextBool();
    });
  }

  void _aoTrocarBastao(int indiceArrastado, int indiceAlvo) {
    if (indiceArrastado == indiceAlvo || _vitoria) return;

    setState(() {
      final alturaArrastada = _bastoesEmJogo[indiceArrastado];
      _bastoesEmJogo[indiceArrastado] = _bastoesEmJogo[indiceAlvo];
      _bastoesEmJogo[indiceAlvo] = alturaArrastada;
    });

    _verificarVitoria();
  }

  void _verificarVitoria() {
    // ALTERAÇÃO: Cria a lista de "gabarito" correta baseada no desafio atual
    final List<double> gabarito;
    if (_ordemCrescente) {
      gabarito = _alturasCorretas;
    } else {
      // Cria uma lista invertida para o desafio decrescente
      gabarito = _alturasCorretas.reversed.toList();
    }

    bool vitoriaAlcancada = const ListEquality().equals(_bastoesEmJogo, gabarito);

    if (vitoriaAlcancada && !_vitoria) {
      setState(() => _vitoria = true);
      _confettiController.play();
      Future.delayed(const Duration(milliseconds: 500), _showWinDialog);
    }
  }
  
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Parabéns!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Você ordenou tudo corretamente!', style: TextStyle(color: Colors.white70)),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          TextButton(
            child: const Text('Jogar de Novo', style: TextStyle(color: Colors.tealAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              _iniciarRodada();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... O resto do build() continua igual ...
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildInstruction(), // Este método agora será dinâmico
                const Spacer(),
                _buildAreaDeJogo(),
                const Spacer(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaDeJogo() {
    // ... O buildAreaDeJogo() continua igual ...
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(4, (index) {
              final altura = _bastoesEmJogo[index];
              final cor = _cores[_alturasCorretas.indexOf(altura)];

              return DragTarget<int>(
                builder: (context, candidateData, rejectedData) {
                  return Draggable<int>(
                    data: index,
                    feedback: BastaoWidget(altura: altura, cor: cor),
                    childWhenDragging: Container(width: 50, height: altura),
                    child: BastaoWidget(altura: altura, cor: cor),
                  );
                },
                onWillAccept: (data) => !_vitoria,
                onAccept: (indiceArrastado) => _aoTrocarBastao(indiceArrastado, index),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _vitoria ? Colors.green.shade400 : Colors.grey.shade800,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24)
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Bastões Coloridos', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
          IconButton(onPressed: _vitoria ? null : _iniciarRodada, icon: const Icon(Icons.refresh, color: Colors.white, size: 28)),
        ],
      ),
    );
  }
  
  // ALTERAÇÃO: O texto da instrução agora muda conforme o desafio
  Widget _buildInstruction() {
    final String textoInstrucao = _ordemCrescente 
        ? 'Ordene do MENOR para o MAIOR' 
        : 'Ordene do MAIOR para o MENOR';

    return Text(textoInstrucao, style: const TextStyle(fontSize: 20, color: Colors.white70));
  }
}