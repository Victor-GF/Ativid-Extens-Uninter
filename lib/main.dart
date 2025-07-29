import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/jogo_da_memoria/jogo_da_memoria.dart';
import 'features/torre_de_blocos/torre_de_blocos.dart';
import 'features/bastoes/bastoes_screen.dart';
import 'features/guardiao_das_formas/guardiao_das_formas_screen.dart';
import 'features/sequencia_cores/sequencia_cores_screen.dart';

void main() {
  runApp(const LudicApp());
}

class LudicApp extends StatelessWidget {
  const LudicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atividades Lúdicas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Nova fonte: Nunito. É moderna, limpa e amigável.
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117), // Fundo azul-escuro
        useMaterial3: true,
      ),
      // home: const JogoDaMemoriaScreen(),
      // home: const TorreDeBlocosScreen(),
      // home: const BastoesScreen()
      // home: const GuardiaoDasFormasScreen(),
      home: const SequenciaCoresScreen(),
    );
  }
}