import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Žandar',
                style: ZandarTypography.textTheme.displayMedium!.copyWith(
                  color: ZandarColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Traditional Balkan Card Game',
                style: ZandarTypography.textTheme.bodyLarge!.copyWith(
                  color: ZandarColors.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Game Modes
              Text(
                'Choose Game Mode',
                style: ZandarTypography.textTheme.headlineSmall!.copyWith(
                  color: ZandarColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: GameModeCard(
                      title: 'Solo vs AI',
                      subtitle: 'Play against computer',
                      icon: Icons.computer,
                      isSelected: !_isPartnership,
                      onTap: () => setState(() => _isPartnership = false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GameModeCard(
                      title: 'Partnership',
                      subtitle: '2 vs 2 teams',
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
                'House Rules',
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
                  'Start Game',
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
                  'How to Play',
                  style: ZandarTypography.buttonText.copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16), // Extra padding at bottom
            ],
          ),
        ),
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

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'How to Play Žandar',
          style: ZandarTypography.textTheme.headlineSmall!,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTutorialSection(
                'Objective',
                'Be the first to reach the target score by capturing cards.',
              ),
              _buildTutorialSection(
                'Capturing Cards',
                '• Match: Play a card of the same rank as a table card\n'
                '• Sum: Play a card equal to the sum of multiple table cards\n'
                '• Jack: Sweeps all cards from the table',
              ),
              _buildTutorialSection(
                'Scoring',
                '• +2 points: Most total cards captured\n'
                '• +1 point: Most clubs captured\n'
                '• +1 point: Captured 2♣ (little two)\n'
                '• +1 point: Captured 10♦ (big ten)',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it!'),
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
