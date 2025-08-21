import 'package:json_annotation/json_annotation.dart';
import 'card.dart';

part 'table_state.g.dart';

@JsonSerializable()
class TableState {
  final List<PlayingCard> faceUp;

  const TableState({required this.faceUp});

  factory TableState.fromJson(Map<String, dynamic> json) =>
      _$TableStateFromJson(json);
  Map<String, dynamic> toJson() => _$TableStateToJson(this);

  TableState copyWith({List<PlayingCard>? faceUp}) {
    return TableState(faceUp: faceUp ?? this.faceUp);
  }

  // Add a card to the table
  TableState addCard(PlayingCard card) {
    return copyWith(faceUp: [...faceUp, card]);
  }

  // Remove cards from the table
  TableState removeCards(List<int> indices) {
    final newFaceUp = List<PlayingCard>.from(faceUp);
    // Sort indices in descending order and remove to maintain valid indices
    final sortedIndices = List<int>.from(indices)..sort((a, b) => b.compareTo(a));
    for (final index in sortedIndices) {
      if (index >= 0 && index < newFaceUp.length) {
        newFaceUp.removeAt(index);
      }
    }
    return copyWith(faceUp: newFaceUp);
  }

  // Clear all cards from the table
  TableState clear() {
    return copyWith(faceUp: []);
  }

  // Get all possible capture combinations for a given card
  List<List<int>> getCaptureCombinations(PlayingCard card) {
    final combinations = <List<int>>[];
    
    // Debug output
    print('Getting capture combinations for: $card');
    print('Table cards: ${faceUp.map((c) => '${c}(${c.value})').join(', ')}');
    
    // Exact rank matches
    for (int i = 0; i < faceUp.length; i++) {
      if (faceUp[i].id.rank == card.id.rank) {
        combinations.add([i]);
        print('  Found rank match at index $i: ${faceUp[i]}');
      }
    }
    
    // Sum combinations (if not a Jack)
    if (!card.isJack) {
      // Check all possible values for the card (for Ace: 1 and 11)
      for (final cardValue in card.possibleValues) {
        print('  Checking sum combinations for card value: $cardValue');
        final sumCombos = _findSumCombinations(cardValue);
        combinations.addAll(sumCombos);
        print('  Found ${sumCombos.length} sum combinations: $sumCombos');
      }
    }
    
    print('  Total combinations: ${combinations.length}');
    return combinations;
  }

  // Find combinations of table cards that sum to target value
  List<List<int>> _findSumCombinations(int target) {
    final combinations = <List<int>>[];
    
    // Get all possible values for each table card (for Aces: [1, 11], for others: [value])
    final cardValueOptions = faceUp.map((card) => card.possibleValues).toList();
    
    void backtrack(int start, int currentSum, List<int> currentCombo, List<int> usedValues) {
      if (currentSum == target && currentCombo.isNotEmpty) {
        combinations.add(List.from(currentCombo));
        return;
      }
      
      if (currentSum > target) return;
      
      for (int i = start; i < faceUp.length; i++) {
        for (int j = 0; j < cardValueOptions[i].length; j++) {
          final value = cardValueOptions[i][j];
          currentCombo.add(i);
          usedValues.add(value);
          backtrack(i + 1, currentSum + value, currentCombo, usedValues);
          currentCombo.removeLast();
          usedValues.removeLast();
        }
      }
    }
    
    backtrack(0, 0, [], []);
    
    // Debug output for sum combinations
    print('    Target: $target, Found combinations: $combinations');
    for (final combo in combinations) {
      final values = combo.map((i) => '${faceUp[i]}(${faceUp[i].value})').join(' + ');
      print('    Combination: $combo = $values');
    }
    
    return combinations;
  }

  // Check if a Jack can sweep all cards
  bool canJackSweep() {
    return faceUp.isNotEmpty;
  }

  // Get cards at specific indices
  List<PlayingCard> getCardsAtIndices(List<int> indices) {
    return indices.map((i) {
      if (i < 0 || i >= faceUp.length) {
        throw RangeError('Index $i is out of range (0..${faceUp.length - 1})');
      }
      return faceUp[i];
    }).toList();
  }

  bool get isEmpty => faceUp.isEmpty;
  int get cardCount => faceUp.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableState &&
          runtimeType == other.runtimeType &&
          faceUp == other.faceUp;

  @override
  int get hashCode => faceUp.hashCode;

  @override
  String toString() => 'TableState(faceUp: ${faceUp.length} cards)';
}
