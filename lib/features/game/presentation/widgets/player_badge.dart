import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../data/models/player.dart';

class PlayerBadge extends StatelessWidget {
  final PlayerState player;
  final bool isCurrentTurn;
  final String position; // 'left', 'right', 'top'

  const PlayerBadge({
    super.key,
    required this.player,
    required this.isCurrentTurn,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentTurn 
          ? ZandarColors.accent.withOpacity(0.3)
          : ZandarColors.onPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTurn ? ZandarColors.accent : ZandarColors.onPrimary.withOpacity(0.3),
          width: isCurrentTurn ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ZandarColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player icon and name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                player.isHuman ? Icons.person : Icons.computer,
                color: isCurrentTurn ? ZandarColors.accent : ZandarColors.onPrimary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                player.displayName,
                style: ZandarTypography.bodySmall.copyWith(
                  color: ZandarColors.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Capture pile
          _buildCapturePile(),
          
          // Hand count
          if (!player.isHuman) ...[
            const SizedBox(height: 4),
            Text(
              '${player.hand.length} cards',
              style: ZandarTypography.bodySmall.copyWith(
                color: ZandarColors.onPrimary.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapturePile() {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: ZandarColors.cardBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: ZandarColors.cardBorder),
      ),
      child: Stack(
        children: [
          // Background cards
          if (player.captures.isNotEmpty) ...[
            Positioned(
              left: 2,
              top: 2,
              child: Container(
                width: 36,
                height: 26,
                decoration: BoxDecoration(
                  color: ZandarColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (player.captures.length > 1)
              Positioned(
                left: 4,
                top: 4,
                child: Container(
                  width: 36,
                  height: 26,
                  decoration: BoxDecoration(
                    color: ZandarColors.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
          
          // Card count
          Center(
            child: Text(
              '${player.captures.length}',
              style: ZandarTypography.bodySmall.copyWith(
                color: ZandarColors.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
