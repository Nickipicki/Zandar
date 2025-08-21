import 'package:json_annotation/json_annotation.dart';

part 'rules.g.dart';

@JsonSerializable()
class Rules {
  final bool jackSweepsAll;
  final bool allowSumCapture;
  final int targetScore;
  final int initialTableCards;
  final int cardsPerDeal;
  final bool isPartnership;

  const Rules({
    this.jackSweepsAll = true,
    this.allowSumCapture = true,
    this.targetScore = 11,
    this.initialTableCards = 4,
    this.cardsPerDeal = 4,
    this.isPartnership = false,
  });

  factory Rules.fromJson(Map<String, dynamic> json) => _$RulesFromJson(json);
  Map<String, dynamic> toJson() => _$RulesToJson(this);

  Rules copyWith({
    bool? jackSweepsAll,
    bool? allowSumCapture,
    int? targetScore,
    int? initialTableCards,
    int? cardsPerDeal,
    bool? isPartnership,
  }) {
    return Rules(
      jackSweepsAll: jackSweepsAll ?? this.jackSweepsAll,
      allowSumCapture: allowSumCapture ?? this.allowSumCapture,
      targetScore: targetScore ?? this.targetScore,
      initialTableCards: initialTableCards ?? this.initialTableCards,
      cardsPerDeal: cardsPerDeal ?? this.cardsPerDeal,
      isPartnership: isPartnership ?? this.isPartnership,
    );
  }

  // Predefined rule sets
  static const Rules standard = Rules();
  
  static const Rules traditional = Rules(
    jackSweepsAll: true,
    allowSumCapture: true,
    targetScore: 11,
    initialTableCards: 4,
    cardsPerDeal: 4,
    isPartnership: false,
  );
  
  static const Rules partnership = Rules(
    jackSweepsAll: true,
    allowSumCapture: true,
    targetScore: 21,
    initialTableCards: 4,
    cardsPerDeal: 4,
    isPartnership: true,
  );
  
  static const Rules simple = Rules(
    jackSweepsAll: true,
    allowSumCapture: false,
    targetScore: 11,
    initialTableCards: 4,
    cardsPerDeal: 4,
    isPartnership: false,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rules &&
          runtimeType == other.runtimeType &&
          jackSweepsAll == other.jackSweepsAll &&
          allowSumCapture == other.allowSumCapture &&
          targetScore == other.targetScore &&
          initialTableCards == other.initialTableCards &&
          cardsPerDeal == other.cardsPerDeal &&
          isPartnership == other.isPartnership;

  @override
  int get hashCode =>
      jackSweepsAll.hashCode ^
      allowSumCapture.hashCode ^
      targetScore.hashCode ^
      initialTableCards.hashCode ^
      cardsPerDeal.hashCode ^
      isPartnership.hashCode;

  @override
  String toString() => 'Rules(jackSweepsAll: $jackSweepsAll, allowSumCapture: $allowSumCapture, targetScore: $targetScore)';
}
