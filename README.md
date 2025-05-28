

# AsyncChat

AsyncChat is a cross-platform messaging application built with Flutter. It serves as a starting point for developers looking to create chat applications with Flutter, providing a foundational structure and essential features.

---

## 📂 Project Structure

The repository is organized into the following directories, each corresponding to a platform:

* **android/**: Android-specific code and configurations.
* **ios/**: iOS-specific code and configurations.
* **lib/**: Dart code shared across all platforms.
* **linux/**: Linux-specific code and configurations.
* **macos/**: macOS-specific code and configurations.
* **test/**: Unit and widget tests.
* **web/**: Web-specific code and configurations.
* **windows/**: Windows-specific code and configurations.

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:

* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Dart SDK](https://dart.dev/get-dart)
* [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/)

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/AngelArabadzhiev/AsyncChat.git
   cd AsyncChat
   ```



2. Install dependencies:

   ```bash
   flutter pub get
   ```



3. Run the application on your desired platform:

   * For Android:

     ```bash
     flutter run -d android
     ```

   * For iOS:

     ```bash
     flutter run -d ios
     ```

   * For Web:

     ```bash
     flutter run -d chrome
     ```

   * For Desktop (Linux/macOS/Windows):

     ```bash
     flutter run -d <platform>
     ```

     Replace `<platform>` with `linux`, `macos`, or `windows` as appropriate.

---

## 🧪 Running Tests

To run the tests:

```bash
flutter test
```



---

## 📄 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.


