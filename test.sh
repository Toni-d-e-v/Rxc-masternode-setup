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

