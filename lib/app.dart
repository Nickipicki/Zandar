import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';
import 'features/game/presentation/screens/lobby_screen.dart';

class ZandarApp extends StatelessWidget {
  const ZandarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Žandar',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ZandarColors.primary,
          brightness: Brightness.light,
        ),
        textTheme: ZandarTypography.textTheme,
        fontFamily: 'Inter',
        
        // Card theme
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: ZandarColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: ZandarColors.primary,
          foregroundColor: ZandarColors.onPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: ZandarTypography.textTheme.headlineSmall!.copyWith(
            color: ZandarColors.onPrimary,
          ),
        ),
        
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ZandarColors.accent,
            foregroundColor: ZandarColors.onAccent,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      
      home: const LobbyScreen(),
    );
  }
}
