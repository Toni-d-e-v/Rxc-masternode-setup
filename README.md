**Preparation**

-Get a VPS from a provider like DigitalOcean, Vultr, Linode, etc.
-Recommended VPS size: 2GB RAM (if less its ok, we can make swap)
-It must be Ubuntu 16.04 (Xenial)
-Make sure you have a transaction of exactly 1008 HELP in your desktop cold wallet.
-ruxcrypto.conf file on LOCAL wallet MUST BE EMPTY!
-masternode.conf file on VPS wallet MUST BE EMPTY!

**NOTES:** PRE_ENABLED status is NOT an issue, just restart local wallet and wait a few minutes.
You need a different IP for each masternode you plan to host (while using this guide)

**Wallet Setup Part 1**
-Open your wallet on your desktop.
-Click Receive, then click Request and put your Label such as “MN1”
-Copy the Address and Send EXACTLY 1008 HELP to this Address
-Go to the Menu option that says "Tools"
-Click the tab that says "Debug Console"

Wait for 15 confirmations, then run following command:

`masternode outputs`

You should see one line corresponding to the transaction id (tx_id) of your 1008 coins with a digit identifier (digit). Save these two strings in a text file.

Example:
{
  "6a66ad6011ee363c2d97da0b55b73584fef376dc0ef43137b478aa73b4b906b0": "0"
}

Note that if you get more than 1 line, it’s because you made multiple 1000 coins transactions, with the tx_id and digit associated.

Run the following command:

`masternode genkey`

You should see a long key: (masternodeprivkey)
EXAMPLE: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

This is your masternode private key, record it to text file, keep it safe, do not share with anyone. This will be called “masternodeprivkey”

-Next, you have to go to the data directory of your wallet 
-Go to wallet settings=> and click “Open masternode configuration file”
-You should see 3 lines both with a # to comment them out:

```
# Masternode config file
# Format: alias IP:port masternodeprivkey collateral_output_txid collateral_output_index
# Example: mn1 127.0.0.2:19999 93HaYBVUCYjEMeeH1Y4sBGLALQZE1Yc1K64xiqgX37tGBDQL8Xg 2bcd3c84c84f87eaa86e4e56834c92927a07f9e18718810b92e0d0324456a67c 0

```

Please make a new line and add:

MN1 (YOUR VPS IP):port masternodeprivkey tx_id digit

EXAMPLE

```
# Masternode config file
# Format: alias IP:port masternodeprivkey collateral_output_txid collateral_output_index
# Example: mn1 127.0.0.2:19999 93HaYBVUCYjEMeeH1Y4sBGLALQZE1Yc1K64xiqgX37tGBDQL8Xg 2bcd3c84c84f87eaa86e4e56834c92927a07f9e18718810b92e0d0324456a67c 0
mn1 178.987.98.01:19999 93HaYBVUCYjEMeeH1Y4sBGLALQZE1Yc1K64xiqgX37tGBDQL8Xg 2bcd3c84c84f87eaa86e4e56834c92927a07f9e18718810b92e0d0324456a67c 0

```

-Put your data correctly, save it and close.
-Go to ruxcrypto Wallet, Click Settings, Check “Show Masternodes Tab”
-Save and Restart your wallet.

Note that each line of the masternode.conf file corresponds to one masternode if you want to run more than one node from the same wallet,
just make a new line and repeat steps.

**VPS Setup**

**Preparation:**
-Windows users will need a program called putty to connect to the VPS
-Use SSH to Log into your VPS

We need to install some dependencies. Please copy, paste and hit enter:

`apt-get update;apt-get upgrade; apt-get install nano software-properties-common git wget -y;`

Now Copy command into the VPS command line and hit enter:

`wget https://raw.githubusercontent.com/Toni-d-e-v/Rxc-masternode-setup/master/masternode.sh && chmod +x masternode.sh && ./masternode.sh`


-When prompted, enter your “masternodeprivkey” from before.
-You will be asked for your VPS IP, the port is 11010
-You will be asked a few other questions. Seriously, it's ok just to click enter at the questions
-The installation should finish successfully. Ask for help in discord if it doesn't.

**Troubleshooting  and testing:**

After the script finishes, you will want to check that it is running properly. Please type in:

`ruxcrypto-cli masternode status`

If you get an error about permissions, you just need to kill the process and restart with:

`killall ruxcryptod`

and restart with:

`ruxcryptod -daemon`

If you get an error that file does not exist, it may be that the script failed to build and we need to trace back the problem. Contact devs in discord.

If everything is cool you should see

`"status": "Not capable Masternode Masternode not in Masternode List"`

This is fine because we just started, so don't worry- we just need to start it.

**Starting Your Masternode**

Go back to your desktop wallet, to the Masternode tab.

Now Click “start-all” and your masternode should be now up and running!

You need to wait for 15 confirmations in order to start the masternode- you can also check on your VPS by:

`ruxcrypto-cli masternode status`

**NOTE:** If the Masternode tab isn’t showing, you need to  click settings, check “Show Masternodes Tab” save, and restart the wallet
If your Masternode does not show, restart the wallet
 
**Checking Your Masternode**
You can check the masternode status by going to the wallet console and typing:
 
`masternode status`
 
If your masternode is running it should print “Masternode successfully started”.

you can also check on your VPS by:

`ruxcrypto-cli masternode status`

If your masternode is running it should print "status": "Masternode successfully started"

**WATCHDOG EXPIRED ERROR**
If you get a "WATCHDOG EXPIRED" error, don't worry about this. You just need to let the masternode sync about 30-60 minutes.
Come back after a bit and it should read "PRE ENABLED" in Masternodes tab.

**CONGRATULATIONS!**
 
