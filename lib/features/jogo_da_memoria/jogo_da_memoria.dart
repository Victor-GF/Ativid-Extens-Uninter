import 'dart:async';
import 'package:atividade_extensionista_uninter/data/models/atividade.dart';
import 'package:atividade_extensionista_uninter/data/repositories/estatisticas_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'widgets/cartao.dart';

class JogoDaMemoriaScreen extends StatefulWidget {
  const JogoDaMemoriaScreen({super.key});

  @override
  State<JogoDaMemoriaScreen> createState() => _JogoDaMemoriaScreenState();
}

class _JogoDaMemoriaScreenState extends State<JogoDaMemoriaScreen> {
  final int _gridSize = 12;
  final int _gridAxisCount = 3;

  late List<int> _cardNumbers;
  late List<bool> _cardFlipped;
  List<int> _flippedIndexes = [];
  List<int> _matchedPairs = [];
  bool _isChecking = false;
  
  late ConfettiController _confettiController;

  // Relógio para o tempo
  final _stopwatch = Stopwatch();
  int _contadorDeErros = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _startNewGame();
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  void _startNewGame() {
    _confettiController.stop();
    List<int> numbers = List.generate(_gridSize ~/ 2, (i) => i + 1) + List.generate(_gridSize ~/ 2, (i) => i + 1);
    numbers.shuffle();

    _contadorDeErros = 0;
    _stopwatch.reset();
    _stopwatch.start();

    setState(() {
      _cardNumbers = numbers;
      _cardFlipped = List<bool>.filled(_gridSize, false);
      _flippedIndexes = [];
      _matchedPairs = [];
      _isChecking = false;
    });
  }

  void _onCardTap(int index) {
    if (_isChecking || _cardFlipped[index]) return;

    setState(() {
      _cardFlipped[index] = true;
      _flippedIndexes.add(index);
      if (_flippedIndexes.length == 2) {
        _isChecking = true;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    int firstIndex = _flippedIndexes[0];
    int secondIndex = _flippedIndexes[1];

    if (_cardNumbers[firstIndex] == _cardNumbers[secondIndex]) {
      setState(() => _matchedPairs.addAll([firstIndex, secondIndex]));
      _flippedIndexes = [];
      _isChecking = false;
      if (_matchedPairs.length == _gridSize) {
        _venceuJogo();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _cardFlipped[firstIndex] = false;
          _cardFlipped[secondIndex] = false;
          _flippedIndexes = [];
          _isChecking = false;
        });
      });
    }
  }

  Future<void> _venceuJogo() async {
    _stopwatch.stop();

    final tempoFinal = _stopwatch.elapsedMilliseconds / 1_000;

    await EstatisticasRepository.instance.registrarNovoTempoAtividade(
      atividade: Atividade.jogoDaMemoria, 
      tempo: tempoFinal
    );

    _confettiController.play();
    _showWinDialog();
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF1F2937),
          title: Text('Mandou Bem!', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('Você encontrou todos os pares!', style: GoogleFonts.nunito(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: Text('Jogar de Novo', style: GoogleFonts.nunito(color: Colors.tealAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF0D1117)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      itemCount: _gridSize,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _gridAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemBuilder: (context, index) {
                        // O número do card determina sua cor! (ex: todos os "1" são teal)
                        int number = _cardNumbers[index];
                        return Cartao(
                          number: number,
                          isFlipped: _cardFlipped[index],
                          isMatched: _matchedPairs.contains(index),
                          onTap: () => _onCardTap(index),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Jogo da Memória',
            style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: _startNewGame,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}