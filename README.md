# Daily Tracker - Flutter App

A beautiful and functional daily workout and wellness tracking app built with Flutter.

## Features

### 🏋️ Workout Tracking
- **Push Ups**: Track daily push-up progress with 100 rep goal
- **Sit Ups**: Monitor sit-up achievements with 100 rep target  
- **Squats**: Follow squat progress with 100 rep objective
- **Water Intake**: Monitor daily water consumption (2000ml goal)

### 🎨 Design Features
- **Material 3 Design**: Modern, beautiful UI following latest design principles
- **Light/Dark Themes**: Automatic theme switching based on system preference
- **Responsive Layout**: Works perfectly on all screen sizes
- **Visual Feedback**: Progress bars, completion celebrations, and intuitive icons
- **Google Fonts**: Clean, readable typography using Inter font family

### 💾 Data Persistence
- **Local Storage**: All progress automatically saved using SharedPreferences
- **Daily Reset**: Fresh start each day with automatic date-based tracking
- **Progress History**: Maintains your daily achievements

### 🔧 Technical Features
- **State Management**: Clean architecture using Provider pattern
- **Responsive UI**: Adaptive layouts for different screen orientations
- **Performance Optimized**: Efficient state updates and minimal rebuilds

## Screenshots

The app features a clean dashboard with:
- Goals header with visual chips
- Overall progress overview
- Individual exercise tracking cards
- Water intake monitoring
- Completion celebrations

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd daily_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform Support
- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## Dependencies

- **provider**: State management
- **shared_preferences**: Local data persistence
- **google_fonts**: Typography enhancement

## Project Structure

```
lib/
├── main.dart              # App entry point
├── theme/
│   └── app_theme.dart     # Light/dark theme configuration
├── state/
│   └── daily_state.dart   # State management and data persistence
└── screens/
    └── dashboard_screen.dart  # Main dashboard UI
```

## Usage

1. **Track Progress**: Tap +10/-10 buttons to adjust exercise counts
2. **Water Intake**: Use +250ml/-250ml buttons for quick water tracking
3. **Reset Progress**: Use the refresh button to reset today's progress
4. **View Goals**: See your daily targets at the top of the screen
5. **Monitor Progress**: Watch progress bars fill as you complete exercises

## Customization

### Goals
Modify the `DailyGoals` class in `lib/state/daily_state.dart` to adjust:
- Push-up target
- Sit-up target  
- Squat target
- Water intake goal

### Themes
Customize colors and styling in `lib/theme/app_theme.dart`:
- Primary colors
- Card styles
- Button appearances
- Typography

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For questions or issues, please open an issue on GitHub or contact the development team.

---

**Built with ❤️ using Flutter**
