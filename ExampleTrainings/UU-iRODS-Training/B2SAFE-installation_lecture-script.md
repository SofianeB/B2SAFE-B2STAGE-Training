# B2SAFE installation

## Prerequisites
- iRODS 4.1.X on an ubuntu 14 server
- Certificates or credentials for a Handle prefix.
 (We will use our test prefix for Handle v8 and the B2HANDLE libarary)
- Adjust the */etc/hosts*
- Install *git*

## Install B2SAFE

- Login
 
 ```sh
 ssh ubuntu@145.100.59.113
 ```
 
- Download the latest version of B2SAFE

 ```sh
 git clone https://github.com/EUDAT-B2SAFE/B2SAFE-core
 cd ~/B2SAFE-core/packaging
 ./create_deb_package.sh
 ```

- Create package

 ```sh
 sudo dpkg -i /home/alice/debbuild/irods-eudat-b2safe_3.1-1.deb
 ```
 
- Configure B2SAFE

 ```sh
 sudo vim /opt/eudat/b2safe/packaging/install.conf
 ```
 - SERVER\_ID=145.100.59.113
 - HANDLE\_SERVER\_URL=https://epic4.storage.surfsara.nl:8007
 - PRIVATE\_KEY=/home/ubuntu/308_21.T12995_USER01_privkey.pem
 - CERTIFICATE\_ONLY=/home/ubuntu/308_21.T12995_USER01_certificate_only.pem
 - PREFIX=21.T12995
 - HANDLEOWNER=200:0.NA/21.T12995
 - REVERSELOOKUP\_USERNAME=21.T12995
 - HTTPS\_VERIFY=false
 - MSIFREE\_ENABLED=false
 - MSICURL\_ENABLED=false

- Run configuration

 ```sh
 sudo su - irods
 cd /opt/eudat/b2safe/packaging/
 ./install.sh
 ```

## Install dependencies

 As user with sudo rights do:
 
 ```sh
 sudo apt-get install python-pip
 sudo pip install queuelib
 sudo pip install dweepy

 sudo apt-get install python-lxml python-defusedxml python-httplib2 python-simplejson
 ```
 
 B2HANDLE:
 
 ```sh
 git clone https://github.com/EUDAT-B2SAFE/B2HANDLE
 cd B2HANDLE/
 python setup.py bdist_egg
 cd dist/
 sudo easy_install b2handle-1.0.3-py2.7.egg
 ```
## Test B2SAFE:
 
 ```sh
 iinit
 cd ~/B2SAFE-core/rules
 irule -vF eudatGetV.r
 irule -vF irule -F eudatCreatePid.r
 ```

## Test PID configuration (if PID creation via iRODS fails)
 
 As user *irods* do:
 
 ```sh
 /opt/eudat/b2safe/cmd/epicclient2.py os /opt/eudat/b2safe/conf/credentials \
 create www.test.com
 ```
  
