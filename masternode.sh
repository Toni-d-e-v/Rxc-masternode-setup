#!/bin/bash

clear
cd /root
echo && echo && echo
sleep 2

# Provjeri root
if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as user: root"
  exit -1
fi

# systemd
systemctl --version >/dev/null 2>&1 || { echo "You must use Ubuntu 16.04 (Xenial)."  >&2; exit 1; }

# input from user
echo "Please enter your Masternode Private Key"
read -e -p "e.g. (8tagsuahsAHAJshjvhs88asadijsuyas98aqsaziucdplmkh75sb) : " key
if [[ "$key" == "" ]]; then
    echo "WARNING: No private key entered, exiting!!!"
    echo && exit
fi
read -e -p "VPS Server IP Address and Masternode Port like IP:11010 : " ip
echo && echo "Pressing ENTER will use the default value for the next prompts."
echo && sleep 3
read -e -p "Add swap space? (Recommended) [Y/n] : " add_swap
if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
    read -e -p "Swap Size [2G] : " swap_size
    if [[ "$swap_size" == "" ]]; then
        swap_size="2G"
    fi
fi
read -e -p "Install Fail2ban? (Recommended) [Y/n] : " install_fail2ban

# swap...
if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
    if [ ! -f /swapfile ]; then
        echo && echo "Adding swap space..."
        sleep 3
        sudo fallocate -l $swap_size /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
        sudo sysctl vm.swappiness=10
        sudo sysctl vm.vfs_cache_pressure=50
        echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
        echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
    else
        echo && echo "WARNING: Swap file detected, skipping add swap!"
        sleep 3
    fi
fi

# Update system 
echo && echo "Upgrading system and install initial dependencies"
sleep 3
sudo apt-get -y update
sudo apt-get -y upgrade

# Install required packages
echo && echo "Installing base packages..."
sleep 3
sudo apt-get -y install \
build-essential \
libtool \
autotools-dev \
automake \
unzip \
pkg-config \
libssl-dev \
bsdmainutils \
software-properties-common \
python-virtualenv \
libzmq3-dev \
libevent-dev \
libboost-dev \
libboost-chrono-dev \
libboost-filesystem-dev \
libboost-program-options-dev \
libboost-system-dev \
libboost-test-dev \
libboost-thread-dev \
libdb4.8-dev \
libdb4.8++-dev \
libminiupnpc-dev 

# fail2ban 
if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
    echo && echo "Installing fail2ban..."
    sleep 3
    sudo apt-get -y install fail2ban
    sudo service fail2ban restart 
fi

# Edit/Create config file for rxc
echo && echo "Creating your data folder and files..."
sleep 3
sudo mkdir /root/.ruxcrypto

rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
rpcpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
sudo touch /root/.ruxcrypto/ruxcrypto.conf #config
echo '
rpcuser='$rpcuser'
rpcpassword='$rpcpassword'
rpcallowip=127.0.0.1
listen=1
server=1
rpcport=23506
daemon=1
logtimestamps=1
maxconnections=256
externalip='$ip'
masternode=1
masternodeprivkey='$key'
' | sudo -E tee /root/.ruxcrypto/ruxcrypto.conf

# Download rxc
mkdir ruxcrypto
cd ruxcrypto
wget https://github.com/Toni-d-e-v/Rxc-masternode-setup/releases/download/1/rxclinux.zip
unzip rxclinux.zip
# Give permissions
chmod +x ruxcryptod
chmod +x ruxcrypto-cli
chmod +x ruxcrypto-tx

# Move binaries do lib folder
sudo mv ruxcrypto-cli /usr/bin/ruxcrypto-cli
sudo mv ruxcrypto-tx /usr/bin/ruxcrypto-tx
sudo mv ruxcryptod /usr/bin/ruxcryptod

#run daemon
ruxcryptod -daemon
sleep 5

# 
echo && echo "Instaliranje Sentinel..."
sleep 3
cd
sudo apt-get -y install python3-pip
sudo pip3 install virtualenv
sudo apt-get install screen
# crypto.ba sentinel made by Rux/Toni.Dev
sudo git clone https://git.crypto.ba/rux/SentinelRXC /root/sentinel-rxc
cd /root/sentinel-rxc
mkdir database
virtualenv venv
. venv/bin/activate
pip install -r requirements.txt
export EDITOR=nano
(crontab -l -u root 2>/dev/null; echo '* * * * * cd /root/sentinel-rxc && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1') | sudo crontab -u root -


# Napravi da kada se restartije da se runa node
if ! crontab -l | grep "@reboot ruxcryptod -daemon"; then
  (crontab -l ; echo "@reboot ruxcryptod -daemon") | crontab -
fi

# Finished
echo && echo "Rxc masternod je instaliran!"

echo "If you put correct PrivKey and VPS IP the daemon should be running."
echo "Wait 2 minutes then run ruxcrypto-cli getinfo to check blocks."
echo "When fully synced you can start ALIAS on local wallet and finally check here with helpico-cli masternode status."
echo && echo
