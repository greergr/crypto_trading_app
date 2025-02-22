@echo off
echo Starting Crypto Trading App...

:: Change to the script's directory
cd /d "%~dp0"

:: Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Flutter is not found in PATH
    echo Please make sure Flutter is installed and added to PATH
    pause
    exit /b 1
)

:: Build the app if it hasn't been built yet
if not exist "build\windows\runner\Release\crypto_trading_app.exe" (
    echo First time setup - Building the app...
    flutter build windows
    if %ERRORLEVEL% neq 0 (
        echo Build failed
        pause
        exit /b 1
    )
)

:: Run the app
echo Launching app...
start "" "build\windows\x64\runner\Release\crypto_trading_app.exe"

exit
