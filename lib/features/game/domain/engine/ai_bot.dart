import 'dart:math';
import '../../data/models/game_state.dart';
import '../../data/models/card.dart';

class AIBot {
  final Random _random = Random();

  // Generate the best move for the AI player
  Move generateMove(GameState gameState) {
    final validMoves = gameState.getValidMoves();
    if (validMoves.isEmpty) {
      throw StateError('No valid moves available for AI');
    }

    // Score each move
    final scoredMoves = <Move, double>{};
    for (final move in validMoves) {
      scoredMoves[move] = _scoreMove(move, gameState);
    }

    // Find the best move(s)
    final maxScore = scoredMoves.values.reduce(max);
    final bestMoves = scoredMoves.entries
        .where((entry) => entry.value == maxScore)
        .map((entry) => entry.key)
        .toList();

    // Add some randomness to avoid predictable play
    final selectedMove = bestMoves[_random.nextInt(bestMoves.length)];
    
    // Add small random jitter to scores to break ties
    if (bestMoves.length > 1) {
      final jitter = _random.nextDouble() * 0.1;
      scoredMoves[selectedMove] = scoredMoves[selectedMove]! + jitter;
    }

    return selectedMove;
  }

  // Score a move based on various factors
  double _scoreMove(Move move, GameState gameState) {
    double score = 0.0;

    // Base score for different move types
    switch (move.type) {
      case MoveType.jackSweep:
        score += _scoreJackSweep(move, gameState);
        break;
      case MoveType.match:
        score += _scoreMatch(move, gameState);
        break;
      case MoveType.sum:
        score += _scoreSumCapture(move, gameState);
        break;
      case MoveType.place:
        score += _scorePlace(move, gameState);
        break;
    }

    // Bonus for capturing special cards
    score += _scoreSpecialCards(move, gameState);

    // Bonus for capturing clubs
    score += _scoreClubsCapture(move, gameState);

    // Bonus for card majority
    score += _scoreCardMajority(move, gameState);

    // Penalty for leaving good opportunities for opponent
    score -= _scoreOpponentOpportunities(move, gameState);

    return score;
  }

  // Score a Jack sweep move
  double _scoreJackSweep(Move move, GameState gameState) {
    double score = 10.0; // Base score for Jack sweep
    
    // Bonus for sweeping more cards
    score += gameState.table.faceUp.length * 2.0;
    
    // Bonus for sweeping when table has many cards
    if (gameState.table.faceUp.length >= 3) {
      score += 5.0;
    }
    
    return score;
  }

  // Score a match capture
  double _scoreMatch(Move move, GameState gameState) {
    double score = 5.0; // Base score for match
    
    final capturedCard = gameState.table.getCardsAtIndices(move.tableIndices).first;
    
    // Bonus for capturing special cards
    if (capturedCard.isSpecial) {
      score += 15.0;
    }
    
    // Bonus for capturing clubs
    if (capturedCard.id.suit == Suit.clubs) {
      score += 3.0;
    }
    
    return score;
  }

  // Score a sum capture
  double _scoreSumCapture(Move move, GameState gameState) {
    double score = 3.0; // Base score for sum capture
    
    final capturedCards = gameState.table.getCardsAtIndices(move.tableIndices);
    
    // Bonus for capturing more cards
    score += capturedCards.length * 1.5;
    
    // Bonus for capturing special cards
    for (final card in capturedCards) {
      if (card.isSpecial) {
        score += 15.0;
      }
      if (card.id.suit == Suit.clubs) {
        score += 3.0;
      }
    }
    
    return score;
  }

  // Score a place move
  double _scorePlace(Move move, GameState gameState) {
    double score = 1.0; // Base score for placing
    
    // Penalty for placing high-value cards that could be used for captures
    if (move.card.value >= 10) {
      score -= 2.0;
    }
    
    // Penalty for placing cards that create sum opportunities for opponent
    score -= _calculateSumOpportunities(move.card, gameState) * 0.5;
    
    return score;
  }

  // Score capturing special cards (2♣ and 10♦)
  double _scoreSpecialCards(Move move, GameState gameState) {
    double score = 0.0;
    
    if (move.type == MoveType.place) return score;
    
    final capturedCards = gameState.table.getCardsAtIndices(move.tableIndices);
    
    for (final card in capturedCards) {
      if (card.id.rank == Rank.two && card.id.suit == Suit.clubs) {
        score += 20.0; // 2♣ is very valuable
      }
      if (card.id.rank == Rank.ten && card.id.suit == Suit.diamonds) {
        score += 20.0; // 10♦ is very valuable
      }
    }
    
    return score;
  }

  // Score capturing clubs
  double _scoreClubsCapture(Move move, GameState gameState) {
    if (move.type == MoveType.place) return 0.0;
    
    final capturedCards = gameState.table.getCardsAtIndices(move.tableIndices);
    int clubsCaptured = 0;
    
    for (final card in capturedCards) {
      if (card.id.suit == Suit.clubs) {
        clubsCaptured++;
      }
    }
    
    // Bonus for capturing clubs (helps with clubs majority)
    return clubsCaptured * 3.0;
  }

  // Score for card majority
  double _scoreCardMajority(Move move, GameState gameState) {
    if (move.type == MoveType.place) return 0.0;
    
    final currentPlayer = gameState.currentPlayer;
    final capturedCards = gameState.table.getCardsAtIndices(move.tableIndices);
    
    // Calculate new total cards if this move is made
    final newTotalCards = currentPlayer.totalCards + capturedCards.length + 1; // +1 for the played card
    
    // Bonus for increasing card lead
    int maxOtherCards = 0;
    for (final player in gameState.players) {
      if (player.id != currentPlayer.id) {
        maxOtherCards = maxOtherCards < player.totalCards ? player.totalCards : maxOtherCards;
      }
    }
    
    if (newTotalCards > maxOtherCards) {
      return 5.0; // Bonus for taking the lead
    }
    
    return 0.0;
  }

  // Score opponent opportunities (penalty)
  double _scoreOpponentOpportunities(Move move, GameState gameState) {
    if (move.type == MoveType.place) {
      // Calculate how many sum opportunities this creates for opponents
      return _calculateSumOpportunities(move.card, gameState) * 2.0;
    }
    
    return 0.0;
  }

  // Calculate how many sum opportunities a card creates
  double _calculateSumOpportunities(PlayingCard card, GameState gameState) {
    double opportunities = 0.0;
    
    // Check how many cards on table could sum to this card's value
    final tableValues = gameState.table.faceUp.map((c) => c.value).toList();
    
    // Simple heuristic: count cards that could be part of a sum
    for (final value in tableValues) {
      if (value <= card.value) {
        opportunities += 1.0;
      }
    }
    
    return opportunities;
  }

  // Get a simple move (for testing or fallback)
  Move getSimpleMove(GameState gameState) {
    final validMoves = gameState.getValidMoves();
    if (validMoves.isEmpty) {
      throw StateError('No valid moves available');
    }
    
    // Prefer captures over placing
    final captures = validMoves.where((move) => move.type != MoveType.place).toList();
    if (captures.isNotEmpty) {
      return captures.first;
    }
    
    return validMoves.first;
  }
}
