@echo off
echo ==========================================
echo Starting Folder and File Cleanup...
echo ==========================================

cd lib

echo Renaming folders...
rename "splash screen" "splash_screen"
rename "home screen" "home_screen"
rename "loge in" "login"
rename "sign up" "sign_up"
rename "Jadwaly" "jadwaly"
rename "Settings" "settings"
rename "Notifications" "notifications"
rename "widget" "widgets"
rename "qady\widgt qady" "widgets"

echo Renaming files...
rename "login\loge_in.dart" "login_screen.dart"
rename "login\custom_logein_textfild.dart" "custom_login_textfield.dart"
rename "sign_up\custom_signup_textfild.dart" "custom_signup_textfield.dart"
rename "widgets\castom_nevigator.dart" "custom_navigator.dart"
rename "qady\widgets\custom_text_fild.dart" "custom_textfield.dart"

cd ..

echo Moving MainActivity.kt for new Package Name (com.uod.smartapp)...
mkdir "android\app\src\main\kotlin\com\uod" 2>nul
mkdir "android\app\src\main\kotlin\com\uod\smartapp" 2>nul
move "android\app\src\main\kotlin\com\example\colloge\MainActivity.kt" "android\app\src\main\kotlin\com\uod\smartapp\"

echo ==========================================
echo Running Dart Script to Fix All Imports...
echo ==========================================
dart fix_imports.dart

echo ==========================================
echo Cleanup Complete!
echo ==========================================
pause
