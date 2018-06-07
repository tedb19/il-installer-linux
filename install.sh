#!/bin/bash
clear
INSTALLATION_DIRECTORY="/opt/Interop-Layer"
PLATFORM="linux"
DATABASE_PROP="interopdb"
PM2="node_modules/pm2/bin/pm2"

echo "==============: Installing nodejs..."
sudo tar -xf prerequisites/node-v8.11.2-linux-x64.tar.xz --directory /usr/local --strip-components 1

echo "==============: Extracting installation files to '$INSTALLATION_DIRECTORY/' ..."
sudo mkdir "$INSTALLATION_DIRECTORY" -v
sudo tar -xvf dist.tar.gz -C "$INSTALLATION_DIRECTORY"

sudo chown -R $USER:$USER "$INSTALLATION_DIRECTORY"

echo "==============: Please enter the database credentials:"

while true; do
  read -p "Database username: "  USERNAME_PROP
  read -ps "Database password: "  PASSWORD_PROP

  RESULT=`mysqlshow 2>&1 --user=$USERNAME_PROP --password=$PASSWORD_PROP mysql | grep -v Wildcard | grep -o mysql`

  if [ "$RESULT" == "mysql mysql" ]; then
      echo "==============: Database credentials are correct!"
      sudo echo "USERNAME_PROP=$USERNAME_PROP" >> /etc/environment
      sudo echo "PASSWORD_PROP=$PASSWORD_PROP" >> /etc/environment
      break
  else
    echo "==============: The database credentials are incorrect! Please try again:"
  fi
done

sudo echo "DATABASE_PROP=$DATABASE_PROP" >> /etc/environment
sudo echo "PLATFORM=$PLATFORM" >> /etc/environment

source /etc/environment

mysql -u${USERNAME_PROP} -p${PASSWORD_PROP} -e "CREATE DATABASE ${DATABASE_PROP} /*\!40100 DEFAULT CHARACTER SET utf8 */;"

echo "==============: Starting IL through PM2 Process Manager"
cd "$INSTALLATION_DIRECTORY/dist"
$PM2 start src/server/index.js --name "Interoperability Layer"

echo "==============: Make PM2 auto-start on system restarts"
$PM2 startup | tail -1 | sudo -E bash -

$PM2 save

clear

echo "


  _____           _                                                         _       _   _   _   _               _                                    
 |_   _|         | |                                                       | |     (_) | | (_) | |             | |                                   
   | |    _ __   | |_    ___   _ __    ___    _ __     ___   _ __    __ _  | |__    _  | |  _  | |_   _   _    | |        __ _   _   _    ___   _ __ 
   | |   | '_ \  | __|  / _ \ | '__|  / _ \  | '_ \   / _ \ | '__|  / _` | | '_ \  | | | | | | | __| | | | |   | |       / _` | | | | |  / _ \ | '__|
  _| |_  | | | | | |_  |  __/ | |    | (_) | | |_) | |  __/ | |    | (_| | | |_) | | | | | | | | |_  | |_| |   | |____  | (_| | | |_| | |  __/ | |   
 |_____| |_| |_|  \__|  \___| |_|     \___/  | .__/   \___| |_|     \__,_| |_.__/  |_| |_| |_|  \__|  \__, |   |______|  \__,_|  \__, |  \___| |_|   
                                             | |                                                       __/ |                      __/ |              
                                             |_|                                                      |___/                      |___/               


"

echo 
echo "==============: Interoperability Layer successfully installed!"
echo "==============: Browse to http://localhost:5000 to begin using the IL."
echo "==============: Default username and password is admin admin"
echo "==============: Update the facility name and the DHIS credentials under the settings page"
echo "==============: Update the system addresses for each participating system"
