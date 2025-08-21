import 'dart:math';
import 'card.dart';

class Deck {
  final List<PlayingCard> _cards;
  final Random _random;

  Deck._(this._cards, this._random);

  factory Deck.standard({int? seed}) {
    final random = seed != null ? Random(seed) : Random();
    final cards = <PlayingCard>[];
    
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        cards.add(PlayingCard(id: CardId(suit: suit, rank: rank)));
      }
    }
    
    return Deck._(cards, random);
  }

  List<PlayingCard> get cards => List.unmodifiable(_cards);

  void shuffle() {
    _cards.shuffle(_random);
  }

  List<PlayingCard> deal(int count) {
    if (count > _cards.length) {
      throw ArgumentError('Cannot deal $count cards from deck with ${_cards.length} cards');
    }
    
    final dealt = _cards.take(count).toList();
    _cards.removeRange(0, count);
    return dealt;
  }

  PlayingCard? draw() {
    if (_cards.isEmpty) return null;
    return _cards.removeAt(0);
  }

  int get remainingCount => _cards.length;

  bool get isEmpty => _cards.isEmpty;

  // Deal initial table cards, replacing any Jacks
  List<PlayingCard> dealTableCards(int count) {
    final tableCards = <PlayingCard>[];
    final jacks = <PlayingCard>[];
    
    // Deal initial cards
    for (int i = 0; i < count; i++) {
      if (_cards.isEmpty) break;
      final card = _cards.removeAt(0);
      if (card.isJack) {
        jacks.add(card);
      } else {
        tableCards.add(card);
      }
    }
    
    // Replace Jacks with new cards
    for (final jack in jacks) {
      if (_cards.isNotEmpty) {
        tableCards.add(_cards.removeAt(0));
      }
    }
    
    return tableCards;
  }

  // Add Jacks back to the deck
  void addJacksBack(List<PlayingCard> jacks) {
    _cards.addAll(jacks);
  }
}
