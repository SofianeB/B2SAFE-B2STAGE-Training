# Installation of iRODS 4.1
This document describes how to install iRODS4.1 on a Ubuntu machine with a postgresql 9.3 database as iCAT.

## Environment
Ubuntu 14.04 server

##Prerequisites
### 1. Update and upgrade if necessary
```sh
apt-get update
apt-get upgrade
```
### 2. Set firewall
```sh
sudo apt-get install iptables-persistent
```
- edit /etc/iptables/rules.v4
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
-A INPUT -j LOG
-A INPUT -j DROP
COMMIT
```
- edit /etc/iptables/rules.v4
```sh
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -j DROP
COMMIT
```

```sh
/etc/init.d/iptables-persistent start
```

### 3. Create admin user for machine and irods
```sh
adduser irodsadmin
```
### (Optional)
To change the linux username (useful when working with VM templates and creatign several users)
```sh
usermod -l alice irodsadmin
groupmod -n alice irodsadmin
usermod -d /home/alice -m alice
usermod -c alice alice
```
Add newuser to sudoers

### 4. Install postgresql
```sh
sudo apt-get install postgresql
```

### 5. Set host name

```sh
hostnamectl <set-hostname> <new-hostname>
echo "IPa.ddr.ess <new-hostname>" >> /etc/hosts
```

## Installing iRODS
### 6. Configure and create porstgresql database
```sh
sudo su - postgres
psql
CREATE DATABASE "ICAT";
CREATE USER irods WITH PASSWORD 'irods';
GRANT ALL PRIVILEGES ON DATABASE "ICAT" to irods;
\q
exit
```
### 7. Download and install iRODS packages
```sh
wget ftp://ftp.renci.org/pub/irods/releases/4.1.6/ubuntu14/irods-icat-4.1.6-ubuntu14-x86_64.deb
wget ftp://ftp.renci.org/pub/irods/releases/4.1.6/ubuntu14/irods-database-plugin-postgres-1.6-ubuntu14-x86_64.deb
```

```sh
sudo dpkg -i irods-icat-4.1.6-ubuntu14-x86_64.deb irods-database-plugin-postgres-1.6-ubuntu14-x86_64.deb
```
This will exit with the following error message:
```sh
dpkg: dependency problems prevent configuration of irods-icat:
...
Errors were encountered while processing:
 irods-icat
 irods-database-plugin-postgres
```
The dependencies will be fixed by executing:
```sh
sudo apt-get -f install
```

### 8. Configuring iRODS
- First we create the irods vault (where data put into iRODS will be physically stored).
```sh
sudo mkdir /irodsVault 
sudo chmod 777 /irodsVault
```

- Configure iRODS
```sh
sudo /var/lib/irods/packaging/setup_irods.sh
```

```sh
iRODS servers zone name [tempZone]: alicetestZone
iRODS Vault directory [/var/lib/irods/iRODS/Vault]: /irodsVault
iRODS servers zone_key [TEMPORARY_zone_key]: alicetest_zone_key
iRODS servers administrator username [rods]: alice
Database servers hostname or IP address: localhost
```

### 9. Login to iRODS

```sh
iinit
```

```sh
Enter the host name (DNS) of the server to connect to: localhost
Enter the port number: 1247
Enter your irods user name: alice
Enter your irods zone: alicetestZone
```
- Test whether you can list your iRODS directory
```sh
ils
```

### Additional Server configuration
iRODS creates a lot of log files, which are not cleaned up automatically. To do so start a cron-job:
```
sudo vim /etc/cron.d/irods
```
Add
```
# cleanup old logfiles older than 14 days
11      1       *       *       *       root    find /var/lib/irods/iRODS/server/log/{re,rods}Log.* -mtime +14  -exec rm {} \;
```
to the file. 
Now root will delete all reLog and rodsLog files that are older than 14 days. The command will be executed everyday at 11.01am.


