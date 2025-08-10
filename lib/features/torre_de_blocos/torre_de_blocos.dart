import 'package:atividade_extensionista_uninter/data/models/atividade.dart';
import 'package:atividade_extensionista_uninter/data/repositories/estatisticas_repository.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/torre.dart';

class TorreDeBlocosScreen extends StatefulWidget {
  const TorreDeBlocosScreen({super.key});

  @override
  State<TorreDeBlocosScreen> createState() => _TorreDeBlocosScreenState();
}

class _TorreDeBlocosScreenState extends State<TorreDeBlocosScreen> {
  late List<int> _alturasDasTorres;
  late bool _desafioMaiorTorre;
  int? _indiceCorreto;
  bool _bloquearToques = false;

  final _chavesDasTorres = [
    GlobalKey<TorreState>(),
    GlobalKey<TorreState>(),
    GlobalKey<TorreState>(),
    GlobalKey<TorreState>()
  ];

  final _cores = [Colors.teal, Colors.pink, Colors.orange, Colors.purple];
  
  // Para os controles do usuário
  late ConfettiController _confettiController;

  // Para cronometrar o tempo
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _iniciarNovaRodada();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  void _iniciarNovaRodada() {
    _confettiController.stop(); // Garante que os confetes parem
    final random = Random();
    
    final Set<int> alturas = {};
    while (alturas.length < 4) {
      alturas.add(random.nextInt(7) + 2);
    }

    _alturasDasTorres = alturas.toList();
    _alturasDasTorres.shuffle();
    _cores.shuffle();

    _desafioMaiorTorre = random.nextBool();
    
    int resposta = _desafioMaiorTorre ? _alturasDasTorres.reduce(max) : _alturasDasTorres.reduce(min);
    _indiceCorreto = _alturasDasTorres.indexOf(resposta);

    _stopwatch.reset();
    _stopwatch.start();

    setState(() {
      _bloquearToques = false; // Garante que os toques sejam liberados
    });
  }

  void _onTorreTap(int indiceTocado) {
    if (_bloquearToques) return;

    setState(() => _bloquearToques = true);

    if (indiceTocado == _indiceCorreto) {
      _chavesDasTorres[indiceTocado].currentState?.animarAcerto();
      _confettiController.play();
      Future.delayed(const Duration(milliseconds: 400), () {
        _venceuJogo(indiceTocado);
      });
    } else {
      _chavesDasTorres[indiceTocado].currentState?.animarErro();
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => _bloquearToques = false);
      });
    }
  }

  Future<void> _venceuJogo(int indiceTocado) async {
    _stopwatch.stop();
    final tempoFinal = _stopwatch.elapsedMilliseconds / 1000;

    // Salva o tempo no repositório
    final recorde = await EstatisticasRepository.instance.registrarNovoTempoAtividade(
      atividade: Atividade.torreDeBlocos, 
      tempo: tempoFinal,
    );
    
    // Continua com a animação e o dialog
    _chavesDasTorres[indiceTocado].currentState?.animarAcerto();
    _confettiController.play();
    Future.delayed(const Duration(milliseconds: 400), () {
      _showWinDialog(recorde);
    });
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
                _iniciarNovaRodada();
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
      // ALTERAÇÃO: Envolver o corpo em um Stack para os confetes
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildInstruction(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      // ALTERAÇÃO: Gerar 4 torres
                      children: List.generate(4, (index) {
                        return Torre(
                          key: _chavesDasTorres[index],
                          altura: _alturasDasTorres[index],
                          cor: _cores[index],
                          onTap: () => _onTorreTap(index),
                        );
                      }),
                    ),
                  ),
                ),
                Container(
                  height: 20,
                  color: Colors.white.withOpacity(0.1),
                )
              ],
            ),
          ),
          // ALTERAÇÃO: Adicionar o widget de confetes
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.yellow],
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
            'Torre de Blocos',
            style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: _bloquearToques ? null : _iniciarNovaRodada, // Desabilita o botão durante a animação
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Selecione a ',
            style: TextStyle(fontSize: 22, color: Colors.white70),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _desafioMaiorTorre ? 'MAIOR' : 'MENOR',
              style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const Text(
            ' torre',
            style: TextStyle(fontSize: 22, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}