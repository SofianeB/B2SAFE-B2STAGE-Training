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
mkdir -p ~/iRODS_DSI
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
"irods_host" : "<fully-qualified-hostname>",
"irods_port" : 1247,
"irods_user_name" : "alice",
"irods_zone_name" : "alicetestZone",
"irods_default_resource" : "demoResc"
}
```
Note, that when you copy an irods environment file over or when you create this file with *iinit* the value *irods_default_resource* is not automatically set. However, the iRODS-DSI is dependent on this value and not setting it will cause unpredictable errors.

Do an 
```sh
iinit
```
to create the password-hash that will be used later to automatically authenticate with iRODS.

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
$LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/home/alice/iRODS_DSI/"
$irodsConnectAsAdmin "rods"
load_dsi_module iRODS
auth_level 4
```
and add the line below to */etc/init.d/globus-gridftp-server*:
```sh
LD_PRELOAD="$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libglobus_gridftp_server.so:/home/alice/iRODS_DSI/libglobus_gridftp_server_iRODS.so"
export LD_PRELOAD
```

Restart the gridFTP server:
```sh
/etc/init.d/globus-gridftp-server restart
```

### Enabling PID resolution on the server
The iRODS-DSI supports accessing data in iRODS with their PID like:
```sh
eve@eve:~$ globus-url-copy -list gsiftp://alice.eudat-sara.vm.surfsara.nl/846/70c2995c-2d80-11e6-acfc-04040a64008f/
gsiftp://alice.eudat-sara.vm.surfsara.nl/846/70c2995c-2d80-11e6-acfc-04040a64008f/
    file.txt
```
To enable this feature simply add

```sh
#Resolution of PIDs
$pidHandleServer "http://<handle-server>:<port>/api/handles"
```
E.g.
```sh
$pidHandleServer "http://epic3.storage.surfsara.nl:8001/api/handles"
```
to your *gridftp.conf* and restart the gridFTP server.


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
gsiftp://irods4-alicetest.eudat-sara.vm.surfsara.nl/aliceZone/home/alice/
put1.txt
put2.txt
test.txt
DataCollection/
DataTrunk/
testData/
```

### Debug information
When the gridFTP server is run under root and you restart the server using *sudo* under an admin user you will encounter this error after restarting the gridFTP server:
```
alice@ubuntu:~/iRODS_DSI/B2STAGE-GridFTP$ globus-url-copy -list gsiftp://alice.eudat-sara.vm.surfsara.nl/aliceZone/home/alice/
gsiftp://aliceZone.eudat-sara.vm.surfsara.nl/aliceZone/home/


error: globus_ftp_client: the server responded with an error
530 530-Login incorrect. : /home/alice/iRODS_DSI/B2STAGE-GridFTP/DSI/globus_gridftp_server_iRODS.c:globus_l_gfs_iRODS_make_error:579:
530-iRODS DSI. Error: 'clientLogin' failed.. CAT_INVALID_AUTHENTICATION: , status: -826000.
530-
530 End.
```

You need to restart the gridFTP server directly under root and not via sudo.
