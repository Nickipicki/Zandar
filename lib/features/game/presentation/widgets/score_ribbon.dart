import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/typography.dart';
import '../../data/models/game_state.dart';

class ScoreRibbon extends StatelessWidget {
  final GameState gameState;
  final bool isPartnership;

  const ScoreRibbon({
    super.key,
    required this.gameState,
    required this.isPartnership,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZandarColors.primary.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: ZandarColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Target score
          Text(
            'Target: ${gameState.rules.targetScore}',
            style: ZandarTypography.textTheme.titleMedium!.copyWith(
              color: ZandarColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Score display
          if (isPartnership)
            _buildPartnershipScores()
          else
            _buildIndividualScores(),

          // Current turn indicator
          const SizedBox(height: 8),
          _buildTurnIndicator(),
        ],
      ),
    );
  }

  Widget _buildIndividualScores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: gameState.players.map((player) {
        final score = gameState.score[player.id] ?? 0;
        final isCurrentTurn = gameState.currentTurnIndex == gameState.players.indexOf(player);
        
        return _buildScoreCard(
          player.displayName,
          score,
          gameState.rules.targetScore,
          isCurrentTurn,
          player.isHuman,
        );
      }).toList(),
    );
  }

  Widget _buildPartnershipScores() {
    // Group players into teams
    final team1Players = [gameState.players[0], gameState.players[2]]; // N-S
    final team2Players = [gameState.players[1], gameState.players[3]]; // E-W
    
    final team1Score = team1Players.fold<int>(0, (sum, player) => sum + (gameState.score[player.id] ?? 0));
    final team2Score = team2Players.fold<int>(0, (sum, player) => sum + (gameState.score[player.id] ?? 0));
    
    final isTeam1Turn = team1Players.any((player) => 
      gameState.currentTurnIndex == gameState.players.indexOf(player));
    final isTeam2Turn = team2Players.any((player) => 
      gameState.currentTurnIndex == gameState.players.indexOf(player));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreCard(
          'Team N-S',
          team1Score,
          gameState.rules.targetScore,
          isTeam1Turn,
          true, // Team 1 includes human player
        ),
        _buildScoreCard(
          'Team E-W',
          team2Score,
          gameState.rules.targetScore,
          isTeam2Turn,
          false,
        ),
      ],
    );
  }

  Widget _buildScoreCard(String name, int score, int targetScore, bool isCurrentTurn, bool isHuman) {
    final progress = score / targetScore;
    final isWinning = score >= targetScore;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentTurn 
          ? ZandarColors.accent.withOpacity(0.3)
          : ZandarColors.onPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentTurn ? ZandarColors.accent : ZandarColors.onPrimary.withOpacity(0.3),
          width: isCurrentTurn ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: ZandarTypography.textTheme.bodySmall!.copyWith(
              color: ZandarColors.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: ZandarTypography.scoreMedium.copyWith(
              color: isWinning ? ZandarColors.scorePositive : ZandarColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Progress bar
          SizedBox(
            width: 60,
            height: 4,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: ZandarColors.onPrimary.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                isWinning ? ZandarColors.scorePositive : ZandarColors.accent,
              ),
            ),
          ),
          if (isCurrentTurn) ...[
            const SizedBox(height: 4),
            Icon(
              Icons.play_arrow,
              color: ZandarColors.accent,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTurnIndicator() {
    final currentPlayer = gameState.currentPlayer;
    final isHumanTurn = currentPlayer.isHuman;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHumanTurn 
          ? ZandarColors.validMove.withOpacity(0.2)
          : ZandarColors.scoreNeutral.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHumanTurn ? ZandarColors.validMove : ZandarColors.scoreNeutral,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHumanTurn ? Icons.person : Icons.computer,
            color: isHumanTurn ? ZandarColors.validMove : ZandarColors.scoreNeutral,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isHumanTurn ? 'Your turn' : '${currentPlayer.displayName}\'s turn',
            style: ZandarTypography.textTheme.bodySmall!.copyWith(
              color: isHumanTurn ? ZandarColors.validMove : ZandarColors.scoreNeutral,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
