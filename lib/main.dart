import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MicroMovesApp(),
    ),
  );
}

class MicroMovesApp extends StatelessWidget {
  const MicroMovesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const lightSeed = Colors.deepOrange;
    const darkSeed = Colors.deepOrangeAccent;

    return MaterialApp(
      title: 'MicroMoves',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightSeed,
          brightness: Brightness.light,
          primary: const Color(0xFFFF5722),
          secondary: const Color(0xFFFFB300),
          tertiary: const Color(0xFF00BCD4),
          surface: const Color(0xFFFFF9F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF7F0),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black87, width: 2.5),
          ),
          color: Colors.white,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.black87, width: 2.5),
          ),
          elevation: 6,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.black87, width: 2),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black87, width: 2.5),
          ),
          backgroundColor: const Color(0xFFFFB300),
          foregroundColor: Colors.black87,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 8,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFFE082),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkSeed,
          brightness: Brightness.dark,
          primary: const Color(0xFFFF7043),
          secondary: const Color(0xFFFFCA28),
          tertiary: const Color(0xFF26C6DA),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white24, width: 2),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.white24, width: 2),
          ),
          elevation: 6,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white24, width: 2),
          ),
          backgroundColor: const Color(0xFFFFCA28),
          foregroundColor: Colors.black87,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFFFF7043).withValues(alpha: 0.4),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}
