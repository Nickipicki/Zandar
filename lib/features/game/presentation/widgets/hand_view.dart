import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/typography.dart';
import '../../data/models/card.dart';
import 'card_view.dart';

class HandView extends StatelessWidget {
  final List<PlayingCard> hand;
  final PlayingCard? selectedCard;
  final Function(PlayingCard) onCardTap;
  final VoidCallback onCardPlay;
  final bool isValidMove;

  const HandView({
    super.key,
    required this.hand,
    required this.selectedCard,
    required this.onCardTap,
    required this.onCardPlay,
    required this.isValidMove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZandarColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: ZandarColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hand title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Hand (${hand.length})',
                style: ZandarTypography.textTheme.titleMedium!.copyWith(
                  color: ZandarColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (selectedCard != null)
                ElevatedButton(
                  onPressed: isValidMove ? onCardPlay : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValidMove 
                      ? ZandarColors.accent 
                      : ZandarColors.scoreNeutral,
                    foregroundColor: ZandarColors.onAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Play Card',
                    style: ZandarTypography.buttonText.copyWith(fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Cards
          if (hand.isEmpty)
            _buildEmptyHand()
          else
            _buildCards(),
        ],
      ),
    );
  }

  Widget _buildEmptyHand() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: ZandarColors.cardBorder, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'No cards in hand',
                              style: ZandarTypography.textTheme.bodyMedium!.copyWith(
            color: ZandarColors.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCards() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hand.length,
        itemBuilder: (context, index) {
          final card = hand[index];
          final isSelected = selectedCard == card;
          
          return Padding(
            padding: EdgeInsets.only(
              right: index < hand.length - 1 ? 8 : 0,
            ),
            child: Transform.translate(
              offset: Offset(0, isSelected ? -10 : 0),
              child: CardView(
                card: card,
                isSelected: isSelected,
                onTap: () => onCardTap(card),
                width: 70,
                height: 90,
              ),
            ),
          );
        },
      ),
    );
  }
}
