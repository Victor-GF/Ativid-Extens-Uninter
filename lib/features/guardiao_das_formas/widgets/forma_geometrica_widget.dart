import 'package:flutter/material.dart';

// Enum para definir os tipos de forma
enum TipoForma { circulo, quadrado, triangulo }

// O widget que usa o CustomPainter
class FormaGeometricaWidget extends StatelessWidget {
  final TipoForma tipo;
  final double tamanho;
  final Color cor;

  const FormaGeometricaWidget({
    super.key,
    required this.tipo,
    required this.tamanho,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: CustomPaint(
        painter: _ShapePainter(tipo, cor),
      ),
    );
  }
}

// O pintor que efetivamente desenha as formas no canvas
class _ShapePainter extends CustomPainter {
  final TipoForma tipo;
  final Color cor;

  _ShapePainter(this.tipo, this.cor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = cor;

    switch (tipo) {
      case TipoForma.circulo:
        final center = Offset(size.width / 2, size.height / 2);
        canvas.drawCircle(center, size.width / 2, paint);
        break;
      case TipoForma.quadrado:
        final rect = Rect.fromLTWH(0, 0, size.width, size.height);
        canvas.drawRect(rect, paint);
        break;
      case TipoForma.triangulo:
        final path = Path();
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}