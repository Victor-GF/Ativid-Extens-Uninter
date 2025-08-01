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

  // Função para buscar os dados de um jogo
  Future<EstatisticaJogo> buscarEstatistica(String nomeDoJogo) async {
    // A lógica de buscar no Hive e converter de Map para o nosso modelo
    final dados = Map<String, dynamic>.from(_box.get(nomeDoJogo) ?? {});
    return EstatisticaJogo.fromMap(dados, nomeDoJogo);
  }

  // Função para salvar os dados de um jogo
  Future<void> salvarEstatistica(EstatisticaJogo estatistica) async {
    // A lógica de converter nosso modelo para Map e salvar no Hive
    await _box.put(estatistica.nomeDoJogo, estatistica.toMap());
  }
}