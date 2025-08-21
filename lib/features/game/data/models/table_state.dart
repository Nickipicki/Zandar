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
    // Remove in reverse order to maintain indices
    for (int i = indices.length - 1; i >= 0; i--) {
      newFaceUp.removeAt(indices[i]);
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
    
    // Exact rank matches
    for (int i = 0; i < faceUp.length; i++) {
      if (faceUp[i].id.rank == card.id.rank) {
        combinations.add([i]);
      }
    }
    
    // Sum combinations (if not a Jack)
    if (!card.isJack) {
      final sumCombos = _findSumCombinations(card.value);
      combinations.addAll(sumCombos);
    }
    
    return combinations;
  }

  // Find combinations of table cards that sum to target value
  List<List<int>> _findSumCombinations(int target) {
    final combinations = <List<int>>[];
    final values = faceUp.map((card) => card.value).toList();
    
    void backtrack(int start, int currentSum, List<int> currentCombo) {
      if (currentSum == target && currentCombo.isNotEmpty) {
        combinations.add(List.from(currentCombo));
        return;
      }
      
      if (currentSum > target) return;
      
      for (int i = start; i < values.length; i++) {
        currentCombo.add(i);
        backtrack(i + 1, currentSum + values[i], currentCombo);
        currentCombo.removeLast();
      }
    }
    
    backtrack(0, 0, []);
    return combinations;
  }

  // Check if a Jack can sweep all cards
  bool canJackSweep() {
    return faceUp.isNotEmpty;
  }

  // Get cards at specific indices
  List<PlayingCard> getCardsAtIndices(List<int> indices) {
    return indices.map((i) => faceUp[i]).toList();
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
