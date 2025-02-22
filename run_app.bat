@echo off
cd /d "%~dp0"
start /min cmd /c "flutter clean && flutter pub get && flutter run -d chrome --web-port 8000 --web-renderer html"
timeout /t 10 /nobreak >nul
start "" "http://localhost:8000"
