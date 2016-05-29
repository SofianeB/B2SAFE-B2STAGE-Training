# Using B2STAGE, hands-on
This section is divided into two parts. In the first part we explain how to install and configure the gridFTP tools to make a connection to an gridFTP-enabled iRODS server.
The second part will take you through the commands how to work on an iRODS system with help of gridFTP and how to combine the gridFTP commands with the icommands to steer your data flow.

## Setup a gridFTP client
### Prerequisites
- Ubuntu 14.04
- Installation of the [icommands](http://irods.org/download/)

### Installation and configuration
To install the client tools you need **sudo-rights** on the machine you are ging to intall them on.

Download the globus tools package and install the *globus-data-management-client*
```sh
wget http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo_latest_all.deb
dpkg -i globus-toolkit-repo_latest_all.deb
apt-get update
apt-get install -y globus-data-management-client
```

#### CA certificate

Copy the *<hash>.0*  and <hash>.signing_policy from the gridFTP server to the user interface

```
sudo mkdir /etc/grid-security/certificates
sudo scp -r alice@<gridFTPserver>:/etc/grid-security/certificates/<hash>.* /etc/grid-security/certificates
```

To connect to the gridFTP server you need a certificate. The admin of the gridFTP server will provide you with two files a *usercert.pem* and a *userkey.pem*. Both need to be saved in:
```sh
mkdir /home/<user>/.globus
```

## Working with gridFTP

### Proxies
To work with gridFTP you need to create a so-called proxy, to this end your *usercert.pem* will be used. The gridFTP client will employ the proxy to execute commands on the gridFTP server on your behalf.

```sh
grid-proxy-init -debug
```

The option *debug* will give you insight in how the proxy is created. At the end of the prompt you will find an expiration time for your proxy. Commands that have not been finished before that time will be cut off and thus fail.

### globus-url-copy
We will work with the *globus-url-copy* command and show you how you can list, add and retrieve files from iRODS with this command.

First let's have a look at what functionality is offered:
```sh
globus-url-copy -help
```

Note, that all commands you issue via this command will be executed as one and the same iRODS user cofigured for the iRODS-DSI module. 
That means, that even if you log in as another irodsuser your data will be deposited as the same user. On our training machines, it is the user *alice*.
To work with gridFTP you might need to set the ACLs with *ichmod* for *alice* to list and copy your files.

### Listings

List the iRODS home collection of the iRODS user *alice*:
```sh
globus-url-copy -vb -ipv6 -list gsiftp://<fqhn_or_ip>/aliceZone/home/alice/
```
[//]: # "The '''/<zone_name>/<collection>/<collection>/``` part below"
[//]: # "does not show in the redendered result. It show '''////``` instead."
Since this GridFTP server is integrated with iRODS, the url to list consists of */zone_name/home/alice/collection/*. Where the collection part is the logical path of the iRODS zone.
**Note**, that you cannot use gridFTP any longer to list, add and fetch data from the normal file system on the iRODS server in this setting. Also note, that all data will be ingested under the user *alice*.


### Uploading data
**Single files**

Single files can be uploaded to iRODS via:
```sh
globus-url-copy -dbg -ipv6 file:/home/alice/test.txt gsiftp://alice.eudat-sara.vm.surfsara.nl/aliceZone/home/alice/
```
This will add *test.txt* to the iRODS collection *alice*. To rename the file in iRODS you can extend the iRODS path pointing to the collection with a filename.

**Exercise: ACLs** Ingest some data in iRODS using gridFTP. Use your iRODS admin account to find where it is ingested to and what the ACLs are. You might need an *iquest* command.

**Exercise: Data collections**

Use the *globus-url-copy* to copy a whole directory to iRODS.
How can you copy a whole subtree?
How can you make sure that the destination collection in iRODS is created properly?

**Exercise: Retrieve data from iRODS**

Use the *globus-url-copy* to retrieve a single file and folder from iRODS.

## GridFTP and B2SAFE
In the previous parts of the tutorial we have seen how we can employ the icommands to ingest data and how to synchronise this data with another iRODS grid using B2SAFE.

**Exercise**
Develop a script that will synchronise a directory tree from your client machine to the gridFTP/iRODS server, which will, when run multiple times, take into account changed and deleted files. 
The script should employ *globus-url-copy*.

* Consult the help on *globus-url-copy* and search for convenient options.
* Synchronise your `gridftp<xyz>` directory on your client machine to `/aliceZone/home/alice/irods<x>/data/`.
* Verify the data is properly updated, think of how to create and employ checksums and where to store them, on the client machine and on the iRODS/gridFTP server.
* Synchronise again and verify no files are transfered.
* Change a file.
* Synchronise again and verify the file is properly updated.

* Extend the script by generating PIDs for the data ingested into iRODS (this can be done manually or by using the B2SAFE rules).
* Trigger the B2SAFE replication to *bob* on the iRODS client.

* Which operations should be executed by a data user and which should be done by a data admin or iRODS admin?

#### Challenge: Using the iRODS server rule engine

A better and more advanced approach is to use the iRODS rule engine to compute checksums and mint PIDs automatically.

For this exercise you will need *system admin* and *irods admin* rights on the iRODS server.

You can find the iRODS server rule engine configuration on the iRODS server here: `/etc/irods/core.re`. 

Some usefull hooks in this context are:

* `acPostProcForPut` - Rule for post processing the put operation.
* `acPostProcForCopy` - Rule for post processing the copy operation.
* `acPostProcForFilePathReg` - Rule for post processing the registration
* `acPostProcForCreate` - Rule for post processing of data object create.
* `acPostProcForOpen` - Rule for post processing of data object open.
* `acPostProcForPhymv` - Rule for post processing of data object phymv.
* `acPostProcForRepl` - Rule for post processing of data object repl.

Make sure to limit the changes to the irods home directory for your user:

```
ON($objPath like "/aliceZone/home/irods<x>/*") {
    # do something useful
}
```
More information on the iRODS microservices: https://docs.irods.org/master/doxygen/

[//]: # "I feel this last bit goes a bit too quickly. All we get here are"
[//]: # "pointers. To me it feels an example is missing, I might be wrong"
[//]: # "of course..."
