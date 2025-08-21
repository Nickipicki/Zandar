import 'package:json_annotation/json_annotation.dart';
import 'card.dart';
import 'player.dart';
import 'table_state.dart';
import 'rules.dart';
import 'score.dart';

part 'game_state.g.dart';

enum GamePhase {
  @JsonValue('waiting')
  waiting,
  @JsonValue('dealing')
  dealing,
  @JsonValue('playing')
  playing,
  @JsonValue('scoring')
  scoring,
  @JsonValue('finished')
  finished,
}

enum MoveType {
  @JsonValue('place')
  place,
  @JsonValue('match')
  match,
  @JsonValue('sum')
  sum,
  @JsonValue('jack_sweep')
  jackSweep,
}

@JsonSerializable()
class Move {
  final MoveType type;
  final PlayingCard card;
  final List<int> tableIndices;

  const Move({
    required this.type,
    required this.card,
    required this.tableIndices,
  });

  factory Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);
  Map<String, dynamic> toJson() => _$MoveToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Move &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          card == other.card &&
          tableIndices == other.tableIndices;

  @override
  int get hashCode => type.hashCode ^ card.hashCode ^ tableIndices.hashCode;

  @override
  String toString() => 'Move(type: $type, card: $card, indices: $tableIndices)';
}

@JsonSerializable()
class GameState {
  final String id;
  final List<PlayerState> players;
  final TableState table;
  final List<PlayingCard> stock;
  final int currentTurnIndex;
  final Rules rules;
  final Map<String, int> score;
  final GamePhase phase;
  final int turnNonce;
  final DealScore? lastDealScore;
  final String? winner;
  final int? seed;

  const GameState({
    required this.id,
    required this.players,
    required this.table,
    required this.stock,
    required this.currentTurnIndex,
    required this.rules,
    required this.score,
    required this.phase,
    required this.turnNonce,
    this.lastDealScore,
    this.winner,
    this.seed,
  });

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  GameState copyWith({
    String? id,
    List<PlayerState>? players,
    TableState? table,
    List<PlayingCard>? stock,
    int? currentTurnIndex,
    Rules? rules,
    Map<String, int>? score,
    GamePhase? phase,
    int? turnNonce,
    DealScore? lastDealScore,
    String? winner,
    int? seed,
  }) {
    return GameState(
      id: id ?? this.id,
      players: players ?? this.players,
      table: table ?? this.table,
      stock: stock ?? this.stock,
      currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex,
      rules: rules ?? this.rules,
      score: score ?? this.score,
      phase: phase ?? this.phase,
      turnNonce: turnNonce ?? this.turnNonce,
      lastDealScore: lastDealScore ?? this.lastDealScore,
      winner: winner ?? this.winner,
      seed: seed ?? this.seed,
    );
  }

  // Get current player
  PlayerState get currentPlayer => players[currentTurnIndex];

  // Check if it's a human player's turn
  bool get isHumanTurn => currentPlayer.isHuman;

  // Check if game is over
  bool get isGameOver => phase == GamePhase.finished || winner != null;

  // Check if current player can make any captures
  bool get canCapture {
    final player = currentPlayer;
    for (final card in player.hand) {
      if (table.getCaptureCombinations(card).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // Get all valid moves for current player
  List<Move> getValidMoves() {
    final moves = <Move>[];
    final player = currentPlayer;

    for (final card in player.hand) {
      final combinations = table.getCaptureCombinations(card);
      
      if (combinations.isNotEmpty) {
        // Add capture moves
        for (final combo in combinations) {
          if (card.isJack && rules.jackSweepsAll) {
            moves.add(Move(
              type: MoveType.jackSweep,
              card: card,
              tableIndices: combo,
            ));
          } else if (combo.length == 1) {
            moves.add(Move(
              type: MoveType.match,
              card: card,
              tableIndices: combo,
            ));
          } else if (rules.allowSumCapture) {
            moves.add(Move(
              type: MoveType.sum,
              card: card,
              tableIndices: combo,
            ));
          }
        }
      }
      
      // Always add place move as an option
      moves.add(Move(
        type: MoveType.place,
        card: card,
        tableIndices: [],
      ));
    }

    return moves;
  }

  // Check if a move is valid
  bool isValidMove(Move move) {
    final validMoves = getValidMoves();
    
    // Debug output
    print('Checking move: $move');
    print('Valid moves count: ${validMoves.length}');
    for (final validMove in validMoves) {
      print('  Valid move: $validMove');
    }
    
    return validMoves.any((validMove) => 
      validMove.type == move.type &&
      validMove.card == move.card &&
      validMove.tableIndices.length == move.tableIndices.length &&
      validMove.tableIndices.every((index) => move.tableIndices.contains(index))
    );
  }

  // Apply a move and return new game state
  GameState applyMove(Move move) {
    if (!isValidMove(move)) {
      throw ArgumentError('Invalid move: $move');
    }

    final newPlayers = List<PlayerState>.from(players);
    final currentPlayerIndex = currentTurnIndex;
    final currentPlayer = newPlayers[currentPlayerIndex];
    final newStock = List<PlayingCard>.from(stock);

    // Remove card from hand
    final newHand = List<PlayingCard>.from(currentPlayer.hand);
    newHand.remove(move.card);

    // Handle capture or place
    List<PlayingCard> newCaptures = List<PlayingCard>.from(currentPlayer.captures);
    TableState newTable = table;

    switch (move.type) {
      case MoveType.place:
        newTable = table.addCard(move.card);
        break;
      case MoveType.match:
      case MoveType.sum:
        newCaptures.add(move.card);
        final capturedCards = table.getCardsAtIndices(move.tableIndices);
        newCaptures.addAll(capturedCards);
        newTable = table.removeCards(move.tableIndices);
        break;
      case MoveType.jackSweep:
        newCaptures.add(move.card);
        newCaptures.addAll(table.faceUp);
        newTable = table.clear();
        break;
    }

    // Update player state
    newPlayers[currentPlayerIndex] = currentPlayer.copyWith(
      hand: newHand,
      captures: newCaptures,
    );

    // Check if deal is over (all hands empty)
    final isDealOver = newPlayers.every((player) => player.hand.isEmpty);

    if (isDealOver) {
      // Last capture takes remaining table cards
      if (newTable.faceUp.isNotEmpty) {
        final lastPlayer = newPlayers[currentPlayerIndex];
        final finalCaptures = List<PlayingCard>.from(lastPlayer.captures);
        finalCaptures.addAll(newTable.faceUp);
        newPlayers[currentPlayerIndex] = lastPlayer.copyWith(
          captures: finalCaptures,
        );
        newTable = newTable.clear();
      }

      // Calculate deal score
      final dealScore = DealScore.fromPlayerStates(newPlayers);
      final dealPoints = dealScore.calculatePoints();
      
      // Update total scores
      final newScore = Map<String, int>.from(score);
      for (final entry in dealPoints.entries) {
        newScore[entry.key] = (newScore[entry.key] ?? 0) + entry.value;
      }

      // Check for winner
      String? newWinner;
      for (final entry in newScore.entries) {
        if (entry.value >= rules.targetScore) {
          newWinner = entry.key;
          break;
        }
      }

      // Check if game is over (stock empty or winner found)
      if (newStock.isEmpty || newWinner != null) {
        return copyWith(
          players: newPlayers,
          table: newTable,
          phase: newWinner != null ? GamePhase.finished : GamePhase.scoring,
          lastDealScore: dealScore,
          score: newScore,
          winner: newWinner,
          turnNonce: turnNonce + 1,
        );
      } else {
        // Deal more cards
        return _dealMoreCards(newPlayers, newTable, newStock);
      }
    } else {
      // Continue to next player
      final nextTurnIndex = (currentTurnIndex + 1) % players.length;
      return copyWith(
        players: newPlayers,
        table: newTable,
        currentTurnIndex: nextTurnIndex,
        turnNonce: turnNonce + 1,
      );
    }
  }

  // Deal more cards to players
  GameState _dealMoreCards(List<PlayerState> players, TableState table, List<PlayingCard> currentStock) {
    final newPlayers = <PlayerState>[];
    final newStock = List<PlayingCard>.from(currentStock);
    
    for (final player in players) {
      final cardsToDeal = rules.cardsPerDeal;
      final newHand = List<PlayingCard>.from(player.hand);
      
      for (int i = 0; i < cardsToDeal && newStock.isNotEmpty; i++) {
        newHand.add(newStock.removeAt(0));
      }
      
      newPlayers.add(player.copyWith(hand: newHand));
    }

    return copyWith(
      players: newPlayers,
      table: table,
      stock: newStock,
      currentTurnIndex: currentTurnIndex,
      turnNonce: turnNonce + 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameState &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          players == other.players &&
          table == other.table &&
          stock == other.stock &&
          currentTurnIndex == other.currentTurnIndex &&
          rules == other.rules &&
          score == other.score &&
          phase == other.phase &&
          turnNonce == other.turnNonce;

  @override
  int get hashCode =>
      id.hashCode ^
      players.hashCode ^
      table.hashCode ^
      stock.hashCode ^
      currentTurnIndex.hashCode ^
      rules.hashCode ^
      score.hashCode ^
      phase.hashCode ^
      turnNonce.hashCode;

  @override
  String toString() => 'GameState(id: $id, phase: $phase, turn: $currentTurnIndex)';
}
