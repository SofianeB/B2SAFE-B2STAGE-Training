# Installing the iRODS-DSI
With the iRODS-DSI all commands executed via the gridFTP protocol will be directly forwarded to iRODS. That means that after the installation you will no longer be able to access the normal filesystem via this protocol. 
A full installation and configuration guide is provided [here](https://github.com/EUDAT-B2STAGE/B2STAGE-GridFTP).

## Necessary system packages
```sh
sudo apt-get install libglobus-common-dev 
sudo apt-get install libglobus-gridftp-server-dev 
sudo apt-get install libglobus-gridmap-callout-error-dev
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install build-essential make cmake git
```

## Necessary iRODS packages and code
```sh
mkdir -p ~/iRODS_DSI/deploy
cd ~/iRODS_DSI
wget ftp://ftp.renci.org/pub/irods/releases/4.1.8/ubuntu14/irods-dev-4.1.8-ubuntu14-x86_64.deb
sudo dpkg -i irods-dev-4.1.8-ubuntu14-x86_64.deb
wget ftp://ftp.renci.org/pub/irods/releases/4.1.8/ubuntu14/irods-runtime-4.1.8-ubuntu14-x86_64.deb
sudo dpkg -i irods-runtime-4.1.8-ubuntu14-x86_64.deb
sudo apt-get update
```

```sh
git clone https://github.com/EUDAT-B2STAGE/B2STAGE-GridFTP.git
```

### Installation
```sh
cp setup.sh.template setup.sh
```

Edit the *setup.sh*, minimal setup:

```sh
export GLOBUS_LOCATION="/usr"
export IRODS_PATH="/usr"
export DEST_LIB_DIR="/home/alice/iRODS_DSI"
export DEST_BIN_DIR="/home/alice/iRODS_DSI"
export DEST_ETC_DIR="/home/alice/iRODS_DSI"
```
and install:

```sh
source setup.sh
cmake CMakeLists.txt
make
```

### Configuration
All commands coming from gridFTP entering iRODS will be executed as the same irods user. This userprofile is defined under *root*:

```sh
sudo su -
root@iRODS4:~# mkdir .irods
vim ~/.irods/irods_environment.json
{
"irods_host" : "localhost",
"irods_port" : 1247,
"irods_user_name" : "alice",
"irods_zone_name" : "alicetestZone",
"irods_default_resource" : "demoResc"
}
```

Add the following to your */etc/gridftp.conf* file:
```sh
# globus-gridftp-server configuration file

# this is a comment

# option names beginning with '$' will be set as environment variables, e.g.
$GLOBUS_ERROR_VERBOSE 1
$GLOBUS_TCP_PORT_RANGE 50000,51000

# port
port 2811

#iRODS connection
$LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/home/alice/iRODS_DSI/B2STAGE-GridFTP/"
$irodsConnectAsAdmin "rods"
load_dsi_module iRODS
auth_level 4
```
and add the line below to */etc/init.d/globus-gridftp-server*:
```sh
LD_PRELOAD="$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libglobus_gridftp_server.so:/home/alice/iRODS_DSI/B2STAGE-GridFTP/libglobus_gridftp_server_iRODS.so"
export LD_PRELOAD
```

Restart the gridFTP server:
```sh
/etc/init.d/globus-gridftp-server restart
```

### Testing the iRODS-DSI
As a user initialise a proxy

```sh
grid-proxy-init
```

List data in the user's iRODS home collection:
- Listing
```sh
alice@irods4:~$ globus-url-copy -list gsiftp://alice.eudat-sara.vm.surfsara.nl/aliceZone/home/alice/
```

The output should look like this:
```
gsiftp://irods4-alicetest.eudat-sara.vm.surfsara.nl/alicetestZone/home/alice/
put1.txt
put2.txt
test.txt
DataCollection/
DataTrunk/
testData/
```

### Debug information
When you are using a grid certificate mapping to a linux user that is called differently than the default irods user in */root/.irods/irods_environment* or */var/lib/irods/.irods/irods_environment.json* you will encounter ther following error:

```
530-Login incorrect. : /home/ubuntu/iRODS_DSI/B2STAGE-GridFTP/DSI/globus_gridftp_server_iRODS.c:globus_l_gfs_iRODS_make_error:579:
530-iRODS DSI. Error: 'clientLogin' failed.. CAT_INVALID_AUTHENTICATION: , status: -826000.
530-
530 End.
```

One solution is to to create an irods admin with the same user name as the linux account the certificate is mapped to and update the *irods_environment* files.
I.e. if your grid certificate is mapped to *admin*, but your iRODS user is *alice*, do:
- Create an iRODS account *admin*
```
iadmin mkuser admin rodsadmin
iadmin moduser admin password ***
```
- Update the */root/.irods/irods_environment*:
```
{
"irods_port": 1247,
"irods_host": "localhost",
"irods_user_name": "admin",
"irods_zone_name": "aliceZone"
}
```
- Update the */var/lib/irods/.irods/irods_environment.json*:
```
"irods_home": "/aliceZone/home/admin",
"irods_cwd": "/aliceZone/home/admin",
"irods_user_name": "admin",
```
- Restart the gridFTP server directly under root and not via sudo.