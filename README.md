# 75 Hard Challenge Tracker

A Flutter mobile application to track your progress through the famous 75 Hard Challenge. This app helps you stay accountable and motivated throughout your 75-day mental toughness journey.

## 📲 Download the App

➡️ **[Download Latest APK](https://github.com/sudheerthan/75HardChallenge/releases/download/v1.0.0/the_75Days.apk)**  
(*Click to install the app on your Android device*)


## Features

### 🎯 Core Functionality
- **Daily Task Tracking**: Check off 8 essential daily tasks
- **Progressive Day System**: Days advance only when all tasks are completed
- **Persistent Storage**: Your progress is saved locally and persists between app sessions
- **Day Completion Control**: Complete a day by finishing all tasks, then advance to the next day

### 📊 Statistics & Analytics
- **Progress Overview**: Track overall completion percentage
- **Perfect Days Counter**: See how many days you've completed perfectly
- **Task Analysis**: Individual completion rates for each task type
- **Visual Calendar**: 75-day grid showing your progress with color-coded performance
- **Completion Trends**: Identify which tasks you struggle with most

### 🎨 User Experience
- **Material Design 3**: Modern, clean interface following Google's design guidelines
- **Intuitive Navigation**: Easy-to-use interface with clear visual feedback
- **Completion Celebrations**: Special dialogs and animations when completing days
- **Progress Indicators**: Visual progress bars and completion states

## The 8 Daily Tasks

1. **Follow a Diet** - Stick to a structured diet with no cheat meals
2. **Two 45-Minute Workouts** - Complete two workouts daily, one must be outdoors
3. **Drink 1 Gallon (3.7L) of Water** - Stay hydrated with no substitutions
4. **Read 10 Pages** - Read 10 pages of a non-fiction/self-improvement book
5. **Take a Progress Photo** - Capture a daily photo to track physical changes
6. **Get 7-8 Hours of Sleep** - Ensure proper rest to aid recovery and focus
7. **Avoid Sugar & Junk** - Cut out all added sugars and junk food
8. **Practice a Skill** - Spend time developing a personal or professional skill

## How It Works

### Day Progression System
- Start on Day 1 when you first open the app
- Complete all 8 tasks throughout your day
- When all tasks are checked off, you can complete the day
- Upon day completion, you automatically advance to the next day
- Days cannot be reset once completed (maintains challenge integrity)

### Data Persistence
- All progress is saved locally using SharedPreferences
- Your current day, task completions, and statistics persist between app sessions
- Each completed day is permanently recorded for statistics

## Screenshots

<!-- - Main tracking screen
- Statistics page
- Day completion dialog
- Rules/tasks overview -->

## Installation

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  cupertino_icons: ^1.0.2
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by Andy Frisella's 75 Hard Challenge
- Built with Flutter and Material Design 3
- Icons provided by Material Icons

## Support

If you find this app helpful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs via Issues
- 💡 Suggesting features
- 🔄 Contributing improvements

---

**Remember**: The 75 Hard Challenge is about mental toughness and discipline. This app is just a tool - your commitment and consistency are what matter most. Stay strong! 💪

## Changelog

### v1.0.0
- Initial release
- Core task tracking functionality
- Day progression system
- Statistics and analytics
- Material Design 3 UI
- Local data persistence