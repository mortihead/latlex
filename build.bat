@echo off
rem Сборка LatLex (Lation Lexicon) под Windows через Free Pascal.
rem Установка компилятора: https://www.freepascal.org/download.html
setlocal
cd /d "%~dp0"

if not exist run mkdir run
if not exist build mkdir build

fpc -Fu.\tpcompat -FE.\run -FU.\build .\src\LatLex.pas
if errorlevel 1 goto :eof

copy /Y src\data\LATLEX.HLP run\LATLEX.HLP >nul
if not exist run\BOBR.VOC copy /Y src\data\BOBR.VOC run\BOBR.VOC >nul
if not exist run\BOBR.TBL copy /Y src\data\BOBR.TBL run\BOBR.TBL >nul
if not exist run\LATLEX.CFG copy /Y src\data\LATLEX.CFG run\LATLEX.CFG >nul

echo.
echo Готово: run\LatLex.exe
echo Запуск: cd run ^&^& LatLex.exe
echo (используйте Windows Terminal - классический cmd.exe может не поддерживать ANSI-цвета)
echo (словарь BOBR.VOC уже выбран и проиндексирован - можно сразу Begin test)
