# Installation of B2SAFE 2
This document describes how to install B2SAFE 2 with iRODS4.1 on a Ubunutu 14.04 system.

## Environment
Ubuntu 14.04 server, iRODS 4.1 with postgresql 9.3
You will also need a handle prefix and the respective credentials to configure B2SAFE.

##Prerequisites
For a comprehensive documentation please refer to https://github.com/EUDAT-B2SAFE/B2SAFE-core/wiki.

- Install git:
 ```sh
 sudo apt-get install git
 ```

- Obtain a (test) prefix to create PIDs. 
 For a prefix for the **Handle server v7** you will be provided with a prefix and a password. When working with **Handle server v8** you will be provided with certficates (private key and certificate) and a password for the reverse lookup servelet.
 
### 1. Clone code and create packages
- Clone the github repository of B2SAFE and create the debian package

 ```sh
 git clone https://github.com/EUDAT-B2SAFE/B2SAFE-core
 cd ~/B2SAFE-core/packaging
 ./create_deb_package.sh
 ```
- PID configuration with *epicclient.py*
If you do not want to add the trusted CA of the epic server to your trusted CAs you need to edit the B2SAFE-core/cmd/epicclient.py:

 ```py
 self.http = httplib2.Http(disable_ssl_certificate_validation=True)
 ```

- PID configuration with epicclient2.py
The SSL verfication is given as a parameter in the *credentials* file (see below CRED_FILE_PATH).

- Install the created package as *root*
 ```sh
 sudo dpkg -i /home/alice/debbuild/irods-eudat-b2safe_3.1-1.deb
 ```
### 2. Configure B2SAFE
```sh
The package b2safe has been installed in /opt/eudat/b2safe.
To install/configure it in iRODS do following as the user who runs iRODS :

# update install.conf with correct parameters with your favorite editor
sudo vi /opt/eudat/b2safe/packaging/install.conf

# install/configure it as the user who runs iRODS
source /etc/irods/service_account.config
sudo su - $IRODS_SERVICE_ACCOUNT_NAME -s "/bin/bash" -c "cd /opt/eudat/b2safe/packaging/ ; ./install.sh"
```
We need to pass some parameters that B2SAFE will use to craete the credentials json file to connect to the Handle server to create PIDs.

When working with the **epicclient.py** you need to fill in the following parameters:
- SERVER_ID: The fully qualified name of your server or IP address. Note, that when you also plan to install B2STAGE, the server ID has to match the known hostname of your gridFTP instance.
- BASE_URI: The handle server that hosts your handle prefix. Here we use *https://epic3.storage.surfsara.nl/v2_test/handles/*
- USERNAME: This is your handle prefix
- PREFIX: This is also your handle prefix
- CRED_FILE_PATH: The json credentials file to connect to the Handle server

The resulting json file after the configuration should look like this:
```sh
{
    "handle_server_url": "https://epic3.storage.surfsara.nl:8001",
    "prefix": "841",
    "handleowner": "200:0.NA/841",
    "reverse_username": "841",
    "reverse_password": "XXX",
    "HTTPS_verify": "False",
    "overwrite": "True" 
}
```

If you are using **the B2HANDLE library and epicclient2.py** you need to fill in the following:
- PRIVATE_KEY: Path to the respective pem-file
- CERTIFICATE_ONLY: Path to the respective pem-file (make sure the linux user *irods* has access to these files)
- REVERSELOOKUP_USERNAME: Usually your prefix
- HTTPS_VERIFY: If you did not install the handle servers certificates, set this variable to "False".

The resulting json file should look like this:
```sh
{
    "handle_server_url": "https://epic4.storage.surfsara.nl:8007",
    "baseuri": "https://epic4.storage.surfsara.nl:8007",
    "private_key": "/<path>/<to>/308_21.T12995_USER01_privkey.pem",
    "certificate_only": "/<path>/<to>/308_21.T12995_USER01_certificate_only.pem",
    "prefix": "21.T12995",
    "handleowner": "200:0.NA/21.T12995",
    "reverselookup_username": "21.T12995",
    "reverselookup_password": "XXX",
    "HTTPS_verify": "False"
}
```

For a testing server you might want to set *AUTHZ_ENABLED* and *MSIFREE_ENABLED* to false.

### 3. Python dependencies
- Check dependencies

 ```sh
 cd /opt/eudat/b2safe/cmd
 ./authZmanager.py -h
 ./logmanager.py -h
 ./messageManager.py -h
 ./metadataManager.py -h
 ```
 ```sh
 ./epicclient.py --help
 ```
 or
 ```sh
 ./epicclient2.py --help
 ```


- Known dependencies

 ```sh
 sudo apt-get install python-pip
 sudo pip install queuelib
 sudo pip install dweepy

 sudo apt-get install python-lxml
 sudo apt-get install python-defusedxml
 sudo apt-get install python-httplib2

 sudo apt-get install python-simplejson
 ```
- B2HANDLE python library

 Install as user with sudo rights
 
 ```sh
 git clone https://github.com/EUDAT-B2SAFE/B2HANDLE
 cd B2HANDLE/
 python setup.py bdist_egg
 cd dist/
 sudo easy_install b2handle-1.0.3-py2.7.egg
 ```

### 4. Tests
#### B2SAFE installation
```sh
iinit
cd ~/B2SAFE-core/rules
irule -vF eudatGetV.r
```
 should return
```sh
*version = 3.1-0
```

####Generating PIDs
- Test the epicclient.py:
 ```sh
 sudo su - irods
 /opt/eudat/b2safe/cmd/epicclient.py os /opt/eudat/b2safe/conf/credentials create www.test.com
 ```
- Test the epicclient2.py:
 
 ```sh
 sudo su - irods
 /opt/eudat/b2safe/cmd/epicclient2.py os /opt/eudat/b2safe/conf/credentials create www.test.com
 ```
 
- Execute the test rules:
 ```sh
 irule -F eudatCreatePid.r
 irule -F eudatRepl_coll.r
 ...
 ```
 
 **Exercise**:
 Alter the test rules in *rules* such that a real folder is assigned with PIDs and replicated to another folder on that iRODS instance. 
 
