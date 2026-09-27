import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/expense_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDark = themeProvider.isDarkMode;
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: isDark ? Brightness.dark : Brightness.light,
              scaffoldBackgroundColor: isDark ? const Color(0xFF0B0F14) : const Color(0xFFF5F7F6),
              colorScheme: isDark
                  ? const ColorScheme.dark(
                      primary: Color(0xFF34D399),
                      secondary: Color(0xFFF5C563),
                      surface: Color(0xFF12181F),
                    )
                  : const ColorScheme.light(
                      primary: Color(0xFF10B981),
                      secondary: Color(0xFFD97706),
                      surface: Colors.white,
                    ),
              textTheme: GoogleFonts.poppinsTextTheme(
                isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
              ),
            ),
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    backgroundColor: isDark ? const Color(0xFF0B0F14) : Colors.white,
                    body: const Center(child: CircularProgressIndicator(color: Color(0xFF34D399))),
                  );
                }
                if (snapshot.hasData) {
                  return const HomeScreen();
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}