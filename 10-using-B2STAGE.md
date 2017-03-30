# Using B2STAGE, hands-on
This section is divided into two parts. In the first part we explain how to install and configure the gridFTP tools to make a connection to an gridFTP-enabled iRODS server.
The second part will take you through the commands how to work on an iRODS system by means of gridFTP and how to combine the gridFTP commands with the icommands to steer your data flow.

## Setup a gridFTP client
If you are working on one of the provisioned user interface machines, please skip this section.

### Prerequisites
- Ubuntu 14.04
- Installation of the [icommands](http://irods.org/download/)

### Installation and configuration
To install the client tools you need **sudo-rights** on the machine you are ging to intall them on.

Download the globus tools package and install the *globus-data-management-client*
```sh
wget http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo_latest_all.deb
sudo dpkg -i globus-toolkit-repo_latest_all.deb
sudo apt-get update
sudo apt-get install -y globus-data-management-client
```

### Installing *uberftp*

The uberFTP client provides some more handy functionality like bulk removal of data that is complementary to the functionality the globus-tools offer.

```sh
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:maarten-kooyman-6/ppa
sudo apt-get update
sudo apt-get install uberftp 
```

### CA certificate

Copy the *<hash>.0*  and <hash>.signing_policy from the gridFTP server to the user interface

```
sudo mkdir /etc/grid-security/certificates
sudo scp -r alice@<gridFTPserver>:/etc/grid-security/certificates/<hash>.* /etc/grid-security/certificates
```

To connect to the gridFTP server you need a certificate. The admin of the gridFTP server will provide you with two files a *usercert.pem* and a *userkey.pem*. Both need to be saved in:
```sh
mkdir /home/<user>/.globus
```

## Hostname resolving
To map the actual server name and the distinguished name of the gridFTP server you can adjust the */etc/hosts*. Here we show an example:
```sh
<ip.add.re.ss>   localname of the gridFTP server
<fqdn>           localname of the gridFTP server
```
This enables you to access the gridFTP server by its, in most cases, shorter full name or IP address.

## Working with gridFTP

### Proxies
To work with gridFTP you need to create a so-called proxy, to this end your *usercert.pem* will be used. The gridFTP client will employ the proxy to execute commands on the gridFTP server on your behalf.

```sh
grid-proxy-init -debug
```

The option *debug* will give you insight in how the proxy is created. At the end of the prompt you will find an expiration time for your proxy. Commands that have not been finished before that time will be cut off and thus fail.

On the gridFTP server your certificate is mapped to a certain **iRODS user** under which you can managae your data.

### globus-url-copy
We will work with the *globus-url-copy* command and show how you can do simple data operations like list, add and retrieve files from iRODS with this command.

First let's have a look at which functionalities are offered:
```sh
globus-url-copy -help
```

### Listings

List the iRODS home collection of the iRODS user *alice*:
```sh
globus-url-copy -vb -ipv6 -list gsiftp://<fqdn>/aliceZone/home/alice/
```
[//]: # "The '''/<zone_name>/<collection>/<collection>/``` part below"
[//]: # "does not show in the redendered result. It show '''////``` instead."
Since this GridFTP server is integrated with iRODS, the url to list consists of */zone_name/home/alice/collection/*. Where the collection part is the logical path of the iRODS zone.
**Note**, that you cannot use this gridFTP instance any longer to list, add and fetch data from the normal file system on the server in this setting. Try to list the folder */tmp* on the gridFTP server:

```sh
globus-url-copy -vb -ipv6 -list gsiftp://<fqdn>/tmp/
gsiftp://<fqdn>/tmp/


error: globus_ftp_client: the server responded with an error
500 500-Command failed. : /home/alice/iRODS_DSI/B2STAGE-GridFTP/DSI/globus_gridftp_server_iRODS.c:globus_l_gfs_iRODS_make_error:579:
500-iRODS DSI. Error: No such file or directory.. USER_FILE_DOES_NOT_EXIST: , status: -310000.
500-
500 End.
```

### Data management in iRODS with gridFTP
**Single files**

Single files can be uploaded to iRODS via:
```sh
globus-url-copy -dbg -ipv6 file:/home/alice/test.txt gsiftp://<fqdn>/aliceZone/home/alice/
```
This will add *test.txt* to the iRODS collection *alice*. To rename the file in iRODS you can extend the iRODS path pointing to the collection with a filename.

**Exercise: ACLs** Ingest some data in iRODS using gridFTP. Use your iRODS (admin) account to find out where the files are located on the server and which the ACLs are set. You might need an *iquest* command.

**Exercise: Data collections**

Use the *globus-url-copy* to copy a whole directory to iRODS.
How can you copy a whole subtree?
How can you make sure that the destination collection in iRODS is created properly?
How can you delete a whole directory (or iRODS collection) using gridFTP?

**Exercise: Retrieve data from iRODS**

Use the *globus-url-copy* to retrieve a single file and folder from iRODS.

## GridFTP and B2SAFE
In the previous parts of the tutorial we have seen how we can employ the icommands to ingest data and how to synchronise this data with another iRODS grid using B2SAFE.

**Exercise: Synchronising collections**
Develop a script that will synchronise a directory tree on your client machine with the gridFTP/iRODS server. The script should only process changed and deleted files when run several times.

* Consult the help on *globus-url-copy* and search for convenient options.
* Synchronise your `gridftp<xyz>` directory on your client machine to */aliceZone/home/alice/irods<x>/data/* on the iRODS server.
* Verify that the data is properly updated, think of how to create and employ checksums and where to store them, on the client machine and on the iRODS/gridFTP server.
* Synchronise again and verify no files are transfered.
* Change a file.
* Synchronise again and verify the file is properly updated.

**Exercise: Data management with PIDs**
* Extend the script by generating PIDs for the data ingested into iRODS (this can be done manually or by using the B2SAFE rules).
* Trigger the B2SAFE replication to the iRODS server *bob*.
* (Optional) If you use your own iRODS/B2SAFE instances, try to automatically trigger the B2SAFE rules upon certain actions.

* Which operations should be executed by a data user and which should be done by a data admin or iRODS admin?

#### Challenge: Using the iRODS server rule engine to execute data policies
For this challenge you need admin rights on the gridFTP/iRODS server.

An advanced approach is to use the iRODS rule engine to compute checksums and mint PIDs automatically. To this end you will use iRODS event hooks to trigger certain actions when data is ingested into a certain collection. If a user adds or changes data in this collection, these actions will be automatically executed.
You can find the iRODS server rule engine configuration on the iRODS server here: */etc/irods/core.re*. 
Some usefull event hooks are:

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

## B2STAGE and iRODS federations
With iRODS you can easily access data in another zone with:
```sh
ils /bobZone/home/alice#aliceZone/
```
The *globus-url-copy* client however, will not understand the path due to the sign '#':
```sh
globus-url-copy -list gsiftp://eudat-training2/bobZone/home/alice#aliceZone/
gsiftp://eudat-training2/bobZone/home/alice#aliceZone/


error: globus_ftp_client: an invalid value for url was used
```
You can use the *uberFTP* client instead:
```sh
berftp -ls gsiftp://eudat-training2/bobZone/home/alice#aliceZone/
drwxr-xr-x   0     root     root            0 Jan  1 00:00 .
drwxr-xr-x   0     root     root            0 Jan  1 00:00 ..
-rwxr-xr-x   0     root     root           28 Jan 18 13:08 FileFromAlice.txt
```

Another way to solve this issue is to wrap your remote iRODS path with a PID:
With B2HANDLE you can wrap the path `sh irods://130.186.13.14:1247/bobZone/home/alice#aliceZone/testfile-New.txt` with a PID, e.g.
*21.T12995/eb179104-de28-11e6-911a-fa163edb14ff* and access the file with the *globur-url-copy* client:

```
globus-url-copy -list gsiftp://eudat-training2/21.T12995/eb179104-de28-11e6-911a-fa163edb14ff/
gsiftp://eudat-training2/21.T12995/eb179104-de28-11e6-911a-fa163edb14ff/
    testfile-New.txt
```
**Note**, that the URL field in the PID needs to start with *irods*, contains the fully qualified domain name of the gridFTP server that is coupled to the iRODS instance and not the *remote* irods instance.

# Trouble shooting
When you work with servers in different time zones you might encounter tghis error when you try to reach the gridFTP server:

```sh
user@ubuntu:~$ globus-url-copy -list gsiftp://<fqdn>/aliceZone/home/alice/
gsiftp://<fqdn>/aliceZone/home/alice/


error: globus_ftp_client: the server responded with an error
530 530-globus_xio_gssapi_ftp.c:globus_l_xio_gssapi_ftp_decode_adat:856:
530-Authentication Error
530-GSS Major Status: Authentication Failed
530-accept_sec_context.c:gss_accept_sec_context:180:
530-SSLv3 handshake problems
530-globus_i_gsi_gss_utils.c:globus_i_gsi_gss_handshake:1018:
530-Unable to verify remote side's credentials
530-globus_i_gsi_gss_utils.c:globus_i_gsi_gss_handshake:991:
530-SSLv3 handshake problems: Couldn't do ssl handshake
530-OpenSSL Error: s3_srvr.c:3279: in library: SSL routines, function SSL3_GET_CLIENT_CERTIFICATE: no certificate returned
530-globus_gsi_callback.c:globus_gsi_callback_handshake_callback:539:
530-Could not verify credential
530-globus_gsi_callback.c:globus_i_gsi_callback_cred_verify:762:
530-The certificate is not yet valid: Cert with subject: /O=Grid/OU=GlobusTest/OU=simpleCA-irods4.eve/OU=Globus Simple CA/CN=eve/CN=33477151 is not yet valid- check clock skew between hosts.
530 End.
```

This can be helped by synchronising the two machines. Run 
```sh
sudo ntpdate -s ntp1.nl.uu.net
```
on both of them.

[]()|[]()|[]()
----|----|----
[Previous](https://github.com/EUDAT-Training/B2SAFE-B2STAGE-Training/blob/master/09-install-B2STAGE.md)|[Index](https://github.com/EUDAT-Training/B2SAFE-B2STAGE-Training)  | **The end**
