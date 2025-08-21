import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/typography.dart';
import '../../data/models/rules.dart';
import '../../data/models/player.dart';
import '../../data/models/game_state.dart';
import '../../data/models/card.dart';
import '../../data/models/table_state.dart';
import '../../domain/engine/turn_engine.dart';
import '../widgets/card_view.dart';
import '../widgets/hand_view.dart';
import '../widgets/table_grid.dart';
import '../widgets/score_ribbon.dart';
import '../widgets/player_badge.dart';
import 'results_screen.dart';

class TableScreen extends ConsumerStatefulWidget {
  final Rules rules;
  final bool isPartnership;

  const TableScreen({
    super.key,
    required this.rules,
    required this.isPartnership,
  });

  @override
  ConsumerState<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends ConsumerState<TableScreen> {
  late GameState _gameState;
  late TurnEngine _turnEngine;
  PlayingCard? _selectedCard;
  List<int> _selectedTableIndices = [];
  bool _isProcessingTurn = false;

  @override
  void initState() {
    super.initState();
    _turnEngine = TurnEngine();
    _initializeGame();
  }

  void _initializeGame() {
    final players = _createPlayers();
    _gameState = _turnEngine.createGame(
      players: players,
      rules: widget.rules,
    );
  }

  List<PlayerState> _createPlayers() {
    if (widget.isPartnership) {
      return [
        PlayerState(
          id: 'player1',
          hand: [],
          captures: [],
          isHuman: true,
          name: 'You',
        ),
        PlayerState(
          id: 'player2',
          hand: [],
          captures: [],
          isHuman: false,
          name: 'AI 1',
        ),
        PlayerState(
          id: 'player3',
          hand: [],
          captures: [],
          isHuman: false,
          name: 'AI 2',
        ),
        PlayerState(
          id: 'player4',
          hand: [],
          captures: [],
          isHuman: false,
          name: 'AI 3',
        ),
      ];
    } else {
      return [
        PlayerState(
          id: 'player1',
          hand: [],
          captures: [],
          isHuman: true,
          name: 'You',
        ),
        PlayerState(
          id: 'player2',
          hand: [],
          captures: [],
          isHuman: false,
          name: 'AI',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZandarColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Score Ribbon
            ScoreRibbon(
              gameState: _gameState,
              isPartnership: widget.isPartnership,
            ),
            
            // Main Game Area
            Expanded(
              child: Stack(
                children: [
                  // Table Grid
                  Center(
                    child: TableGrid(
                      tableState: _gameState.table,
                      selectedIndices: _selectedTableIndices,
                      onCardTap: _onTableCardTap,
                    ),
                  ),
                  
                  // Player Badges
                  _buildPlayerBadges(),
                ],
              ),
            ),
            
            // Player Hand
            HandView(
              hand: _gameState.currentPlayer.hand,
              selectedCard: _selectedCard,
              onCardTap: _onHandCardTap,
              onCardPlay: _onCardPlay,
              isValidMove: _selectedCard != null && _canMakeMove(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerBadges() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top players (for 4-player mode)
            if (widget.isPartnership) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PlayerBadge(
                    player: _gameState.players[1],
                    isCurrentTurn: _gameState.currentTurnIndex == 1,
                    position: 'top',
                  ),
                  PlayerBadge(
                    player: _gameState.players[3],
                    isCurrentTurn: _gameState.currentTurnIndex == 3,
                    position: 'top',
                  ),
                ],
              ),
              const Spacer(),
              // Side players
              Row(
                children: [
                  PlayerBadge(
                    player: _gameState.players[0],
                    isCurrentTurn: _gameState.currentTurnIndex == 0,
                    position: 'left',
                  ),
                  const Spacer(),
                  PlayerBadge(
                    player: _gameState.players[2],
                    isCurrentTurn: _gameState.currentTurnIndex == 2,
                    position: 'right',
                  ),
                ],
              ),
            ] else ...[
              // 2-player mode
              const Spacer(),
              Row(
                children: [
                  PlayerBadge(
                    player: _gameState.players[0],
                    isCurrentTurn: _gameState.currentTurnIndex == 0,
                    position: 'left',
                  ),
                  const Spacer(),
                  PlayerBadge(
                    player: _gameState.players[1],
                    isCurrentTurn: _gameState.currentTurnIndex == 1,
                    position: 'right',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onHandCardTap(PlayingCard card) {
    setState(() {
      _selectedCard = card;
      _selectedTableIndices.clear();
    });
  }

  void _onTableCardTap(int index) {
    if (_selectedCard == null) return;

    setState(() {
      if (_selectedTableIndices.contains(index)) {
        _selectedTableIndices.remove(index);
      } else {
        _selectedTableIndices.add(index);
      }
    });
  }

  bool _canMakeMove() {
    if (_selectedCard == null) return false;
    
    if (_selectedTableIndices.isEmpty) {
      // Can always place a card
      return true;
    }
    
    // Check if the selected combination is valid
    return _turnEngine.isValidCapture(_gameState, _selectedCard!, _selectedTableIndices);
  }

  void _onCardPlay() async {
    if (!_canMakeMove() || _isProcessingTurn) return;

    setState(() {
      _isProcessingTurn = true;
    });

    try {
      // Create the move
      final move = _createMove();
      
      // Apply the move
      final newGameState = _gameState.applyMove(move);
      
      setState(() {
        _gameState = newGameState;
        _selectedCard = null;
        _selectedTableIndices.clear();
      });

      // Process AI turns
      await _processAITurns();

      // Check if game is over
      if (_gameState.isGameOver) {
        _showGameOver();
      } else if (_gameState.phase == GamePhase.scoring) {
        _showDealResults();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid move: $e')),
      );
    } finally {
      setState(() {
        _isProcessingTurn = false;
      });
    }
  }

  Move _createMove() {
    if (_selectedCard == null) {
      throw ArgumentError('No card selected');
    }

    if (_selectedTableIndices.isEmpty) {
      return Move(
        type: MoveType.place,
        card: _selectedCard!,
        tableIndices: [],
      );
    }

    // Determine move type
    MoveType moveType;
    if (_selectedCard!.isJack && widget.rules.jackSweepsAll) {
      moveType = MoveType.jackSweep;
    } else if (_selectedTableIndices.length == 1) {
      moveType = MoveType.match;
    } else {
      moveType = MoveType.sum;
    }

    return Move(
      type: moveType,
      card: _selectedCard!,
      tableIndices: _selectedTableIndices,
    );
  }

  Future<void> _processAITurns() async {
    while (_gameState.currentPlayer.isHuman == false && 
           !_gameState.isGameOver && 
           _gameState.phase != GamePhase.scoring) {
      
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final move = _turnEngine.processTurn(_gameState, null);
      setState(() {
        _gameState = move;
      });
    }
  }

  void _showDealResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Deal Complete!',
          style: ZandarTypography.textTheme.headlineSmall!,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Deal Score:',
              style: ZandarTypography.textTheme.titleMedium!,
            ),
            const SizedBox(height: 16),
            ..._gameState.players.map((player) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(player.displayName),
                  Text('${player.totalCards} cards'),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewDeal();
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showGameOver() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          gameState: _gameState,
          isPartnership: widget.isPartnership,
        ),
      ),
    );
  }

  void _startNewDeal() {
    final newGameState = _turnEngine.startNewDeal(_gameState);
    setState(() {
      _gameState = newGameState;
    });
  }
}
