import 'package:json_annotation/json_annotation.dart';

part 'card.g.dart';

enum Suit {
  @JsonValue('clubs')
  clubs,
  @JsonValue('diamonds')
  diamonds,
  @JsonValue('hearts')
  hearts,
  @JsonValue('spades')
  spades,
}

enum Rank {
  @JsonValue('ace')
  ace,
  @JsonValue('two')
  two,
  @JsonValue('three')
  three,
  @JsonValue('four')
  four,
  @JsonValue('five')
  five,
  @JsonValue('six')
  six,
  @JsonValue('seven')
  seven,
  @JsonValue('eight')
  eight,
  @JsonValue('nine')
  nine,
  @JsonValue('ten')
  ten,
  @JsonValue('jack')
  jack,
  @JsonValue('queen')
  queen,
  @JsonValue('king')
  king,
}

@JsonSerializable()
class CardId {
  final Suit suit;
  final Rank rank;

  const CardId({
    required this.suit,
    required this.rank,
  });

  factory CardId.fromJson(Map<String, dynamic> json) => _$CardIdFromJson(json);
  Map<String, dynamic> toJson() => _$CardIdToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardId &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  @override
  String toString() => 'CardId(suit: $suit, rank: $rank)';
}

@JsonSerializable()
class PlayingCard {
  final CardId id;

  const PlayingCard({required this.id});

  factory PlayingCard.fromJson(Map<String, dynamic> json) =>
      _$PlayingCardFromJson(json);
  Map<String, dynamic> toJson() => _$PlayingCardToJson(this);

  int get value => switch (id.rank) {
    Rank.ace => 11, // Ass ist standardmäßig 11, kann aber auch als 1 verwendet werden
    Rank.jack => 11,
    Rank.queen => 12,
    Rank.king => 13,
    _ => id.rank.index + 1
  };

  // Get all possible values for this card (for Ace: [1, 11], for others: [value])
  List<int> get possibleValues => switch (id.rank) {
    Rank.ace => [1, 11],
    _ => [value]
  };

  bool get isJack => id.rank == Rank.jack;
  bool get isSpecial => (id.rank == Rank.two && id.suit == Suit.clubs) ||
      (id.rank == Rank.ten && id.suit == Suit.diamonds);

  String get displayName {
    final rankName = switch (id.rank) {
      Rank.ace => 'A',
      Rank.jack => 'J',
      Rank.queen => 'Q',
      Rank.king => 'K',
      _ => (id.rank.index + 1).toString(),
    };

    final suitSymbol = switch (id.suit) {
      Suit.clubs => '♣',
      Suit.diamonds => '♦',
      Suit.hearts => '♥',
      Suit.spades => '♠',
    };

    return '$rankName$suitSymbol';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PlayingCard(${displayName})';
}
