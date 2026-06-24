# جامعة درنة — التطبيق الذكي | University of Derna Smart App

<div align="center">

![University of Derna](https://img.shields.io/badge/جامعة%20درنة-Smart%20App-001835?style=for-the-badge&logo=firebase)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?style=for-the-badge&logo=dart)

**التطبيق الذكي الرسمي لإدارة جامعة درنة وخدمات الطلاب**  
*Official Smart Management Application for University of Derna*

</div>

---

## 📋 نظرة عامة | Project Overview

### العربية

التطبيق الذكي لجامعة درنة هو منصة رقمية متكاملة تهدف إلى تحويل تجربة التعليم الجامعي في جامعة درنة (ليبيا) من النظام الورقي التقليدي إلى بيئة رقمية حديثة وشاملة. يغطي التطبيق دورة حياة الطالب الكاملة — من التسجيل الأولي حتى التخرج — ويوفر بوابات مخصصة للطلاب وأعضاء هيئة التدريس والإداريين والزوار.

### English

The University of Derna Smart App is a comprehensive digital platform designed to modernize the academic experience at the University of Derna, Libya. It digitizes the complete student lifecycle — from initial registration through graduation — and provides dedicated portals for Students, Faculty Members, Administrators, and Guest users.

---

## 🔴 بيان المشكلة | Problem Statement

### العربية

تعاني جامعة درنة، كغيرها من الجامعات الليبية، من:
- إدارة ورقية بطيئة للتسجيل والسجلات الأكاديمية
- انعدام التواصل الفوري بين الطلاب وأعضاء هيئة التدريس
- صعوبة الوصول إلى الجداول الدراسية والدرجات والرسوم
- غياب آلية شفافة لمتابعة حالة طلبات القبول
- عدم توفر معلومات الكليات للعموم بشكل منظم

### English

The university faces: slow paper-based registration, no real-time student-faculty communication, difficulty accessing schedules/grades/fees, no transparent admission tracking, and no organized public college information.

---

## 🎯 الأهداف | Objectives

1. رقمنة دورة حياة الطالب الكاملة | Digitize the full student lifecycle
2. توفير بوابات مخصصة لكل دور مستخدم | Role-specific portals for each user type
3. تحسين الشفافية في عملية القبول | Improve admission process transparency
4. تمكين أعضاء هيئة التدريس من الإدارة الرقمية | Empower faculty with digital management tools
5. توفير وصول عام لمعلومات الكليات | Public access to college information
6. دعم اللغتين العربية والإنجليزية | Full Arabic/English bilingual support

---

## ✨ الميزات الرئيسية | Main Features

| الميزة | Feature | الحالة |
|--------|---------|--------|
| تسجيل متعدد المراحل مع نظام تسجيل النقاط | Multi-step scored registration | ✅ Implemented |
| بوابة الطالب الكاملة | Full student portal | ✅ Implemented |
| لوحة تحكم عضو هيئة التدريس | Faculty member dashboard | ✅ Implemented |
| لوحة تحكم الإدارة | Admin dashboard | ✅ Implemented |
| طابور التحقق من التسجيلات | Registration verification queue | ✅ Implemented |
| عرض الكليات للزوار | Public college portal (guest) | ✅ Implemented |
| جهاز تتبع حفظ القرآن | Quran Hifzh tracker | ✅ Implemented |
| ثنائية اللغة (عربي/إنجليزي) | Full AR/EN localization | ✅ Implemented |
| الوضع الداكن والفاتح | Dark/Light theme | ✅ Implemented |
| الوصول دون اتصال | Offline Firestore persistence | ✅ Implemented |
| استئذان غياب | Absence excuse submission | ✅ Implemented |
| تجديد القيد | Enrollment renewal | ✅ Implemented |
| عرض الجدول الدراسي | Timetable view | ⚠️ Mock data |
| الإشعارات الفورية | Push notifications | ⚠️ Planned |
| كشف الدرجات (Transcript) | Academic transcript | ⚠️ In progress |

---

## 👥 أدوار المستخدمين | User Roles

### 🎓 طالب (Student)
- عرض الجدول الدراسي والدرجات
- تقديم طلبات استئذان الغياب
- تجديد القيد الدراسي
- مراجعة الرسوم الدراسية
- عرض كشف الدرجات
- مراسلة أعضاء هيئة التدريس

### 👨‍🏫 عضو هيئة التدريس (Faculty)
- إدارة الطلاب وحضورهم
- رفع أوراق الامتحانات
- إدخال الدرجات
- إدارة المهام والواجبات
- عرض التقارير والإحصاءات
- إدارة الجدول الشخصي

### 🛡️ مدير النظام (Admin)
- مراجعة وقبول/رفض طلبات التسجيل
- إدارة المستخدمين
- إدارة المقررات الدراسية
- إعدادات النظام
- عرض سجلات النظام
- إدارة التقارير

### 👁️ زائر (Guest)
- تصفح معلومات الكليات
- الاطلاع على الأقسام والبرامج
- لا يمكنه الوصول إلى البيانات الشخصية

---

## 🏗️ معمارية النظام | System Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Flutter App                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ Student  │  │ Faculty  │  │     Admin         │  │
│  │  Portal  │  │  Portal  │  │    Dashboard      │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
│  ┌──────────────────────────────────────────────┐   │
│  │            Core (Router, Theme, L10n)         │   │
│  │       GoRouter + Riverpod + AppTheme          │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────┬───────────────────────────┘
                          │
         ┌────────────────▼────────────────┐
         │         Firebase Backend         │
         │  Auth | Firestore | Storage      │
         │  Cloud Functions (planned)       │
         └─────────────────────────────────┘
```

**State Management:** Riverpod 3 (main app) + BLoC (Hifzh module)  
**Navigation:** GoRouter 17 with role-based redirect guards  
**Database:** Cloud Firestore (primary) + SQLite (planned offline cache) + Hive (Hifzh)  
**Localization:** Flutter gen-l10n with Arabic/English ARB files

---

## 🛠️ التقنيات المستخدمة | Technology Stack

| Category | Technology | Version |
|----------|-----------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | ^3.7.2 |
| State Management | Flutter Riverpod | ^3.3.1 |
| Navigation | GoRouter | ^17.2.3 |
| Backend | Firebase (Auth, Firestore, Storage) | Latest |
| Local DB | sqflite (planned), Hive (Hifzh) | ^2.4.2 / ^2.2.3 |
| Maps | Google Maps Flutter | ^2.17.1 |
| PDF | Syncfusion PDF Viewer | ^33.2.10 |
| Charts | fl_chart | ^1.2.0 |
| Fonts | Cairo (local) + Google Fonts fallback | — |
| HTTP | Dio | ^5.9.2 |

---

## 🔥 خدمات Firebase | Firebase Services Used

| Service | Usage |
|---------|-------|
| **Firebase Auth** | Email/password sign-in, account creation, password reset |
| **Cloud Firestore** | Users, registrations, schedules, fees, notifications, email queue |
| **Firebase Storage** | Exam paper uploads, profile image uploads |
| **Cloud Functions** | Declared (email sending, custom claims) — not yet implemented client-side |

---

## 📁 هيكل المشروع | Folder Structure

```
flutter_project/
├── lib/
│   ├── core/               # Shared infrastructure (theme, router, models, providers)
│   ├── features/           # 28 feature modules (auth, admin, faculty, student...)
│   ├── l10n/               # Arabic & English localization
│   ├── shared/             # Cross-feature widgets
│   └── main.dart           # App entry point
├── assets/
│   ├── images/             # Splash screen, app assets
│   ├── sounds/             # Audio assets (Hifzh module)
│   └── data/               # Static JSON data
├── fonts/                  # Cairo font family
├── firestore.rules         # Firestore Security Rules
├── storage.rules           # Firebase Storage Rules
├── firebase.json           # Firebase project config
└── pubspec.yaml            # Dart dependencies
```

---

## ⚙️ دليل التثبيت | Installation Guide

### Prerequisites
- Flutter SDK `^3.7.2`
- Dart SDK `^3.7.2`
- Android Studio / VS Code
- Firebase CLI
- Node.js (for Firebase CLI)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/amrokhalidalshalwy-stack/University-of-Derna-Smart-App-.git
cd University-of-Derna-Smart-App-

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure Firebase (replace with your own project)
flutterfire configure

# 4. Create .env file (DO NOT commit real values)
cp .env.example .env
# Edit .env with your configuration

# 5. Generate localization files
flutter gen-l10n

# 6. Run the app
flutter run
```

---

## 🔧 دليل الإعداد | Configuration Guide

### Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Firebase Authentication** (Email/Password provider)
3. Create a **Cloud Firestore** database
4. Enable **Firebase Storage**
5. Run `flutterfire configure` to generate `firebase_options.dart`
6. Deploy Security Rules: `firebase deploy --only firestore,storage`

### Environment Variables (`.env`)
```
API_BASE_URL=https://api.uod.edu.ly
QURAN_API_BASE_URL=https://api.quran.com/api/v4
ENABLE_OFFLINE_AUDIO=true
```

> ⚠️ **NEVER** put API keys or tokens in `.env` — they will be bundled into the APK.

---

## ▶️ تشغيل المشروع | Running the Project

```bash
# Debug mode
flutter run

# Specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome

# Release mode (Android)
flutter build apk --release

# Release mode (iOS)
flutter build ios --release
```

---

## 🚀 دليل النشر | Deployment Guide

### Android
```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols
```
Upload to Google Play Store.

### Firebase Hosting (Web)
```bash
flutter build web --release
firebase deploy --only hosting
```

### Firebase Rules
```bash
firebase deploy --only firestore
firebase deploy --only storage
```

---

## 🔒 اعتبارات الأمان | Security Considerations

> ⚠️ See `SECURITY_REVIEW.md` for the full security audit.

**Critical before production:**
1. Revoke and remove `serviceAccountKey.json` from the project directory
2. Fix the Firestore catch-all wildcard rule
3. Enable Firebase App Check
4. Set Firebase Auth custom claims via Cloud Functions for role enforcement
5. Restrict API keys in Google Cloud Console by bundle ID

---

## 🗺️ خارطة الطريق | Roadmap

### Version 1.1 (Next)
- [ ] Connect timetable to live Firestore data
- [ ] Fix Firestore Security Rules (remove wildcard)
- [ ] Implement Firebase Cloud Functions for email sending and custom claims
- [ ] Add real notification system (FCM)

### Version 1.2
- [ ] Complete SQLite offline cache layer
- [ ] Full transcript generation with n8n webhook
- [ ] Student messaging system
- [ ] Performance tracking charts for faculty

### Version 2.0
- [ ] Firebase App Check integration
- [ ] Advanced analytics dashboard
- [ ] Push notification campaigns
- [ ] Document upload/management system
- [ ] Course enrollment system

---

## 🔮 التحسينات المستقبلية | Future Improvements

1. Implement repository pattern for testability
2. Add unit tests and widget tests
3. Complete BLoC → Riverpod migration in Hifzh module
4. Add Firebase Crashlytics for error monitoring
5. Implement course enrollment and grade submission workflows
6. Add video lecture support
7. Implement peer-to-peer chat with read receipts
8. Multi-college admin management

---

## 👨‍💻 المطورون | Contributors

- **Omar Khaled Alkhawga** — Lead Developer / Flutter Engineer
- University of Derna — Project Sponsor

---

## 📄 الترخيص | License

This project is proprietary software developed for the University of Derna.  
هذا المشروع برنامج مملوك تم تطويره لجامعة درنة.

All rights reserved © 2025–2026 University of Derna Smart App Team.
=======
# colloge

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.