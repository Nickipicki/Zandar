import 'package:json_annotation/json_annotation.dart';
import 'player.dart';

part 'score.g.dart';

@JsonSerializable()
class DealScore {
  final String? totalCardsWinner; // player/team id
  final String? mostClubsWinner;
  final String? twoOfClubsWinner;
  final String? tenOfDiamondsWinner;

  const DealScore({
    this.totalCardsWinner,
    this.mostClubsWinner,
    this.twoOfClubsWinner,
    this.tenOfDiamondsWinner,
  });

  factory DealScore.fromJson(Map<String, dynamic> json) =>
      _$DealScoreFromJson(json);
  Map<String, dynamic> toJson() => _$DealScoreToJson(this);

  DealScore copyWith({
    String? totalCardsWinner,
    String? mostClubsWinner,
    String? twoOfClubsWinner,
    String? tenOfDiamondsWinner,
  }) {
    return DealScore(
      totalCardsWinner: totalCardsWinner ?? this.totalCardsWinner,
      mostClubsWinner: mostClubsWinner ?? this.mostClubsWinner,
      twoOfClubsWinner: twoOfClubsWinner ?? this.twoOfClubsWinner,
      tenOfDiamondsWinner: tenOfDiamondsWinner ?? this.tenOfDiamondsWinner,
    );
  }

  // Calculate points for each player/team
  Map<String, int> calculatePoints() {
    final points = <String, int>{};
    
    print('=== DEAL SCORE CALCULATION ===');
    print('Total cards winner: $totalCardsWinner');
    print('Most clubs winner: $mostClubsWinner');
    print('2♣ winner: $twoOfClubsWinner');
    print('10♦ winner: $tenOfDiamondsWinner');
    
    // Most total cards (+2 points)
    if (totalCardsWinner != null) {
      points[totalCardsWinner!] = (points[totalCardsWinner!] ?? 0) + 2;
      print('+2 points to $totalCardsWinner for most cards');
    }
    
    // Most clubs (+1 point)
    if (mostClubsWinner != null) {
      points[mostClubsWinner!] = (points[mostClubsWinner!] ?? 0) + 1;
      print('+1 point to $mostClubsWinner for most clubs');
    }
    
    // 2♣ captured (+1 point)
    if (twoOfClubsWinner != null) {
      points[twoOfClubsWinner!] = (points[twoOfClubsWinner!] ?? 0) + 1;
      print('+1 point to $twoOfClubsWinner for 2♣');
    }
    
    // 10♦ captured (+1 point)
    if (tenOfDiamondsWinner != null) {
      points[tenOfDiamondsWinner!] = (points[tenOfDiamondsWinner!] ?? 0) + 1;
      print('+1 point to $tenOfDiamondsWinner for 10♦');
    }
    
    print('Final points: $points');
    print('==============================');
    
    return points;
  }

  // Calculate deal score from player states
  static DealScore fromPlayerStates(List<PlayerState> players) {
    print('=== CALCULATING DEAL SCORE ===');
    for (final player in players) {
      print('${player.name}: ${player.totalCards} cards, ${player.clubsCount} clubs, has 2♣: ${player.hasTwoOfClubs}, has 10♦: ${player.hasTenOfDiamonds}');
    }
    
    String? totalCardsWinner;
    String? mostClubsWinner;
    String? twoOfClubsWinner;
    String? tenOfDiamondsWinner;
    
    // Find player with most total cards
    int maxCards = 0;
    String? tempTotalCardsWinner;
    for (final player in players) {
      if (player.totalCards > maxCards) {
        maxCards = player.totalCards;
        tempTotalCardsWinner = player.id;
      } else if (player.totalCards == maxCards) {
        // Tie - no points awarded
        tempTotalCardsWinner = null;
      }
    }
    totalCardsWinner = tempTotalCardsWinner;
    
    // Find player with most clubs
    int maxClubs = 0;
    String? tempMostClubsWinner;
    for (final player in players) {
      if (player.clubsCount > maxClubs) {
        maxClubs = player.clubsCount;
        tempMostClubsWinner = player.id;
      } else if (player.clubsCount == maxClubs) {
        // Tie - no points awarded
        tempMostClubsWinner = null;
      }
    }
    mostClubsWinner = tempMostClubsWinner;
    
    // Find who captured 2♣
    for (final player in players) {
      if (player.hasTwoOfClubs) {
        twoOfClubsWinner = player.id;
        break;
      }
    }
    
    // Find who captured 10♦
    for (final player in players) {
      if (player.hasTenOfDiamonds) {
        tenOfDiamondsWinner = player.id;
        break;
      }
    }
    
    return DealScore(
      totalCardsWinner: totalCardsWinner,
      mostClubsWinner: mostClubsWinner,
      twoOfClubsWinner: twoOfClubsWinner,
      tenOfDiamondsWinner: tenOfDiamondsWinner,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DealScore &&
          runtimeType == other.runtimeType &&
          totalCardsWinner == other.totalCardsWinner &&
          mostClubsWinner == other.mostClubsWinner &&
          twoOfClubsWinner == other.twoOfClubsWinner &&
          tenOfDiamondsWinner == other.tenOfDiamondsWinner;

  @override
  int get hashCode =>
      totalCardsWinner.hashCode ^
      mostClubsWinner.hashCode ^
      twoOfClubsWinner.hashCode ^
      tenOfDiamondsWinner.hashCode;

  @override
  String toString() => 'DealScore(totalCards: $totalCardsWinner, clubs: $mostClubsWinner, 2♣: $twoOfClubsWinner, 10♦: $tenOfDiamondsWinner)';
}
