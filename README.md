# Tourist Trip Planner

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

Welcome to the **Tourist Trip Planner**, a modern Flutter-based mobile application designed to help users plan their travel itineraries with ease. Featuring an intuitive login system and a user-friendly interface, this app showcases a robust login screen with animations, form validation, and seamless navigation to a trip planning feature. The app now includes Persian language support for broader accessibility.

## Screenshots

| **Login** | **Trip Planning 1** | **Trip Planning 2** | **Trip Planning 3** |
|-----------|---------------------|---------------------|---------------------|
| ![Login](screenshots/Screenshot%201.png) | ![Trip Planning 1](screenshots/Screenshot%202.png) | ![Trip Planning 2](screenshots/Screenshot%203.png) | ![Trip Planning 3](screenshots/Screenshot%204.png) |

| **Trip Planning 4** | **Trip Planning 5** | **Trip Planning 6** | **Trip Planning 7** |
|---------------------|---------------------|---------------------|---------------------|
| ![Trip Planning 4](screenshots/Screenshot%205.png) | ![Trip Planning 5](screenshots/Screenshot%206.png) | ![Trip Planning 6](screenshots/Screenshot%207.png) | ![Trip Planning 7](screenshots/Screenshot%208.png) |

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)

## Overview

The **Tourist Trip Planner** app provides a seamless experience for users to log in and manage their travel plans. Built with Flutter, it ensures cross-platform compatibility for both Android and iOS, delivering a smooth and responsive user experience. The app now supports Persian localization, enhancing usability for Persian-speaking users.

## Features

- **Animated Login Interface**: Scalable logo and social login options (Google, Facebook, Apple).
- **Form Validation**: Email and password validation with a password strength indicator.
- **Responsive Design**: Optimized for both Android and iOS platforms.
- **Seamless Navigation**: Smooth transition to the trip planning screen upon successful login.
- **Persian Language Support**: Full localization for Persian-speaking users.

## Prerequisites

Before setting up the project, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) (for Android/iOS development)
- A code editor (e.g., [VS Code](https://code.visualstudio.com/) with the Flutter extension)

## Getting Started

Follow these steps to set up and run the project locally:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/tourist-trip-planner.git
   cd tourist-trip-planner
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the App**:
   - Connect a physical device or start an emulator/simulator.
   - Execute the following command:
     ```bash
     flutter run
     ```
   - The app will launch, allowing you to test the login screen.

4. **Build the App (Optional)**:
   - **For Android (APK)**:
     ```bash
     flutter build apk --debug
     ```
     The APK will be available in `build/app/outputs/flutter-apk/`.
   - **For iOS (IPA, requires macOS and Xcode)**:
     ```bash
     flutter build ios --debug
     ```
     Open `build/ios/Runner.xcworkspace` in Xcode to archive and export the IPA.

## Project Structure

- `lib/screens/login_screen.dart`: Implements the login screen with animations and form handling.
- `lib/screens/tourist_planner_screen.dart`: Main trip planning screen (to be implemented).
- `pubspec.yaml`: Contains dependency configuration and project metadata.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-branch
   ```
3. Make your changes and commit them:
   ```bash
   git commit -m "Add new feature"
   ```
4. Push to the branch:
   ```bash
   git push origin feature-branch
   ```
5. Open a Pull Request.

Please ensure your code adheres to [Flutter best practices](https://flutter.dev/docs/development) and is well-documented.

## License

This project is licensed under the MIT License. Feel free to use, modify, and distribute it as per the license terms.

## Contact

For questions or feedback, please open an issue in this repository or contact the maintainer:

- **Email**: navid.office.work@gmail.com
- **GitHub**: (https://github.com/7Na7iD7)

## Acknowledgments

- Special thanks to the [Flutter community](https://flutter.dev/community) for providing an exceptional framework.
- Inspired by modern UI/UX designs for travel applications.
- Gratitude to contributors for adding Persian language support.
