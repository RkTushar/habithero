# 📱 HabitHero -  Gamified Habit Tracker

HabitHero is a Flutter-based habit tracking application that helps users build better habits by tracking consistency and progress. It supports Firebase Authentication and Firestore for secure login and real-time data storage.

---

## ✨ Features

- 🔐 Firebase Authentication (Email & Password Login)
- ➕ Add new habits with custom names and frequency
- 📊 View all your habits in a neat list
- ✅ Check completed habits and plan your week
- ☁️ Real-time Firestore database integration
- 🚀 Smooth and clean Material UI
- 🔒 Secure user-specific habit data

---

## 🛠️ Tech Stack

| Technology    | Description                              |
|---------------|------------------------------------------|
| Flutter       | UI toolkit for cross-platform apps       |
| Dart          | Programming language used with Flutter   |
| Firebase Auth | User authentication system               |
| Cloud Firestore | Realtime NoSQL database by Firebase     |

--

## 🧪 How to Run Locally

1. **Clone the Repo**
   ```bash
   git clone https://github.com/RkTushar/habithero.git
   cd habithero
2. **Install Dependencies**
   ```bash
   flutter pub get
3. **Connect Firebase**
   Create a project in Firebase Console

   Add Android & Web apps to it

   Download the Google-services.json file and place it in android/app/

   Enable Email/Password in Firebase Authentication

   Set up Firestore database rules for user access
4. **Run the Apps**
   ```bash
   flutter run
5. **📁 Folder Structure**
   ```bash
   lib/
   │
   ├── main.dart               # Entry point
   ├── login_screen.dart       # Login & registration
   ├── home_screen.dart        # Habit list screen
   ├── add_habit_screen.dart   # Add new habit UI
   
6. **To Do**
    Streak & Progress Visualization

 Habit Completion Toggle

 Edit/Delete Habit Functionality

 Dark Mode Support

 Push Notifications

 7. **License**
      This project is open source and available under the MIT License.
