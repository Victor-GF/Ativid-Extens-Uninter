import 'package:atividade_extensionista_uninter/data/models/atividade.dart';
import 'package:atividade_extensionista_uninter/data/models/estatistica_jogo.dart';
import 'package:atividade_extensionista_uninter/data/repositories/estatisticas_repository.dart';
import 'package:flutter/material.dart';

class EstatisticasScreen extends StatefulWidget {
  const EstatisticasScreen({super.key});

  @override
  State<EstatisticasScreen> createState() => _EstatisticasScreenState();
}

class _EstatisticasScreenState extends State<EstatisticasScreen> {
  bool _isLoading = true;
  late List<EstatisticaJogo> _estatisticas;

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    // Busca as estatísticas de todas as atividades definidas no nosso enum
    final List<EstatisticaJogo> statsCarregadas = [];
    for (var activity in Atividade.values) {
      final stat = await EstatisticasRepository.instance.getEstatisticas(activity.id);
      statsCarregadas.add(stat);
    }

    // Atualiza a tela com os dados carregados
    if (mounted) {
      setState(() {
        _estatisticas = statsCarregadas;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _estatisticas.length,
              itemBuilder: (context, index) {
                final stat = _estatisticas[index];
                // Busca o label do nosso enum usando o id salvo
                final activityLabel = Atividade.values.firstWhere((a) => a.id == stat.nomeDoJogo).label;

                return Card(
                  color: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activityLabel,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        // Usamos RichText para estilizar o label e o valor de forma diferente
                        _buildStatRow('🏆', 'Recorde de Tempo:', stat.recordeDeTempo == null ? 'Nenhum' : '${stat.recordeDeTempo!.toStringAsFixed(1)}s'),
                        const SizedBox(height: 8),
                        _buildStatRow('📊', 'Média de Tempo:', stat.mediaDeTempo == null ? 'Nenhum' : '${stat.mediaDeTempo!.toStringAsFixed(1)}s'),
                        const SizedBox(height: 8),
                        _buildStatRow('🎮', 'Total de Partidas:', stat.totalDePartidas?.toString() ?? 'Nenhum'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Widget auxiliar para criar as linhas de texto de forma consistente
  Widget _buildStatRow(String emoji, String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
        children: [
          TextSpan(text: '$emoji $label '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}