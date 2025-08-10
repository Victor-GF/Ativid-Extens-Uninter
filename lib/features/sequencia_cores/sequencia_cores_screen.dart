import 'package:atividade_extensionista_uninter/data/models/atividade.dart';
import 'package:atividade_extensionista_uninter/data/repositories/estatisticas_repository.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'domain/gerardor_de_sequencia.dart';
import 'widgets/circulo_de_cor_widget.dart';

// Enum para controlar o estado do feedback visual
enum EstadoFeedback { nenhum, correto, incorreto }

class SequenciaCoresScreen extends StatefulWidget {
  const SequenciaCoresScreen({super.key});

  @override
  State<SequenciaCoresScreen> createState() => _SequenciaCoresScreenState();
}

class _SequenciaCoresScreenState extends State<SequenciaCoresScreen> {
  final _gerador = GeradorDeSequencia();
  final List<Color> _coresDoJogo = [
    Colors.blue.shade400,
    Colors.orange.shade400,
    Colors.green.shade400,
    Colors.red.shade400,
  ];

  late List<Color?> _sequencia;
  late Color _corCorreta;
  late List<Color> _opcoes;

  Color? _opcaoSelecionada;
  EstadoFeedback _estadoFeedback = EstadoFeedback.nenhum;
  late ConfettiController _confettiController;

  // Lista de chaves para controlar a animação de cada opção
  final List<GlobalKey<CirculoDeCorWidgetState>> _chavesDasOpcoes =
      List.generate(3, (_) => GlobalKey());

  // Para cronometrar o tempo
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _iniciarRodada();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
    _stopwatch.stop();
  }

  void _iniciarRodada() {
    final novaRodada = _gerador.gerarNovaRodada(coresDisponiveis: _coresDoJogo);

    _stopwatch.reset();
    _stopwatch.start();

    setState(() {
      _sequencia = novaRodada.sequencia;
      _corCorreta = novaRodada.corCorreta;
      _opcoes = novaRodada.opcoes;
      _estadoFeedback = EstadoFeedback.nenhum;
      _opcaoSelecionada = null;
      _confettiController.stop();
    });
  }

  void _onOpcaoTap(Color corSelecionada) {
    if (_estadoFeedback != EstadoFeedback.nenhum) return;

    setState(() {
      _opcaoSelecionada = corSelecionada;
      if (corSelecionada == _corCorreta) {
        _estadoFeedback = EstadoFeedback.correto;
        final indiceFaltando = _sequencia.indexOf(null);
        if (indiceFaltando != -1) {
          _sequencia[indiceFaltando] = _corCorreta;
        }
        _confettiController.play();
        Future.delayed(const Duration(milliseconds: 400), _venceuJogo);
      } else {
        // ALTERAÇÃO PRINCIPAL: Lógica para ativar a animação de tremor
        _estadoFeedback = EstadoFeedback.incorreto;

        final indiceErrado = _opcoes.indexOf(corSelecionada);
        if (indiceErrado != -1) {
          _chavesDasOpcoes[indiceErrado].currentState?.playShakeAnimation();
        }

        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _estadoFeedback = EstadoFeedback.nenhum;
            _opcaoSelecionada = null;
          });
        });
      }
    });
  }

  Future<void> _venceuJogo() async {
    _stopwatch.stop();
    final tempoFinal = _stopwatch.elapsedMilliseconds / 1000;

    // Salva o tempo no repositório
    final recorde = await EstatisticasRepository.instance
        .registrarNovoTempoAtividade(
          atividade: Atividade.sequenciaDasCores,
          tempo: tempoFinal,
        );

    _showWinDialog(recorde);
  }

  // Implementação movida para dentro da classe e com o nome correto.
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeader(),
                _buildInstruction(),
                _buildGradeSequencia(),
                _buildAreaDeOpcoes(),
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

  Widget _buildGradeSequencia() {
    return Container(
      // O "Quadro" que envolve a grade
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 colunas
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: 6, // 6 itens no total
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final cor = _sequencia[index];
          return CirculoDeCorWidget(
            cor: cor,
            // A borda verde de acerto agora envolve o quadro inteiro
            // Para simplificar, vamos deixar a borda apenas nas opções de resposta
            // borda: _estadoFeedback == EstadoFeedback.correto ? Border.all(color: Colors.green.shade400, width: 4) : null,
            child:
                cor == null
                    ? const Text(
                      '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildAreaDeOpcoes() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_opcoes.length, (index) {
          // Loop com índice
          final corOpcao = _opcoes[index];
          Border? borda;
          if (_opcaoSelecionada == corOpcao) {
            if (_estadoFeedback == EstadoFeedback.correto) {
              borda = Border.all(color: Colors.green.shade400, width: 4);
            } else if (_estadoFeedback == EstadoFeedback.incorreto) {
              borda = Border.all(color: Colors.red.shade400, width: 4);
            }
          }

          return GestureDetector(
            onTap: () => _onOpcaoTap(corOpcao),
            // ALTERAÇÃO: Atribuição da chave ao widget
            child: CirculoDeCorWidget(
              key: _chavesDasOpcoes[index],
              cor: corOpcao,
              borda: borda,
            ),
          );
        }),
      ),
    );
  }

  // CORREÇÃO: Implementação movida para dentro da classe e com o nome correto.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sequência das Cores',
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _iniciarRodada,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction() {
    return const Text(
      'Qual cor está faltando?',
      style: TextStyle(
        fontSize: 22,
        color: Colors.white70,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
