import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/book_provider.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with your platform options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cyber-Orchid Theme Colors for Global Consistency
    const Color violet = Color(0xFFA855F7);
    const Color obsidianBg = Color(0xFF0B0E14);

    return ChangeNotifierProvider(
      create: (_) => BookProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Lumina Library OS",
        
        // Updated Theme to match Glassmorphism / Cyber-Orchid Style
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: violet,
          scaffoldBackgroundColor: obsidianBg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: violet,
            brightness: Brightness.dark,
            secondary: const Color(0xFF22D3EE), // Ice Cyan
          ),
          // Ensures text fields across the app follow your glass style
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withOpacity(0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          useMaterial3: true,
        ),

        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}
