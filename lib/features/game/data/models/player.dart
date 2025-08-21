import 'package:json_annotation/json_annotation.dart';
import 'card.dart';

part 'player.g.dart';

@JsonSerializable()
class PlayerState {
  final String id;
  final List<PlayingCard> hand;
  final List<PlayingCard> captures;
  final bool isHuman;
  final String? name;
  final String? avatar;

  const PlayerState({
    required this.id,
    required this.hand,
    required this.captures,
    required this.isHuman,
    this.name,
    this.avatar,
  });

  factory PlayerState.fromJson(Map<String, dynamic> json) =>
      _$PlayerStateFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerStateToJson(this);

  PlayerState copyWith({
    String? id,
    List<PlayingCard>? hand,
    List<PlayingCard>? captures,
    bool? isHuman,
    String? name,
    String? avatar,
  }) {
    return PlayerState(
      id: id ?? this.id,
      hand: hand ?? this.hand,
      captures: captures ?? this.captures,
      isHuman: isHuman ?? this.isHuman,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }

  // Count cards by suit
  int get clubsCount => captures.where((card) => card.id.suit == Suit.clubs).length;
  int get diamondsCount => captures.where((card) => card.id.suit == Suit.diamonds).length;
  int get heartsCount => captures.where((card) => card.id.suit == Suit.hearts).length;
  int get spadesCount => captures.where((card) => card.id.suit == Suit.spades).length;

  // Check for special cards
  bool get hasTwoOfClubs => captures.any((card) =>
      card.id.rank == Rank.two && card.id.suit == Suit.clubs);
  
  bool get hasTenOfDiamonds => captures.any((card) =>
      card.id.rank == Rank.ten && card.id.suit == Suit.diamonds);

  // Total cards captured
  int get totalCards => captures.length;

  // Display name
  String get displayName => name ?? 'Player $id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerState &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          hand == other.hand &&
          captures == other.captures &&
          isHuman == other.isHuman;

  @override
  int get hashCode =>
      id.hashCode ^ hand.hashCode ^ captures.hashCode ^ isHuman.hashCode;

  @override
  String toString() => 'PlayerState(id: $id, hand: ${hand.length}, captures: ${captures.length})';
}
