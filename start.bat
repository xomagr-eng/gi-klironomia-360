@echo off
rem ============================================================
rem  ΓΗ & ΚΛΗΡΟΝΟΜΙΑ 360° - Εκκίνηση ως εφαρμογη (offline)
rem  Σηκωνει τοπικο server στο localhost (ΧΩΡΙΣ ιντερνετ) και
rem  ανοιγει την εφαρμογη ωστε να λειτουργει ως πληρες PWA.
rem ============================================================
cd /d "%~dp0"

rem Ξεκινα τον τοπικο server κρυμμενο στο παρασκηνιο
start "GH360-server" /min powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0serve.ps1"

rem Δωσε 1-2 δευτερολεπτα να σηκωθει
timeout /t 2 /nobreak >nul

rem Ανοιξε την εφαρμογη στον προεπιλεγμενο browser
start "" "http://localhost:8790/index.html"

echo.
echo  Η εφαρμογη ανοιξε στο http://localhost:8790
echo  Στον browser: μενου -> "Εγκατασταση εφαρμογης" / "Προσθηκη στην αρχικη οθονη"
echo  ωστε να ανοιγει fullscreen σαν κανονικη εφαρμογη.
echo.
echo  Ο server τρεχει στο παρασκηνιο. Για να τον κλεισεις, κλεισε
echo  το παραθυρο "GH360-server" (η κανε Log off/Restart).
echo.
timeout /t 4 /nobreak >nul
