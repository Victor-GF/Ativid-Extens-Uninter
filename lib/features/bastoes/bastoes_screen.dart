import 'package:atividade_extensionista_uninter/data/models/atividade.dart';
import 'package:atividade_extensionista_uninter/data/repositories/estatisticas_repository.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
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

  late bool _ordemCrescente;

  // Para cronometrar o tempo
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _iniciarRodada();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  void _iniciarRodada() {
    final random = Random();

    _stopwatch.reset();
    _stopwatch.start();

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
      
      Future.delayed(const Duration(milliseconds: 400), _venceuJogo);
    }
  }

  Future<void> _venceuJogo() async {
    _stopwatch.stop();

    final tempoFinal = _stopwatch.elapsedMilliseconds / 1000;

    // Salva o tempo no repositório
    final recorde = await EstatisticasRepository.instance.registrarNovoTempoAtividade(
      atividade: Atividade.bastoesColoridos, 
      tempo: tempoFinal,
    );
    
    _showWinDialog(recorde);
  }

   void _showWinDialog(bool recorde) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF1F2937),

          // Título dinâmico: muda se for um novo recorde
          title: Text(
            recorde ? 'NOVO RECORDE!' : 'Mandou Bem!',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Faz a coluna se ajustar ao conteúdo
            children: [
              // Ícone de troféu aparece apenas se for um novo recorde
              if (recorde)
                const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
              if (recorde) const SizedBox(height: 16),

              // Conteúdo de texto dinâmico
              Text(
                recorde
                    ? 'Você superou seu melhor tempo!'
                    : 'Você encontrou todos os pares!',
                style: GoogleFonts.nunito(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text(
                'Jogar de Novo',
                style: GoogleFonts.nunito(
                  color: Colors.tealAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _iniciarRodada();
              },
            ),
          ],
        );
      },
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