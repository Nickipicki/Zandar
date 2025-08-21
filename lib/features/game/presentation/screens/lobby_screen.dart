import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/typography.dart';
import '../../data/models/rules.dart';
import '../widgets/game_mode_card.dart';
import '../widgets/rules_selector.dart';
import 'table_screen.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  bool _isPartnership = false;
  int _targetScore = 11;
  bool _allowSumCapture = true;
  bool _jackSweepsAll = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZandarColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Settings Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _showLanguageSettings,
                    icon: Icon(
                      Icons.settings,
                      color: ZandarColors.primary,
                      size: 28,
                    ),
                    tooltip: 'Settings',
                  ),
                  const Spacer(),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                                        // Header
                    Text(
                      'app_title'.tr(),
                      style: ZandarTypography.textTheme.displayMedium!.copyWith(
                        color: ZandarColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'app_subtitle'.tr(),
                      style: ZandarTypography.textTheme.bodyLarge!.copyWith(
                        color: ZandarColors.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
              const SizedBox(height: 32),

              // Game Modes
              Text(
                'choose_game_mode'.tr(),
                style: ZandarTypography.textTheme.headlineSmall!.copyWith(
                  color: ZandarColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: GameModeCard(
                      title: 'solo_vs_ai'.tr(),
                      subtitle: 'solo_vs_ai_subtitle'.tr(),
                      icon: Icons.computer,
                      isSelected: !_isPartnership,
                      onTap: () => setState(() => _isPartnership = false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GameModeCard(
                      title: 'partnership'.tr(),
                      subtitle: 'partnership_subtitle'.tr(),
                      icon: Icons.group,
                      isSelected: _isPartnership,
                      onTap: () => setState(() => _isPartnership = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Game Rules
              Text(
                'house_rules'.tr(),
                style: ZandarTypography.textTheme.headlineSmall!.copyWith(
                  color: ZandarColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              RulesSelector(
                targetScore: _targetScore,
                allowSumCapture: _allowSumCapture,
                jackSweepsAll: _jackSweepsAll,
                onTargetScoreChanged: (value) => setState(() => _targetScore = value),
                onSumCaptureChanged: (value) => setState(() => _allowSumCapture = value),
                onJackSweepChanged: (value) => setState(() => _jackSweepsAll = value),
              ),
              const SizedBox(height: 24),

              // Start Game Button
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZandarColors.accent,
                  foregroundColor: ZandarColors.onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'start_game'.tr(),
                  style: ZandarTypography.buttonText.copyWith(
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tutorial Button
              OutlinedButton(
                onPressed: _showTutorial,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ZandarColors.primary,
                  side: BorderSide(color: ZandarColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'how_to_play'.tr(),
                  style: ZandarTypography.buttonText.copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16), // Extra padding at bottom
            ],
          ),
        ),
      ],
    ),
  );
}

  void _startGame() {
    final rules = Rules(
      jackSweepsAll: _jackSweepsAll,
      allowSumCapture: _allowSumCapture,
      targetScore: _targetScore,
      isPartnership: _isPartnership,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TableScreen(
          rules: rules,
          isPartnership: _isPartnership,
        ),
      ),
    );
  }

  void _showLanguageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'language_settings'.tr(),
          style: ZandarTypography.textTheme.headlineSmall!,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'en', '🇺🇸'),
            _buildLanguageOption('Deutsch', 'de', '🇩🇪'),
            _buildLanguageOption('Српски', 'sr', '🇷🇸'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String name, String code, String flag) {
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: 24)),
      title: Text(name),
      onTap: () {
        // Change language
        final locale = Locale(code);
        context.setLocale(locale);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language changed to $name')),
        );
      },
    );
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'tutorial_title'.tr(),
          style: ZandarTypography.textTheme.headlineSmall!,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTutorialSection(
                'objective'.tr(),
                'objective_desc'.tr(),
              ),
              _buildTutorialSection(
                'capturing_cards'.tr(),
                'capturing_cards_desc'.tr(),
              ),
              _buildTutorialSection(
                'scoring'.tr(),
                'scoring_desc'.tr(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('got_it'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ZandarTypography.textTheme.titleMedium!.copyWith(
              color: ZandarColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: ZandarTypography.textTheme.bodyMedium!,
          ),
        ],
      ),
    );
  }
}
