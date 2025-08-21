import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../data/models/game_state.dart';
import '../widgets/card_view.dart';
import 'lobby_screen.dart';

class ResultsScreen extends ConsumerWidget {
  final GameState gameState;
  final bool isPartnership;

  const ResultsScreen({
    super.key,
    required this.gameState,
    required this.isPartnership,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winner = _getWinner();
    final isPlayerWin = winner?.isHuman ?? false;

    return Scaffold(
      backgroundColor: ZandarColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                isPlayerWin ? 'Victory!' : 'Game Over',
                style: ZandarTypography.displayMedium.copyWith(
                  color: isPlayerWin ? ZandarColors.scorePositive : ZandarColors.scoreNegative,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                winner != null ? '${winner.displayName} wins!' : 'It\'s a tie!',
                style: ZandarTypography.titleLarge.copyWith(
                  color: ZandarColors.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Final Scores
              _buildFinalScores(),
              const SizedBox(height: 24),

              // Statistics
              _buildStatistics(),
              const SizedBox(height: 32),

              // Action Buttons
              ElevatedButton(
                onPressed: () => _playAgain(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZandarColors.accent,
                  foregroundColor: ZandarColors.onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Play Again',
                  style: ZandarTypography.buttonText.copyWith(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _backToLobby(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ZandarColors.primary,
                  side: BorderSide(color: ZandarColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Lobby',
                  style: ZandarTypography.buttonText.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalScores() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZandarColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ZandarColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Final Scores',
            style: ZandarTypography.headlineSmall.copyWith(
              color: ZandarColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          if (isPartnership)
            _buildPartnershipScores()
          else
            _buildIndividualScores(),
        ],
      ),
    );
  }

  Widget _buildIndividualScores() {
    return Column(
      children: gameState.players.map((player) {
        final score = gameState.score[player.id] ?? 0;
        final isWinner = score >= gameState.rules.targetScore;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    player.isHuman ? Icons.person : Icons.computer,
                    color: isWinner ? ZandarColors.scorePositive : ZandarColors.onSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    player.displayName,
                    style: ZandarTypography.titleMedium.copyWith(
                      color: isWinner ? ZandarColors.scorePositive : ZandarColors.onSurface,
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Text(
                '$score',
                style: ZandarTypography.scoreLarge.copyWith(
                  color: isWinner ? ZandarColors.scorePositive : ZandarColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPartnershipScores() {
    final team1Players = [gameState.players[0], gameState.players[2]];
    final team2Players = [gameState.players[1], gameState.players[3]];
    
    final team1Score = team1Players.fold<int>(0, (sum, player) => sum + (gameState.score[player.id] ?? 0));
    final team2Score = team2Players.fold<int>(0, (sum, player) => sum + (gameState.score[player.id] ?? 0));
    
    final team1Wins = team1Score >= gameState.rules.targetScore;
    final team2Wins = team2Score >= gameState.rules.targetScore;

    return Column(
      children: [
        _buildTeamScore('Team N-S', team1Score, team1Wins, true),
        const SizedBox(height: 12),
        _buildTeamScore('Team E-W', team2Score, team2Wins, false),
      ],
    );
  }

  Widget _buildTeamScore(String teamName, int score, bool isWinner, bool isHumanTeam) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isHumanTeam ? Icons.group : Icons.computer,
              color: isWinner ? ZandarColors.scorePositive : ZandarColors.onSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              teamName,
              style: ZandarTypography.titleMedium.copyWith(
                color: isWinner ? ZandarColors.scorePositive : ZandarColors.onSurface,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        Text(
          '$score',
          style: ZandarTypography.scoreLarge.copyWith(
            color: isWinner ? ZandarColors.scorePositive : ZandarColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZandarColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ZandarColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Statistics',
            style: ZandarTypography.headlineSmall.copyWith(
              color: ZandarColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Most cards captured
          _buildStatRow(
            'Most Cards',
            _getPlayerWithMostCards()?.displayName ?? 'Tie',
            Icons.style,
          ),
          
          // Most clubs captured
          _buildStatRow(
            'Most Clubs',
            _getPlayerWithMostClubs()?.displayName ?? 'Tie',
            Icons.favorite,
          ),
          
          // Special cards
          _buildStatRow(
            '2♣ Captured',
            _getPlayerWithTwoOfClubs()?.displayName ?? 'None',
            Icons.star,
          ),
          
          _buildStatRow(
            '10♦ Captured',
            _getPlayerWithTenOfDiamonds()?.displayName ?? 'None',
            Icons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: ZandarColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: ZandarTypography.bodyMedium.copyWith(
                  color: ZandarColors.onSurface,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: ZandarTypography.bodyMedium.copyWith(
              color: ZandarColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PlayerState? _getWinner() {
    for (final player in gameState.players) {
      final score = gameState.score[player.id] ?? 0;
      if (score >= gameState.rules.targetScore) {
        return player;
      }
    }
    return null;
  }

  PlayerState? _getPlayerWithMostCards() {
    PlayerState? maxPlayer;
    int maxCards = 0;
    
    for (final player in gameState.players) {
      if (player.totalCards > maxCards) {
        maxCards = player.totalCards;
        maxPlayer = player;
      } else if (player.totalCards == maxCards) {
        maxPlayer = null; // Tie
      }
    }
    
    return maxPlayer;
  }

  PlayerState? _getPlayerWithMostClubs() {
    PlayerState? maxPlayer;
    int maxClubs = 0;
    
    for (final player in gameState.players) {
      if (player.clubsCount > maxClubs) {
        maxClubs = player.clubsCount;
        maxPlayer = player;
      } else if (player.clubsCount == maxClubs) {
        maxPlayer = null; // Tie
      }
    }
    
    return maxPlayer;
  }

  PlayerState? _getPlayerWithTwoOfClubs() {
    for (final player in gameState.players) {
      if (player.hasTwoOfClubs) {
        return player;
      }
    }
    return null;
  }

  PlayerState? _getPlayerWithTenOfDiamonds() {
    for (final player in gameState.players) {
      if (player.hasTenOfDiamonds) {
        return player;
      }
    }
    return null;
  }

  void _playAgain(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TableScreen(
          rules: gameState.rules,
          isPartnership: isPartnership,
        ),
      ),
    );
  }

  void _backToLobby(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LobbyScreen(),
      ),
      (route) => false,
    );
  }
}
