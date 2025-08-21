import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

class RulesSelector extends StatelessWidget {
  final int targetScore;
  final bool allowSumCapture;
  final bool jackSweepsAll;
  final ValueChanged<int> onTargetScoreChanged;
  final ValueChanged<bool> onSumCaptureChanged;
  final ValueChanged<bool> onJackSweepChanged;

  const RulesSelector({
    super.key,
    required this.targetScore,
    required this.allowSumCapture,
    required this.jackSweepsAll,
    required this.onTargetScoreChanged,
    required this.onSumCaptureChanged,
    required this.onJackSweepChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Target Score
        _buildRuleCard(
          title: 'Target Score',
          subtitle: 'First to $targetScore points wins',
          child: Row(
            children: [
              Expanded(
                child: _buildScoreButton(11, '11'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreButton(21, '21'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sum Capture Rule
        _buildRuleCard(
          title: 'Sum Capture',
          subtitle: 'Allow capturing multiple cards that sum to your card\'s value',
          child: Switch(
            value: allowSumCapture,
            onChanged: onSumCaptureChanged,
            activeColor: ZandarColors.accent,
          ),
        ),
        const SizedBox(height: 16),

        // Jack Sweep Rule
        _buildRuleCard(
          title: 'Jack Sweep',
          subtitle: 'Jacks capture all cards from the table',
          child: Switch(
            value: jackSweepsAll,
            onChanged: onJackSweepChanged,
            activeColor: ZandarColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildRuleCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZandarColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZandarColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: ZandarColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ZandarTypography.titleMedium.copyWith(
              color: ZandarColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: ZandarTypography.bodySmall.copyWith(
              color: ZandarColors.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildScoreButton(int score, String label) {
    final isSelected = targetScore == score;
    
    return GestureDetector(
      onTap: () => onTargetScoreChanged(score),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? ZandarColors.accent : ZandarColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? ZandarColors.accent : ZandarColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: ZandarTypography.titleMedium.copyWith(
            color: isSelected ? ZandarColors.onAccent : ZandarColors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
