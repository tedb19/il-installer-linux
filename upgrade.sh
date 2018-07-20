#!/bin/bash
clear
INSTALLATION_DIRECTORY="/opt/Interop-Layer"
DATABASE_PROP="interopdb"
INTEROP="$INSTALLATION_DIRECTORY/dist/src/server/index.js"
SLEEPVALUE=1

cat ./logo

sudo rm -Rf "$INSTALLATION_DIRECTORY/dist/"
sudo tar -xf dist.tar.gz -C "$INSTALLATION_DIRECTORY"
sudo pm2 reload all --update-env

cat ./logo

echo 
echo "==============: Interoperability Layer successfully upgraded!"
echo "==============: Browse to http://localhost:5000 to begin using the IL."
echo "==============: Default username and password is admin admin"

echo
while [ $SLEEPVALUE -lt 10 ]
do
  echo -ne "."
  sleep 2s
  SLEEPVALUE=$[$SLEEPVALUE+1]
done
echo

clear