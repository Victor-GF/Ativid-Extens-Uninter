import 'package:atividade_extensionista_uninter/data/models/atividade.dart';
import 'package:atividade_extensionista_uninter/data/repositories/estatisticas_repository.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/forma_geometrica_widget.dart';

class Forma {
  final int id;
  final TipoForma tipo;
  final Color cor;
  Forma({required this.id, required this.tipo, required this.cor});
}

class GuardiaoDasFormasScreen extends StatefulWidget {
  const GuardiaoDasFormasScreen({super.key});

  @override
  State<GuardiaoDasFormasScreen> createState() => _GuardiaoDasFormasScreenState();
}

// CORREÇÃO 1: Adicionar "with TickerProviderStateMixin" para as animações funcionarem
class _GuardiaoDasFormasScreenState extends State<GuardiaoDasFormasScreen> with TickerProviderStateMixin {
  late List<Forma> _formasParaArrastar;
  late Map<TipoForma, List<Forma>> _formasNasCaixas;
  late ConfettiController _confettiController;
  
  late Map<TipoForma, AnimationController> _animationControllers;
  
  final List<TipoForma> _tiposAlvo = [TipoForma.quadrado, TipoForma.circulo, TipoForma.triangulo];
  final List<Color> _cores = [Colors.blue.shade400, Colors.red.shade400, Colors.green.shade400, Colors.yellow.shade400, Colors.purple.shade400];
  final int _totalPorForma = 3;

  // Para cronometrar o tempo
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    _animationControllers = {
      for (var tipo in _tiposAlvo)
        tipo: AnimationController(
          vsync: this, // Agora 'this' é um TickerProvider válido
          duration: const Duration(milliseconds: 150),
          reverseDuration: const Duration(milliseconds: 150),
        ),
    };

    _iniciarRodada();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _stopwatch.stop();
    _animationControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _iniciarRodada() {
    _stopwatch.reset();
    _stopwatch.start();

    setState(() {
      _formasParaArrastar = [];
      int idCounter = 0;
      for (var tipo in _tiposAlvo) {
        for (int i = 0; i < _totalPorForma; i++) {
          _cores.shuffle();
          _formasParaArrastar.add(Forma(id: idCounter++, tipo: tipo, cor: _cores.first));
        }
      }
      _formasParaArrastar.shuffle();
      
      _formasNasCaixas = {for (var tipo in _tiposAlvo) tipo: []};
      
      _confettiController.stop();
    });
  }

  void _aoSoltarForma(Forma forma) {
    _animationControllers[forma.tipo]?.forward().then((_) {
      _animationControllers[forma.tipo]?.reverse();
    });

    setState(() {
      _formasParaArrastar.removeWhere((f) => f.id == forma.id);
      _formasNasCaixas[forma.tipo]!.add(forma);
    });

    if (_formasParaArrastar.isEmpty) {
      _confettiController.play();
      Future.delayed(const Duration(milliseconds: 400), _venceuJogo);
    }
  }

  Future<void> _venceuJogo() async {
    _stopwatch.stop();
    final tempoFinal = _stopwatch.elapsedMilliseconds / 1000;

    // Salva o tempo no repositório
    final recorde = await EstatisticasRepository.instance.registrarNovoTempoAtividade(
      atividade: Atividade.guardiaoDasFormas, 
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
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildInstruction(),
                Expanded(child: _buildAreaDeJogo()),
                _buildAreaDasCaixas(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaDeJogo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 20.0,
        runSpacing: 20.0,
        alignment: WrapAlignment.center,
        children: _formasParaArrastar.map((forma) {
          return Draggable<Forma>(
            data: forma,
            feedback: FormaGeometricaWidget(tipo: forma.tipo, tamanho: 60, cor: forma.cor.withOpacity(0.7)),
            childWhenDragging: const SizedBox(width: 60, height: 60),
            child: FormaGeometricaWidget(tipo: forma.tipo, tamanho: 60, cor: forma.cor),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAreaDasCaixas() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _tiposAlvo.map((tipoAlvo) {
          final controller = _animationControllers[tipoAlvo]!;
          final scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );

          return DragTarget<Forma>(
            builder: (context, candidateData, rejectedData) {
              return AnimatedBuilder(
                animation: scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: scaleAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 100,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: candidateData.isNotEmpty ? Colors.white : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForTipo(tipoAlvo),
                        color: Colors.white.withOpacity(0.5),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_formasNasCaixas[tipoAlvo]!.length} / $_totalPorForma',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            onWillAccept: (data) => data?.tipo == tipoAlvo,
            onAccept: (data) => _aoSoltarForma(data),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForTipo(TipoForma tipo) {
    switch (tipo) {
      case TipoForma.circulo: return Icons.circle_outlined;
      case TipoForma.quadrado: return Icons.square_outlined;
      case TipoForma.triangulo: return Icons.change_history_outlined;
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Guardião das Formas', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
          IconButton(onPressed: _iniciarRodada, icon: const Icon(Icons.refresh, color: Colors.white, size: 28)),
        ],
      ),
    );
  }
  
  Widget _buildInstruction() {
    return const Text('Arraste cada forma para sua caixa', style: TextStyle(fontSize: 20, color: Colors.white70));
  }
}