import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add your Supabase project URL and anon key after creating a project.
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  runApp(const TelegramXApp());
}

class TelegramXApp extends StatelessWidget {
  const TelegramXApp({super.key});

  @override
  Widget build(BuildContext context) {
    final configured = Supabase.instance.isInitialized;
    return MaterialApp(
      title: 'TELEGRAM X',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF229ED9),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101820),
        useMaterial3: true,
      ),
      home: configured
          ? (Supabase.instance.client.auth.currentSession == null
              ? const AuthScreen()
              : const HomeScreen())
          : const SetupScreen(),
    );
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.send_rounded, size: 64, color: Color(0xFF229ED9)),
                SizedBox(height: 16),
                Text('TELEGRAM X', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text(
                  'Проект создан. Чтобы включить реальные аккаунты и сообщения, '
                  'подключите проект Supabase по инструкции в README.md.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}
