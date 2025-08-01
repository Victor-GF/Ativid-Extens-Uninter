import 'package:atividade_extensionista_uninter/data/models/atividade.dart';
import 'package:atividade_extensionista_uninter/data/models/estatistica_jogo.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EstatisticasRepository {
  // Padrão Singleton
  EstatisticasRepository._();
  static final instance = EstatisticasRepository._();

  late final Box _box;
  static const String _boxName = 'estatisticasBox';

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  EstatisticaJogo getEstatisticas(String nomeDoJogo) {
    // Busca o mapa de dados do Hive. Se não existir, retorna um mapa vazio.
    final dadosDoHive = Map<String, dynamic>.from(_box.get(nomeDoJogo) ?? {});
    return EstatisticaJogo.fromMap(dadosDoHive, nomeDoJogo);
  }

  Future<void> registrarNovoTempoAtividade({
    required Atividade atividade,
    required double tempo,
  }) async {
    final estatisticasAtuais = getEstatisticas(atividade.id);

    // Verifica recorde
    if (tempo < estatisticasAtuais.recordeDeTempo) {
      estatisticasAtuais.recordeDeTempo = tempo;
    }

    // Atualiza média de tempo
    final mediaAtual = estatisticasAtuais.mediaDeTempo;
    final totalPartidas = estatisticasAtuais.totalDePartidas;
    estatisticasAtuais.mediaDeTempo = (mediaAtual * totalPartidas + tempo) / (totalPartidas + 1);
    
    // Incrementa o total de partidas
    estatisticasAtuais.totalDePartidas++;

    // Salva o objeto no banco de dados
    await _box.put(atividade.id, estatisticasAtuais.toMap());
  }
}