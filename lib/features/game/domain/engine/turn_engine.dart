import 'dart:math';
import '../../data/models/game_state.dart';
import '../../data/models/deck.dart';
import '../../data/models/rules.dart';
import '../../data/models/player.dart';
import '../../data/models/table_state.dart';
import 'ai_bot.dart';

class TurnEngine {
  final Random _random = Random();
  final AIBot _aiBot = AIBot();

  // Create a new game
  GameState createGame({
    required List<PlayerState> players,
    required Rules rules,
    int? seed,
  }) {
    final gameId = _generateGameId();
    final gameSeed = seed ?? _random.nextInt(1000000);
    
    // Create and shuffle deck
    final deck = Deck.standard(seed: gameSeed);
    deck.shuffle();
    
    // Deal initial table cards (replacing Jacks)
    final tableCards = deck.dealTableCards(rules.initialTableCards);
    final table = TableState(faceUp: tableCards);
    
    // Deal cards to players
    final playerStates = <PlayerState>[];
    for (final player in players) {
      final hand = deck.deal(rules.cardsPerDeal);
      playerStates.add(player.copyWith(hand: hand, captures: []));
    }
    
    // Initialize scores
    final score = <String, int>{};
    for (final player in players) {
      score[player.id] = 0;
    }
    
    return GameState(
      id: gameId,
      players: playerStates,
      table: table,
      stock: deck.cards,
      currentTurnIndex: 0,
      rules: rules,
      score: score,
      phase: GamePhase.playing,
      turnNonce: 0,
      seed: gameSeed,
    );
  }

  // Process a turn (human or AI)
  GameState processTurn(GameState gameState, Move? move) {
    if (gameState.isGameOver) {
      return gameState;
    }

    final currentPlayer = gameState.currentPlayer;
    
    // If it's an AI player, generate move
    if (!currentPlayer.isHuman) {
      move = _aiBot.generateMove(gameState);
    }
    
    // Validate move
    if (move == null || !gameState.isValidMove(move)) {
      throw ArgumentError('Invalid move: $move');
    }
    
    // Apply move
    return gameState.applyMove(move);
  }

  // Start a new deal (after scoring)
  GameState startNewDeal(GameState gameState) {
    if (gameState.phase != GamePhase.scoring) {
      throw StateError('Cannot start new deal: game is not in scoring phase');
    }
    
    final gameSeed = gameState.seed ?? _random.nextInt(1000000);
    final deck = Deck.standard(seed: gameSeed);
    deck.shuffle();
    
    // Deal initial table cards
    final tableCards = deck.dealTableCards(gameState.rules.initialTableCards);
    final table = TableState(faceUp: tableCards);
    
    // Deal cards to players
    final playerStates = <PlayerState>[];
    for (final player in gameState.players) {
      final hand = deck.deal(gameState.rules.cardsPerDeal);
      playerStates.add(player.copyWith(hand: hand, captures: []));
    }
    
    return gameState.copyWith(
      players: playerStates,
      table: table,
      stock: deck.cards,
      currentTurnIndex: 0,
      phase: GamePhase.playing,
      lastDealScore: null,
      turnNonce: gameState.turnNonce + 1,
    );
  }

  // Get valid moves for a specific card
  List<List<int>> getValidCaptures(GameState gameState, PlayingCard card) {
    return gameState.table.getCaptureCombinations(card);
  }

  // Check if a specific capture is valid
  bool isValidCapture(GameState gameState, PlayingCard card, List<int> tableIndices) {
    final combinations = gameState.table.getCaptureCombinations(card);
    return combinations.any((combo) => 
      combo.length == tableIndices.length && 
      combo.every((index) => tableIndices.contains(index))
    );
  }

  // Get the next player index
  int getNextPlayerIndex(GameState gameState) {
    return (gameState.currentTurnIndex + 1) % gameState.players.length;
  }

  // Check if the current player can make any captures
  bool canCurrentPlayerCapture(GameState gameState) {
    return gameState.canCapture;
  }

  // Get all possible moves for the current player
  List<Move> getCurrentPlayerMoves(GameState gameState) {
    return gameState.getValidMoves();
  }

  // Generate a unique game ID
  String _generateGameId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(10000);
    return 'game_${timestamp}_$random';
  }

  // Validate game state consistency
  bool validateGameState(GameState gameState) {
    // Check that total cards in game equals 52
    int totalCards = gameState.table.faceUp.length + gameState.stock.length;
    for (final player in gameState.players) {
      totalCards += player.hand.length + player.captures.length;
    }
    
    if (totalCards != 52) {
      return false;
    }
    
    // Check that current turn index is valid
    if (gameState.currentTurnIndex < 0 || 
        gameState.currentTurnIndex >= gameState.players.length) {
      return false;
    }
    
    // Check that scores are non-negative
    for (final score in gameState.score.values) {
      if (score < 0) return false;
    }
    
    return true;
  }
}
