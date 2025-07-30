import 'package:atividade_extensionista_uninter/features/menu/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        useMaterial3: true,
      ),
      // A tela inicial do app agora é o menu principal
      home: const MenuPrincipalScreen(),
    );
  }
}