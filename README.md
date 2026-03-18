# 🚀 Airdrop - Flutter File Transfer App

Airdrop is a Flutter-based file sharing application that enables fast and reliable transfer of multiple files between nearby devices. It uses **HTTP for file transfer** and **UDP for device discovery**, similar to apps like ShareIt and Xender.

---

## 📱 Features

- 📡 Device discovery using UDP
- 📤 Send multiple files at once
- 📥 Receive files with accept/decline option
- 📊 Per-file progress tracking
- 📁 Automatic file saving:
  - Images & Videos → Gallery (DCIM)
  - Music → Music folder
  - Other files → Downloads
- ⚡ Fast and reliable transfer using HTTP
- 🎯 Simple and clean UI

---

## 🛠 Tech Stack

- Flutter
- Dart
- HTTP (for file transfer)
- UDP (for device discovery)
- File Picker
- Permission Handler

---

## ⚙️ How It Works

1. Receiver starts listening and broadcasting its presence
2. Sender discovers nearby devices using UDP
3. Sender selects files and sends a transfer request
4. Receiver accepts or declines the request
5. Files are transferred via HTTP and saved automatically

---

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
flutter pub get
flutter run
```
## 📸 Screenshots

### 🏠 Home Screen
![Home](assets/screenshots/home.png)

### 📤 Send Screen
![Send](assets/screenshots/send.png)

### 📥 Receive Screen
![Receive](assets/screenshots/receive.png)
