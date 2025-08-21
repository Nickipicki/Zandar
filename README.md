# Žandar - Traditional Balkan Card Game

A Flutter implementation of the traditional Balkan fishing-style card game Žandar (also known as Žendar or Đžendar). This mobile game features beautiful card animations, AI opponents, and support for both 2-player and 4-player partnership modes.

## Features

- **Traditional Gameplay**: Authentic implementation of the Balkan card game rules
- **Multiple Game Modes**: Solo vs AI, 2-player, and 4-player partnership modes
- **Configurable Rules**: Customizable house rules including sum capture and Jack sweep options
- **Beautiful UI**: Premium felt table design with smooth animations
- **AI Opponents**: Intelligent computer players with strategic decision-making
- **Scoring System**: Complete scoring with special card bonuses (2♣ and 10♦)
- **Responsive Design**: Optimized for both iOS and Android

## Game Rules

### Objective
Be the first to reach the target score (11 or 21 points) by capturing cards from the table.

### Card Values
- Ace = 1 or 11, Jack = 11, Queen = 12, King = 13
- Number cards = face value (2-10)

### Capturing Methods
1. **Match**: Play a card of the same rank as a table card
2. **Sum**: Play a card equal to the sum of multiple table cards
3. **Jack Sweep**: Jacks capture all cards from the table

### Scoring (per deal)
- **+2 points**: Most total cards captured
- **+1 point**: Most clubs (♣) captured
- **+1 point**: Captured 2♣ (little two)
- **+1 point**: Captured 10♦ (big ten)

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- iOS development tools (for iOS builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Nickipicki/Zandar.git
   cd Zandar
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Setup (Optional)

For multiplayer features, set up Firebase:

1. **Install FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase**
   ```bash
   flutterfire configure
   ```

3. **Update firebase_options.dart** with your project credentials

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget
├── firebase_options.dart     # Firebase configuration
├── theme/                    # UI theme and styling
│   ├── colors.dart
│   └── typography.dart
└── features/
    └── game/                 # Game feature
        ├── data/             # Data layer
        │   ├── models/       # Game models
        │   └── services/     # Data services
        ├── domain/           # Business logic
        │   └── engine/       # Game engine
        └── presentation/     # UI layer
            ├── screens/      # Game screens
            └── widgets/      # Reusable widgets
```

## Key Components

### Data Models
- `PlayingCard`: Individual card representation
- `PlayerState`: Player information and game state
- `GameState`: Complete game state management
- `Rules`: Configurable game rules
- `TableState`: Table cards and capture logic

### Game Engine
- `TurnEngine`: Turn management and game flow
- `AIBot`: Intelligent computer player logic
- `Deck`: Card deck management and dealing

### UI Components
- `CardView`: Individual card display
- `TableGrid`: Table card layout
- `HandView`: Player hand interface
- `ScoreRibbon`: Score display and progress

## Customization

### Adding New Rules
1. Extend the `Rules` class with new properties
2. Update the game engine logic in `TurnEngine`
3. Add UI controls in `RulesSelector`

### Modifying AI Behavior
1. Edit the scoring functions in `AIBot`
2. Adjust weights for different move types
3. Add new strategic considerations

### UI Theming
1. Update colors in `ZandarColors`
2. Modify typography in `ZandarTypography`
3. Customize card designs in `CardView`

## Building for Release
coming
### Android
```bash
flutter build apk --release
```
coming
### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


---

**Note**: This is a work in progress. Some features like multiplayer and advanced animations are planned for future releases.
