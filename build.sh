#!/bin/sh
# Собирает LatLex (Lation Lexicon) под macOS или Linux через Free Pascal.
# Установка компилятора:
#   macOS:  brew install fpc
#   Linux:  sudo apt install fpc   (либо fp-compiler в вашем дистрибутиве)
# Под Windows используйте build.bat.
set -e
cd "$(dirname "$0")"

mkdir -p run build
fpc -Fu./tpcompat -FE./run -FU./build ./src/LatLex.pas

cp -f src/data/LATLEX.HLP run/LATLEX.HLP
for f in BOBR.VOC BOBR.TBL LATLEX.CFG; do
  if [ ! -f "run/$f" ]; then
    cp -f "src/data/$f" "run/$f"
  fi
done

echo
echo "Готово: run/LatLex"
echo "Запуск: cd run && ./LatLex"
echo "(словарь BOBR.VOC уже выбран и проиндексирован - можно сразу Begin test)"
