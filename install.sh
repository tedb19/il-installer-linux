#!/bin/bash
clear
INSTALLATION_DIRECTORY="/opt/Interop-Layer"
PLATFORM="linux"
DATABASE_PROP="interopdb"
PM2="$INSTALLATION_DIRECTORY/dist/node_modules/pm2/bin/pm2"
INTEROP="$INSTALLATION_DIRECTORY/dist/src/server/index.js"
SLEEPVALUE=1

cat ./logo

if [ `getconf LONG_BIT` = "64" ]
then
    echo "==============: Installing x64 nodejs..."
    tar -xf prerequisites/node-v8.11.2-linux-x64.tar.xz --directory /usr/local --strip-components 1
else
    echo "==============: Installing x86 nodejs..."
    tar -xf prerequisites/node-v8.11.3-linux-x86.tar.xz --directory /usr/local --strip-components 1
fi


echo "==============: Extracting installation files to '$INSTALLATION_DIRECTORY/' ..."
mkdir "$INSTALLATION_DIRECTORY"
tar -xf dist.tar.gz -C "$INSTALLATION_DIRECTORY"

echo "==============: Setting up PM2"
tar -xf prerequisites/pm2.tar.gz -C /usr/local/lib/node_modules/

ln -s /usr/local/lib/node_modules/pm2/bin/pm2-dev /usr/local/bin/pm2-dev
ln -s /usr/local/lib/node_modules/pm2/bin/pm2 /usr/local/bin/pm2
ln -s /usr/local/lib/node_modules/pm2/bin/pm2-docker /usr/local/bin/pm2-docker
ln -s /usr/local/lib/node_modules/pm2/bin/pm2-runtime /usr/local/bin/pm2-runtime

echo "==============: Please enter the database credentials:"

while true; do
  read -p "Database username: "  USERNAME_PROP
  read -p "Database password: "  PASSWORD_PROP

  RESULT=`mysqlshow 2>&1 --user=$USERNAME_PROP --password=$PASSWORD_PROP mysql | grep -v Wildcard | grep -o proc | tail -1`

  if [ "$RESULT" == "proc" ]; then
      echo "==============: Database credentials are correct!"
      echo "USERNAME_PROP=$USERNAME_PROP" >> /etc/environment
      echo "PASSWORD_PROP=$PASSWORD_PROP" >> /etc/environment
      break
  else
    echo "==============: The database credentials are incorrect! Please try again:"
  fi
done

echo "DATABASE_PROP=$DATABASE_PROP" >> /etc/environment
echo "PLATFORM=$PLATFORM" >> /etc/environment
echo "PM2=$PM2" >> /etc/environment

source /etc/environment

mysql -u${USERNAME_PROP} -p${PASSWORD_PROP} -e "CREATE DATABASE ${DATABASE_PROP} /*\!40100 DEFAULT CHARACTER SET utf8 */;" >> /dev/null

source /etc/environment

chown -R $SUDO_USER:$SUDO_USER "$INSTALLATION_DIRECTORY"

echo "==============: Starting IL through PM2 Process Manager"
USERNAME_PROP=$USERNAME_PROP PASSWORD_PROP=$PASSWORD_PROP PLATFORM=$PLATFORM DATABASE_PROP=$DATABASE_PROP pm2 start $INTEROP --name "Interoperability Layer" --user $SUDO_USER

# echo "==============: Make PM2 auto-start on system restarts"
# env PATH=$PATH:/usr/local/bin $PM2 startup systemd -u $USER --hp /home/$USER
# $PM2 save
# chown -R $USER:$USER /home/${USER}/.pm2 /home/${USER}/.pm2/rpc.sock /home/${USER}/.pm2/pub.sock

# echo "==============: Make PM2 auto-start on system restarts"
pm2 startup | tail -1 | sudo -E bash -

pm2 save

# chown -R $SUDO_USER:$SUDO_USER /home/${SUDO_USER}/.pm2 /home/${SUDO_USER}/.pm2/rpc.sock /home/${SUDO_USER}/.pm2/pub.sock

clear

cat ./logo

echo 
echo "==============: Interoperability Layer successfully installed!"
echo "==============: Browse to http://localhost:5000 to begin using the IL."
echo "==============: Default username and password is admin admin"
echo "==============: Update the facility name and the DHIS credentials under the settings page"
echo "==============: Update the system addresses for each participating system"
echo "==============: Welcome to the future of secure health data exchange!"


echo
while [ $SLEEPVALUE -lt 15 ]
do
  echo -ne "."
  sleep 2s
  SLEEPVALUE=$[$SLEEPVALUE+1]
done
echo

clear
