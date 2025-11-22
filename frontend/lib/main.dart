import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Operations',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),

      home: ThemeProvider(
        toggleTheme: _toggleTheme,
        themeMode: _themeMode,
        child: const HomePage(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const primaryColor = Color(0xFF2563EB);
    const secondaryColor = Color(0xFF64748B);
    const accentColor = Color(0xFF00D4AA);
    const surfaceColor = Color(0xFFF7F9FC);
    const backgroundColor = Color(0xFFFFFFFF);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1A202C),
        onBackground: const Color(0xFF1A202C),
        error: const Color(0xFFE53E3E),
        outline: const Color(0xFFE2E8F0),
      ),
      
      // Typographie moderne avec Google Fonts
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: const Color(0xFF1A202C),
        displayColor: const Color(0xFF1A202C),
      ),
      
      // Surfaces
      scaffoldBackgroundColor: surfaceColor,
      cardColor: backgroundColor,
      
      // AppBar avec design moderne
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Color(0xFF1A202C),
        titleTextStyle: TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      
      // Cartes avec ombre moderne
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: backgroundColor,
        shadowColor: const Color(0xFF1A202C).withOpacity(0.08),
        surfaceTintColor: Colors.transparent,
      ),
      
      // Boutons avec design moderne
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          shadowColor: primaryColor.withOpacity(0.3),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(color: primaryColor.withOpacity(0.3), width: 2),
          foregroundColor: primaryColor,
        ),
      ),
      
      // Champs de texte modernes
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFE53E3E),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF718096),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF4A5568),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // FAB moderne
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      
      // Navigation moderne
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFFA0AEC0),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFF3B82F6);
    const secondaryColor = Color(0xFF94A3B8);
    const accentColor = Color(0xFF4FD1C7);
    const surfaceColor = Color(0xFF0D1117);
    const backgroundColor = Color(0xFF161B22);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: backgroundColor,
        background: surfaceColor,
        onPrimary: const Color(0xFF0D1117),
        onSecondary: const Color(0xFF0D1117),
        onSurface: const Color(0xFFF7FAFC),
        onBackground: const Color(0xFFF7FAFC),
        error: const Color(0xFFF56565),
        outline: const Color(0xFF30363D),
      ),
      
      // Typographie moderne avec Google Fonts
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: const Color(0xFFF7FAFC),
        displayColor: const Color(0xFFF7FAFC),
      ),
      
      scaffoldBackgroundColor: surfaceColor,
      cardColor: backgroundColor,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Color(0xFFF7FAFC),
        titleTextStyle: TextStyle(
          color: Color(0xFFF7FAFC),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: backgroundColor,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: const Color(0xFF0D1117),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF21262D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFF30363D),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF8B949E),
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFFB1BAC4),
          fontSize: 16,
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: const Color(0xFF0D1117),
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFF8B949E),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
    );
  }
}

class ThemeProvider extends InheritedWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  
  const ThemeProvider({
    Key? key,
    required this.toggleTheme,
    required this.themeMode,
    required Widget child,
  }) : super(key: key, child: child);

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) => oldWidget.themeMode != themeMode;
}