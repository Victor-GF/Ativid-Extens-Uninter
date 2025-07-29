import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart'; // ALTERAÇÃO: Importar o pacote de confetes
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

  // ALTERAÇÃO: Aumentar o número de chaves para 4 torres
  final _chavesDasTorres = [
    GlobalKey<TorreState>(),
    GlobalKey<TorreState>(),
    GlobalKey<TorreState>(),
    GlobalKey<TorreState>()
  ];

  final _cores = [Colors.teal, Colors.pink, Colors.orange, Colors.purple];
  
  // ALTERAÇÃO: Adicionar o controller para os confetes
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // ALTERAÇÃO: Inicializar o controller
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _iniciarNovaRodada();
  }

  @override
  void dispose() {
    // ALTERAÇÃO: Dispensar o controller
    _confettiController.dispose();
    super.dispose();
  }

  void _iniciarNovaRodada() {
    _confettiController.stop(); // Garante que os confetes parem
    final random = Random();
    
    // ALTERAÇÃO: Gerar 4 alturas diferentes
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

    setState(() {
      _bloquearToques = false; // Garante que os toques sejam liberados
    });
  }

  void _onTorreTap(int indiceTocado) {
    if (_bloquearToques) return;

    setState(() => _bloquearToques = true);

    if (indiceTocado == _indiceCorreto) {
      // ALTERAÇÃO: Tocar confetes e mostrar dialog em vez de ir para a próxima rodada
      _chavesDasTorres[indiceTocado].currentState?.animarAcerto();
      _confettiController.play();
      Future.delayed(const Duration(milliseconds: 400), () {
        _showWinDialog();
      });
    } else {
      _chavesDasTorres[indiceTocado].currentState?.animarErro();
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => _bloquearToques = false);
      });
    }
  }

  // ALTERAÇÃO: Novo método para exibir o dialog de acerto
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF1F2937),
          title: const Text('Muito bem!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text('Próxima Rodada', style: TextStyle(color: Colors.tealAccent, fontSize: 16, fontWeight: FontWeight.bold)),
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