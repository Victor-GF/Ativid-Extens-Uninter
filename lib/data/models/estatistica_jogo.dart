class EstatisticaJogo {
  final String nomeDoJogo;
  double? recordeDeTempo; // Em segundos
  double? mediaDeTempo;
  int? totalDePartidas;

  EstatisticaJogo({
    required this.nomeDoJogo,
    this.recordeDeTempo,
    this.mediaDeTempo,
    this.totalDePartidas,
  });

  // Funções de conversão para salvar no Hive (que usa Mapas)
  Map<String, dynamic> toMap() => {
        'recordeDeTempo': recordeDeTempo,
        'mediaDeTempo': mediaDeTempo,
        'totalDePartidas': totalDePartidas,
      };

  factory EstatisticaJogo.fromMap(Map<String, dynamic> map, String nomeDoJogo) {
    return EstatisticaJogo(
      nomeDoJogo: nomeDoJogo,
      recordeDeTempo: map['recordeDeTempo'],
      mediaDeTempo: map['mediaDeTempo'],
      totalDePartidas: map['totalDePartidas'],
    );
  }
}