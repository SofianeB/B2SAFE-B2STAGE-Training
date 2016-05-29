# Installation of B2STAGE

In the previous examples we showed how to ingest data into iRODS via the icommands. To transfer large data EUDAT offers the possibility to employ gridFTP to directly enter data into an iRODS zone.
Here we show how to setup a gridFTP endpoint on top of an iRODS server and how to connect the gridFTP endpoint to iRODS.

## Environment
- Ubuntu 14.04 srever
- iRODS 4.1.X server

## Prerequisites
### 1. Update and upgrade if necessary
```sh
apt-get update
apt-get upgrade
```
### 2. Set firewall
```sh
sudo apt-get install iptables-persistent
```
- open ports 2811 and 50000-51000 in /etc/iptables/rules.v4
```sh
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [4538:480396]
-A INPUT -m state --state INVALID -j DROP
-A INPUT -p tcp -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -m state --state NEW -j DROP
-A INPUT -f -j DROP
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP
-A INPUT -p icmp -m limit --limit 5/sec -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 1248 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 1247 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 20000:20199 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 4443 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 2811 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 50000:51000 -j ACCEPT
-A INPUT -j LOG
-A INPUT -j DROP
COMMIT
```

```sh
/etc/init.d/iptables-persistent restart
```
 
 To ensure the mapping from IP to hostname you might have to edit the */etc/hosts*:
```sh
hostname
echo "your.ip.num.ber <yourhostname>" >> /etc/hosts
```

## Installing the globus toolkit
- Download the package
```sh
wget http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo_latest_all.deb
sudo dpkg -i globus-toolkit-repo_latest_all.deb
sudo apt-get update
```
- Install globus-data-management-client, globus-gridftp, globus-gsi
```sh
sudo apt-get install globus-data-management-client globus-gridftp globus-gsi
```

## Creating a certificate authority (CA) on the server
- Become root and install a simple ca.
```sh
sudo su -
cd /root/
grid-ca-create
```
 Follow the prompt.

- Create symlinks in */etc/grid-security*:
```sh
cd /etc/grid-security
```
```sh
ln -s /var/lib/globus/simple_ca/grid-security.conf grid-security.conf
ln -s /var/lib/globus/simple_ca/globus-host-ssl.conf  globus-host-ssl.conf
ln -s /var/lib/globus/simple_ca/globus-user-ssl.conf  globus-user-ssl.conf
```

- Request a host certificate and sign it:
```sh
grid-cert-request -host <fully.qualified.hostname> -force
```
 Make sure *\<fully.qualified.hostname\>* matches the way how to call the server from outside to transfer data.
 If you use a different hostname, users will have to add the mapping from IP to the hostname in their */etc/hosts* on their client machine.

 Sign the certificate, check it and restart the gridFTP server
```sh
grid-ca-sign -in /etc/grid-security/hostcert_request.pem -out /etc/grid-security/hostcert.pem
openssl x509 -in /etc/grid-security/hostcert.pem -text -noout
/etc/init.d/globus-gridftp-server restart
```

## Creating user certificates and editing the gridmap file
Users need to have an own user certificate in order to transfer data to the gridFTP endpoint. This is how you create and sign a user certificate.
- As root create a user certificate:
```sh
grid-cert-request 
grid-ca-sign -in /root/.globus/usercert_request.pem -out /root/.globus/usercert.pem
```
- Send the *usercert.pem* and the *userkey.pem* to the user. The user should store these two documents in */home/user/.globus/*.

- Add the subject of the user to the gridmap file
```sh
grid-cert-info -subject
grid-mapfile-add-entry -dn "/O=Grid/OU=GlobusTest/OU=simpleCA-irods4.alicetest/OU=Globus Simple CA/CN=alice" -ln alice
```
 The flag *-ln* specifies a user on your linux system.

## Testing the gridFTP endpoint
- Switch to a user on your gridFTP server and copy the user certificate and key to the */home/<user>/.globus* directory
```sh
mkdir .globus
cd .globus
```
- Make sure the certificates belong to *alice*
```
sudo chown alice:alice *
```
- Initialise a proxy
```sh
grid-proxy-init
```

T- ry to list the */tmp* directory via gridFTP and create and copy a file to that directory
```sh
globus-url-copy -dbg -list gsiftp://irods4-alicetest.eudat-sara.vm.surfsara.nl/tmp/
echo "kjsbdj" > /home/alice/test.txt
globus-url-copy file:/home/alice/test.txt gsiftp://irods4-alicetest.eudat-sara.vm.surfsara.nl/tmp/test.txt
```

## Installing the iRODS-DSI
With the iRODS-DSI all commands executed via the gridFTP protocol will be directly forwarded to iRODS. That means that after the installation you will no longer be able to access the normal filesystem via this protocol. 
A full installation and configuration guide is provided [here](https://github.com/EUDAT-B2STAGE/B2STAGE-GridFTP).

### Necessary system packages
```sh
sudo apt-get install libglobus-common-dev 
sudo apt-get install libglobus-gridftp-server-dev 
sudo apt-get install libglobus-gridmap-callout-error-dev
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install build-essential make cmake git
```

### Necessary iRODS packages and code
```sh
mkdir -p ~/iRODS_DSI/deploy
cd ~/iRODS_DSI
wget ftp://ftp.renci.org/pub/irods/releases/4.1.6/ubuntu14/irods-dev-4.1.6-ubuntu14-x86_64.deb
sudo dpkg -i irods-dev-4.1.6-ubuntu14-x86_64.deb
wget ftp://ftp.renci.org/pub/irods/releases/4.1.6/ubuntu14/irods-runtime-4.1.6-ubuntu14-x86_64.deb
sudo dpkg -i irods-runtime-4.1.6-ubuntu14-x86_64.deb
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



















