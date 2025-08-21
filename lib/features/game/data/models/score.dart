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
    
    // Most total cards (+2 points)
    if (totalCardsWinner != null) {
      points[totalCardsWinner!] = (points[totalCardsWinner!] ?? 0) + 2;
    }
    
    // Most clubs (+1 point)
    if (mostClubsWinner != null) {
      points[mostClubsWinner!] = (points[mostClubsWinner!] ?? 0) + 1;
    }
    
    // 2♣ captured (+1 point)
    if (twoOfClubsWinner != null) {
      points[twoOfClubsWinner!] = (points[twoOfClubsWinner!] ?? 0) + 1;
    }
    
    // 10♦ captured (+1 point)
    if (tenOfDiamondsWinner != null) {
      points[tenOfDiamondsWinner!] = (points[tenOfDiamondsWinner!] ?? 0) + 1;
    }
    
    return points;
  }

  // Calculate deal score from player states
  static DealScore fromPlayerStates(List<PlayerState> players) {
    String? totalCardsWinner;
    String? mostClubsWinner;
    String? twoOfClubsWinner;
    String? tenOfDiamondsWinner;
    
    // Find player with most total cards
    int maxCards = 0;
    for (final player in players) {
      if (player.totalCards > maxCards) {
        maxCards = player.totalCards;
        totalCardsWinner = player.id;
      } else if (player.totalCards == maxCards) {
        // Tie - no points awarded
        totalCardsWinner = null;
      }
    }
    
    // Find player with most clubs
    int maxClubs = 0;
    for (final player in players) {
      if (player.clubsCount > maxClubs) {
        maxClubs = player.clubsCount;
        mostClubsWinner = player.id;
      } else if (player.clubsCount == maxClubs) {
        // Tie - no points awarded
        mostClubsWinner = null;
      }
    }
    
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
