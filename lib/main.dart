import 'package:atividade_extensionista_uninter/data/repositories/estatisticas_repository.dart';
import 'package:atividade_extensionista_uninter/features/menu/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  // Garante que os widgets do Flutter sejam inicializados antes de qualquer outra coisa
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa nosso repositório de estatísticas
  await EstatisticasRepository.instance.init();

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
