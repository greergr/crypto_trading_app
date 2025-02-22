@echo off
echo Initialize Git repository and push to GitHub
echo =====================================

git init
git add .
git commit -m "Initial commit"
git branch -M main

echo.
echo Please enter your GitHub username:
set /p username=

echo.
git remote add origin https://github.com/greergr/crypto_trading_app.git
git push -u origin main

echo.
echo Done! Now go to https://github.com/greergr/crypto_trading_app/settings/pages
echo to enable GitHub Pages.
echo.
pause
