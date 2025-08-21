import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/typography.dart';
import '../../data/models/card.dart';

class CardView extends StatelessWidget {
  final PlayingCard card;
  final bool isSelected;
  final bool isHighlighted;
  final bool isFaceDown;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const CardView({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isFaceDown = false,
    this.onTap,
    this.width = 60,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isFaceDown ? ZandarColors.primary : ZandarColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getShadowColor(),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: isFaceDown ? _buildFaceDown() : _buildFaceUp(),
      ),
    );
  }

  Widget _buildFaceDown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ZandarColors.primary,
            ZandarColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.style,
          color: ZandarColors.onPrimary.withOpacity(0.7),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFaceUp() {
    final isRedSuit = card.id.suit == Suit.hearts || card.id.suit == Suit.diamonds;
    final suitColor = isRedSuit ? ZandarColors.hearts : ZandarColors.clubs;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          // Top left corner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getRankText(),
                    style: ZandarTypography.cardRank.copyWith(
                      color: suitColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _getSuitSymbol(),
                    style: ZandarTypography.cardSuit.copyWith(
                      color: suitColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const Spacer(),
          
          // Center suit symbol
          Text(
            _getSuitSymbol(),
            style: ZandarTypography.cardSuit.copyWith(
              color: suitColor,
              fontSize: 20,
            ),
          ),
          
          const Spacer(),
          
          // Bottom right corner (rotated)
          Transform.rotate(
            angle: 3.14159, // 180 degrees
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getRankText(),
                      style: ZandarTypography.cardRank.copyWith(
                        color: suitColor,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _getSuitSymbol(),
                      style: ZandarTypography.cardSuit.copyWith(
                        color: suitColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRankText() {
    return switch (card.id.rank) {
      Rank.ace => 'A',
      Rank.jack => 'J',
      Rank.queen => 'Q',
      Rank.king => 'K',
      _ => (card.id.rank.index + 1).toString(),
    };
  }

  String _getSuitSymbol() {
    return switch (card.id.suit) {
      Suit.clubs => '♣',
      Suit.diamonds => '♦',
      Suit.hearts => '♥',
      Suit.spades => '♠',
    };
  }

  Color _getBorderColor() {
    if (isSelected) return ZandarColors.highlight;
    if (isHighlighted) return ZandarColors.validMove;
    return ZandarColors.cardBorder;
  }

  Color _getShadowColor() {
    if (isSelected) return ZandarColors.highlight.withOpacity(0.5);
    if (isHighlighted) return ZandarColors.validMove.withOpacity(0.3);
    return ZandarColors.shadow;
  }
}
