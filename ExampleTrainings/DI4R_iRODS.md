# What will we learn?
- Use iRODS to upload, manage and annotate data
- Steer dataflows between iRODS instances with the iRODS native icommands
- Do automatic data replication between iRODS servers with the B2SAFE module
- Steer data between our laptop/userinterface and iRODS with gridFTP
- Execute third party transfers with gridFTP between a gridFTP enabled iRODS server and a 'normal' gridFTP server

# iRODS and B2SAFE
## Login
You login to iRODS with the command
```
iinit
```
You will be asked for the iRODS server you would like to connect to the port (standard 1247), the zone name of the iRODS server, your iRODS user name and password.

## Basic commands
First we will have a look at some very basic commands to move through the logical namespace in iRPDS. The basic commands in iRODS are very similar to bash/shell commands.
You can browse through your coollections with:
```
ils
```
To change the current working directory do:
```
ipwd
icd /aliceZone/home/<username>/<collection>
ipwd
```
And you can create new collections with:
```
imkdir
```

You can get a full list of all commands with:
```
ihelp
```
If you are unsure how to use a command or what options there are, call the help:
```
<command> -h
```

## Logical and physical namespaces in iRODS
The *ils* command gives you an option to extract the physical location of a file:
```
ils -L
```
We will use this command quite often today to see what happens with files upon replication.
With this command you see where the file is stored on the iRODS server.

## Uploading a Collection to iRODS
First let's create some data in our home directory on the linux filesystem to upload to iRODS
```
mkdir -p Collection
for i in {000..002}; do echo "Collection${i} and some text.">"Collection/File${i}.txt"; done
```

Now upload the collection to iRODS:
```
iput -r -K Collection
```
The option *K* triggers the calculation of checksums and verifies them upon upload.
Check with 
```
ils Collection -L
```
You will see some output like:
```
alice               0 demoResc           29 2016-08-23.09:04 & File000.txt
    9dcbb372c049bdd4b035c1ccb3798e69    generic    /irodsVault/home/eve/Collection/File000.txt
```
* *alice* is the data owner
* *0* is the index of this replica. the number only refers to replicas in one iRODS zone and can be used to autpmatically trim the number of replicas or create new ones in case one got lost.
* *demoResc* is the resource on which the data is stored. Resources can refer to certain paths on the iRODS server or other storage servers and clusters.
* The next entry is the time of the upload and the file name
* the follwing entry is the checksum, in our case it is a MD5 sum
* The last entry is the physical path of the data, in our case the data lies on the iRODS server.

**Exercise**
Explore the command *iget* to store the data back in you home directory. Do not overwrite your original data!

## Replication across iRODS Zones
To keep data safe you sometimes want to store them at a different site belonging to a different administrative unit. iRODS offers to federate iRODS Zones for specific users.
In our little example we set up such a federation.

Remember: to check what data we have stored in our iRODS home collection we used
```
ils 
```
and it listed automatically all data in */aliceZone/home/<user>*.

To access data on the other iRODS server type in:
```
ils /bobZone/home/<user>#aliceZone/home/<user>
```
* *bobZone* denotes the zone on the different server, they are really physically different machines and they run their own iCAT data base
* Your username needs to be extended with *#aliceZone* to indicate that on bobZone you are a remote user
* Authentication: You authenticate with your iRODS instance. System administrators at the other iRODS instance added you as a remote users and your corresponding rights.

### Manual replication to a different iRODS zone
You can use the same commands as above to steer and browse through your home Collection in BobZone. However, you cannot use *iput* to upload data there.
The corresponding command is *irsync*

**Exercise** transfer one file from your *Collection* to bobzone using *irsync*
```
irsync i:<path/file> i:<path/file>
ils /bobZone/<path-to-file> -L
```
The *i* indicates that the file lies in the iRODS logical namespace.
Obviously bobZone uses a different default checksum algorithm.

### Automatic replication with B2SAFE
To understand B2SAFE we first need to see what iRODS rules are.
### iRODS rules 
We have seen that we can replicate data to a different Zone. Now we want to be sure that we can track replicated files, replicate files and collections upon change and we want automatise everything as much as possible. Here, we will make use of iRODS rules.
iRODS rules are short procedure or functions with an own syntax.

Open the file *examples/hello.r*

```
HelloWorld{
    if(*name=="<YourName>"){
        writeLine("stdout", "Hello *name!");
        }
    else { writeLine("stdout", "Hello world!"); }
}
INPUT *name="YourName"
OUTPUT ruleExecOut, *name
```
Replace *YourName* with your name, once in the if statement and if you wish also in the line starting with *INPUT*.

* You can specify the value of parameters in INPUT
* ruleExecOut is the standard output, here the variable *name* is returned too.
Safe the file as *hello.r* somewhere in your account and execute the following command:

```
irule -F hello.r
```

#### B2SAFE
B2SAFE is a ruleset that extends the core rule set of iRODS and provides tools to replicate data and keep track of the replicas by creating persistent identifiers and leaving additional information in the iCAT database.

We will use B2SAFE to replicate our Collection to bobZone, create PIDs for the original data in eveZone, create PIDs for the replicas in bobZone and link the files on PID level.

First let us inspect and adapt the corresponding rule in examples/eudatRepl.r .
```
eudatRepl{
    # Data set replication
    # registered data (with PID registration) (3rd argument - 1st bool("true"))
    # recursive (4th argument 2nd bool("true"))
    EUDATReplication(*source, *destination, bool("true"), bool("true"), *response)
}
INPUT *source='/eveZone/home/alice/Collection', *destination='/bobZone/home/alice#aliceZone/Collection'
OUTPUT ruleExecOut
```
*EUDATReplication* is a rule specified in the B2SAFE module.

Execute the rule with:
```
irule -vF eudatRepl.r
```
* The v-option stands for verbose
The execution of the rule takes some time due to several checks and the creation of the PIDs.

We did not specify any output, so we need to find out what happened.
First we inspect the iCAT metadata entry for our data in aliceZone:

```
imeta ls -d Collection/File000.txt
```

```
AVUs defined for dataObj Collection/File000.txt:
attribute: eudat_dpm_checksum_date:demoResc
value: 01471935855
units:
----
attribute: PID
value: 846/4798e6c8-6a8c-11e6-9242-fa163efdf672
units:
```
The B2SAFE rules automatically calculate a checksum and store the date of the last check as an AVU in the iCAT. They also assign a PID. You can inspect the information stored in the PID at:

```
http://epic3.storage.surfsara.nl:8001/846/4798e6c8-6a8c-11e6-9242-fa163efdf672?noredirect
```

*NOTE*, do not forget the *?noredirect*, our data is not publicly avaiable and accessible via aURL, so this will fail.

* The field URL shows you the iRODS logical path.
* There is a field with the MD5 checksum
* There is a special field *10320/LOC*. It contains the iRODS path of our file and some other PID.

Let us inspect this PID by copying the last bits starting at *846* and resolve it with the epic3 resolver.
(We are working with test PIDs on a test server. Production PIDs are resolved by hdl.handle.net, thus the whole link would work.)

```
http://epic3.storage.surfsara.nl:8001/846/485beb0a-6a8c-11e6-926e-fa163e38303e?noredirect
```

We see here that this file resides in *bobZone*, so it is one of the previously created replicas.
It contains the same checksum as our original file.
There are two additional entries *ROR* and *PPID*. The *ROR* conatins the PID of the original file, the *PPID* contains the PID of the direct parent file. In our case both are identical.
You see that the *10320/LOC* only contains the path to the replica. Usually this field collects all direct children of a data file.

These are all B2SAFE specifiactions and have been implemented by EUDAT.

Now let us verify the information we drew from the PIDs sytem and go to bobZone on our shell.
You can access the iCAT catalogue in bobZone and fetch information on the replica:

```
imeta ls -d /bobZone/home/alice#aliceZone/Collection/File000.txt
```

*Note* that collections also receive a PID:
```
imeta ls -C Collection
```


#### (Optional) Extending the replication chain
Now adopt the *eudatRepl.r* rule to replicate the Collection you have in bobZone back to a different Collection in eveZone. 
Simply exchange the values in *source* and *destination* and make sure to rename *Collection* in eveZone (otherwise you will overwrite the previous one).

```
eudatRepl{
    # Data set replication
    # registered data (with PID registration) (3rd argument - 1st bool("true"))
    # recursive (4th argument 2nd bool("true"))
    EUDATReplication(*source, *destination, bool("true"), bool("true"), *response)
}
INPUT *source='/bobZone/home/alice#aliceZone/Collection', *destination='/aliceZone/home/alice/Collection1'
OUTPUT ruleExecOut
```

**Exercise** 
- Inspect the new PIDs for the data in *Collection1*, especially the fields *PPID* and *ROR*
- What changed in the PID entries of the ROR-PID and the PPID-PID?

Example Chain:
- ROR: 
   http://epic3.storage.surfsara.nl:8001/846/4798e6c8-6a8c-11e6-9242-fa163efdf672?noredirect
- Direct child of the ROR:
   http://epic3.storage.surfsara.nl:8001/846/485beb0a-6a8c-11e6-926e-fa163e38303e?noredirect
- Child of the replica:
   http://epic3.storage.surfsara.nl:8001/846/fd5f8fc8-6a8e-11e6-9aae-fa163efdf672?noredirect

**Exercise**
- Rereplicate the original data collection to another collection to bob.
- Adjust the rule eudatRepl.r
- Which PIDs change?


# B2STAGE: Data management in iRODS with gridFTP
We extended the iRODS with a gridFTP endpoint and coupled it to the iRODS instance. 
This is what the technology B2STAGE does. It also includes automatic PID resolving.
As result you can use gridFTP tools like *globus-url-copy* to copy, delete and manage your data in the iRODS logical namespace.

## Upload data to iRODS with *globus-url-copy*
Reupload your collections again and store it under a different iRODS path.

First create a grid proxy from your certificate:
```
grid-proxy-init
```
then you can use the follwoing command to upload your whole collection to a new iRODS collection
```
imkdir GridFTPColl
globus-url-copy -r Collection/ gsiftp://di4r2016-3.novalocal/aliceZone/home/alice/GridFTPColl/ 
```
- *gsiftp* dentotes the endpoint and protocol
- *di4r2016-3.novalocal* is the short cut for the gridFTP server, (inspect mapping in /etc/hosts)
- *aliceZone/home/alice/GridFTPColl/* is the iRODS path

Check with 
```
ils -L GridFTPColl
```
what happened.

With the options *-sync* and *-sync-level* you can determine which files to update. Note, that these commands will perform checksum calculations but will not store them in the iCAT catalogue.

## Retrieve data by PID
In the previous section we labeled files with PIDs. The B2SAFE module, however, does not only label files with PIDs but also Collections. These PIDs can be used to list and retrieve data with gridFTP.

```
imeta ls -C Collection
globus-url-copy -list gsiftp://di4r2016-3.novalocal/846/4318901c-6a8c-11e6-a1db-fa163efdf672/
```

We replaced the iRODS path with the PID for the collection.
The GridFTP tries to find the file, when this fails it tries to resolve the file path. If this is successful and the URL field in the PID contains a path to which this gridFTP instance has access to, you can retrieve the file(s).

```
mkdir NewCollGsi
globus-url-copy gsiftp://di4r2016-3.novalocal/846/4318901c-6a8c-11e6-a1db-fa163efdf672/ NewCollGsi
ls NewCollGsi
```

## Third party transfers
You can steer data flows between gridFTP endpoints. We will not send data from our iRODS server to another gridFTP server (which accidentially also lies on the machine where the iRODS bobZone is located. However, they are NOT connected.).
We will transfer the data behind a PID:

```
imeta ls -C Collection
```

to the other gridFTP server

```
globus-url-copy gsiftp://di4r2016-3.novalocal/846/4318901c-6a8c-11e6-a1db-fa163efdf672/ gsiftp://di4r2016-2.novalocal/tmp/
```
On the other server the files in *Collection* are saved in *tmp*:
(Note, you do not have access to the server, so you have to trust me.)
```
root@di4r2016-2:/home/cloud-user# ls /tmp/
4318901c-6a8c-11e6-a1db-fa163efdf672  psqlodbc_irods19024.log  psqlodbc_irods8322.log  psqlodbc_irods8551.log  psqlodbc_irods8740.log
File000.txt                           psqlodbc_irods19044.log  psqlodbc_irods8347.log  psqlodbc_irods8553.log  psqlodbc_irods8742.log
File001.txt                           psqlodbc_irods19100.log  psqlodbc_irods8476.log  psqlodbc_irods8560.log  psqlodbc_irods8745.log
File002.txt
...
```


And we can put data from another gridFTP endpoint into iRODS via the gridFTP protocol:
We fetch one of the data files from  we have just saved in the *tmp* directory of the gridFTP endpoint and save it as *ExternalColl* in our iRODS (alice) instance:

```
imkdir ExternalColl
globus-url-copy gsiftp://di4r2016-2.novalocal/tmp/File000.txt gsiftp://di4r2016-3.novalocal/aliceZone/home/alice/ExternalColl/File000.txt

ils ExternalColl
```

# What have we learned?
- We can use iRODS to upload, manage and annotate data
- We can steer dataflows between iRODS instances with the iRODS native icommands
- We can steer data between our laptop/userinterface and iRODS with gridFTP
- We can execute third party transfers with gridFTP between a gridFTP enabled iRODS server and a 'normal' gridFTP server 



