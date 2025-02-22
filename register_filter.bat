@echo off
schtasks /create /xml "%~dp0filter.xml" /tn "CryptoTradingBot" /f
schtasks /run /tn "CryptoTradingBot"
