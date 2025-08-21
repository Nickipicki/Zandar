import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/typography.dart';
import '../../data/models/table_state.dart';
import 'card_view.dart';

class TableGrid extends StatelessWidget {
  final TableState tableState;
  final List<int> selectedIndices;
  final Function(int) onCardTap;

  const TableGrid({
    super.key,
    required this.tableState,
    required this.selectedIndices,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tableState.faceUp.isEmpty) {
      return _buildEmptyTable();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Table (${tableState.faceUp.length} cards)',
            style: ZandarTypography.textTheme.titleMedium!.copyWith(
              color: ZandarColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCardGrid(),
        ],
      ),
    );
  }

  Widget _buildEmptyTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Table is empty',
            style: ZandarTypography.textTheme.titleMedium!.copyWith(
              color: ZandarColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: ZandarColors.onPrimary.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.table_bar,
                size: 48,
                color: ZandarColors.onPrimary.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    // Calculate grid layout based on number of cards
    final cardCount = tableState.faceUp.length;
    int columns = 4;
    
    if (cardCount <= 4) {
      columns = 2;
    } else if (cardCount <= 6) {
      columns = 3;
    } else if (cardCount <= 8) {
      columns = 4;
    } else {
      columns = 5;
    }

    final rows = (cardCount / columns).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(columns, (colIndex) {
              final cardIndex = rowIndex * columns + colIndex;
              
              if (cardIndex >= cardCount) {
                return const SizedBox(width: 70, height: 90);
              }

              final card = tableState.faceUp[cardIndex];
              final isSelected = selectedIndices.contains(cardIndex);

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (cardIndex * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.7 + (value * 0.3),
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: CardView(
                            card: card,
                            isSelected: isSelected,
                            isHighlighted: isSelected,
                            onTap: () => onCardTap(cardIndex),
                            width: 70,
                            height: 90,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        );
      }),
    );
  }
}
