# iRODS and B2SAFE-gridFTP

## What will we learn?
- Use iRODS to upload, manage and annotate data
- Steer dataflows between iRODS instances with the iRODS native icommands
- Do automatic data replication between iRODS servers with the B2SAFE module
- Steer data between our laptop/userinterface and iRODS with gridFTP
- Execute third party transfers with gridFTP between a gridFTP enabled iRODS server and a 'normal' gridFTP server

## icommands for this training 

Command 	| Meaning
---------|--------
iinit		| Login
ienv		| iRODS environment
iuserinfo	| User attributes
**ihelp**		| List of all commands
**\<command\> -h** | Help
**Up- and down load**	|
iput	[-K -r -f -R \<resc\>]	| Upload data, create checksum, recursively, overwrite, specify resource
iget [-K -r -f]	| Check checksum, recursively, overwrite
**Data organisation** |
ils [-L -A -l] | List collection [Long format, Accessions, less long format]
imkdir		| Create collection
icd			| Change current working collection
**Metadata** 		|
imeta add [-d -C] Name AttName AttValue [AttUnits]	| Create metadata [file, collection]
imeta ls [-d -C]	| List metadata [file, collection]


### Connection
On user interface machine type in

```
iinit
```

The system will ask you for information where to connect to:

```
Enter the host name (DNS) of the server to connect to:  <ip adrdress>
Enter the port number: 1247
Enter your irods user name: <irodsuser>
Enter your irods zone: <zonename>
```

Provide your password and .. there you are

### HELP

- List all commands available for iRODS

```
ihelp
```
- Get help on a specific commands

`ihelp iuserinfo` or `iuserinfo -h`


## Basic commands
### Basic commands
First we will have a look at some very basic commands to move through the logical namespace in iRPDS. The basic commands in iRODS 
are very similar to bash/shell commands.
You can browse through your collections with:

```
ils
```
And you can create new collections with:

```
imkdir lewiscarroll
```

### Uploading data to iRODS
We can put a single file into our home-collection or a designated collection.

```
iput -K aliceInWonderland-DE.txt.utf-8 lewiscarroll
```
The flag *-K* triggers the calculation and verification of a checksum, in this case an md5 checksum. 
Now upload a collection to iRODS:

```
iput -r -K aliceInWonderland
```
The option *K* triggers the calculation of checksums and verifies them upon upload.

### Logical and physical namespaces in iRODS
The *ils* command gives you an option to extract the physical location of a file, *-L* gives the long format of the files, 
*-r* lists a collection recursively:

```
ils -L -r aliceInWonderland
```

You will see some output like:

```
/aliceZone/home/di4r-user1/aliceInWonderland:
  di4r-user1        0 demoResc       109858 2017-04-09.10:18 & 
  aliceInWonderland-EN.txt.utf-8    4469a7b948107c7d5bba84b0403cd415    generic    
  /training-data/Vault/home/di4r-user1/aliceInWonderland/aliceInWonderland-EN.txt.utf-8
  
  di4r-user1        0 demoResc       175251 2017-04-09.10:18 &
   aliceInWonderland-IT.txt.utf-8 	615f83cdd21c1c3c23921c731f2c5f88    generic    
   /training-data/Vault/home/di4r-user1/aliceInWonderland/aliceInWonderland-IT.txt.utf-8
```

We will use this command quite often today to see what happens with files upon replication.
With this command you see where the file is stored on the iRODS server.

- *di4r-user1* is the data owner
- *0* is the index of this replica. the number only refers to replicas in one iRODS zone and can be used to automatically trim the 
number of replicas or create new ones in case one got lost.
- *demoResc* is the resource on which the data is stored. Resources can refer to certain paths on the iRODS server or other storage 
servers and clusters.
* The next entry is the time of the upload and the file name
* The follwing entry is the checksum, in our case it is a MD5 sum
* The last entry is the physical path of the data on the iRODS server.

### Exercise (5 min)

Data can be downloaded from iRODS to your local machine with the command *iget*.
Explore the command *iget* to **store the data in your home directory**. Do **not overwrite** your original data and **verify checksums**!

## Replication across iRODS Zones
To keep data safe you sometimes want to store them at a different site belonging to a different administrative unit. 
iRODS offers to federate iRODS Zones for specific users.
In our little example we set up such a federation.

Remember: to check what data we have stored in our iRODS home collection we used

```
ils 
```
and it listed automatically all data in */aliceZone/home/<user>*.

To access data on the other iRODS server type in:

```
ils /bobZone/home/<user>#aliceZone
```
* *bobZone* denotes the zone on the different server, they are really physically different machines and they run their own iCAT data base
* Your username needs to be extended with *#aliceZone* to indicate that on bobZone you are a remote user
* Authentication: You authenticate with your iRODS instance. System administrators at the other iRODS instance added you as a remote 
users and your corresponding rights.

## iRODS federations (10 min)
iRODS federations are connections between different iRODS servers or - in iRODS terms - *zones*. iRODS federations are setup by the 
system administrators. They also exchange users which allows you as a user to read and write data at a different iRODS zones.

In our example our users are known and authenticated at *aliceZone*. Each of your accounts has a counter part at the remote zone *bobZone*. 

Let us have a look at how we can access our **remote** home directory.

```
ils /bobZone/home/di4r-user1#aliceZone
/bobZone/home/di4r-user1#aliceZone:
```

Note that when you are accessing your remote home you have to state at which iRODS zone you are authenticated. 
This is indicated with the *#aliceZone*.

We can put data directly from our linux account in the remote home:

```
iput -K aliceInWonderland-DE.txt.utf-8 /bobZone/home/di4r-user1#aliceZone
```

```
ils /bobZone/home/di4r-user1#aliceZone -L
/bobZone/home/di4r-user1#aliceZone:
  di4r-user1        0 demoResc       187870 2017-03-27.10:20 
  & aliceInWonderland-DE.txt.utf-8
    7bdfc92a31784e0ca738704be4f9d088    generic    
    /irodsVault/home/di4r-user1#aliceZone/aliceInWonderland-DE.txt.utf-8
```

#### Small exercise (10min)
- Try to use *imv* to move *aliceInWonderland-DE.txt.utf-8* from *aliceZone* to *bobZone*. Can you use *icp*? What could be the 
reasoning for the different behaviour?
- Download the German version from *bobZone* to your local linux filesystem (store it under a different file name). Which commands 
can you use?

The command *imv* edits the corresponding entry in the iCAT metadata catalogue at *aliceZone* and moves the data physically to a new 
location in the *Vault*.

```
ils -L aliceInWonderland-DE.txt.utf-8
imv aliceInWonderland-DE.txt.utf-8 aliceGerman.txt
ils -L aliceGerman.txt
```
*imv* would mean that the metadata entry is at *aliceZone*, while the data is physically stored at *bobZone*.
With *icp* you create a new data object with a metadata entry at its iRODS zone and storage site.

### Replicating and synchronising data (15min)
As with *gridFTP* and *rsync* iRODS offers a command to synchronise data between either your local unix filesystem or between different 
iRODS zones.
In contrast to pure iRODS replication with *irepl* this will create new data objects and collections at the remote zone.

In the following we will use the remote iRODS zone as a backup server. The iRODS collection *archive* will serve as source collection 
for the backup.

Upload one of the files in *aliceInWonderland* to your home-collection on **aliceZone**. Do not use the *-K* flag.

```
iput aliceInWonderland/aliceInWonderland-EN.txt.utf-8
```

We can replicate the file to *bobZone*

```
irsync i:/aliceZone/home/di4r-user1/aliceInWonderland-EN.txt.utf-8 \
i:/bobZone/home/di4r-user1#aliceZone/aliceInWonderland-EN.txt.utf-8
```

Check 

```
ils -L /bobZone/home/di4r-user1#aliceZone/aliceInWonderland-EN.txt.utf-8 
```

You see that at the remote site there is a checksum calculated. *irsync* calculates the checksums and uses them to determine 
whether the file needs to be transferred. After some delay you will also see with *ils -L* on **aliceZone** that iROD calcuated and 
stored a checksum for the file.
File transfers with *irsync* are quicker when first calculating the checksum and then transferring them.

#### Small Exercise
Which commands can you use to download the data from the remote iRODS zone to your local unix file system?

### Exercise (15min)
Verify that *irsync* really just updates data when necessary.

1. Create a collection on *aliceZone*, e.g. *archive*
2. Add some files to this collection, e.g. the German version of Alice in Wonderland (use *icp* or *imv*).
3. Check what needs to be synchronised with *irsync -l* flag. What does this flag do?
4. Synchronise the whole collection with *bobZone* (not only the file). Which flag do you have to use?
5. Check again if there is something to be synchronised.
6. Add another file to * aliceInWonderland* on *aliceZone*, e.g. the Italian version of Alice in Wonderland.
7. Check the synchronisation status. (It can take some time until the iRODS system marks the new files as 'synchronised')

#### Solution

1. Synchronising

 ```
 irsync -r i:archive i:/bobZone/home/di4r-user1#aliceZone/archive
 irsync -r -l i:archive i:/bobZone/home/di4r-user1#aliceZone/archive
 ```
2. Add new files to *archive*

 ```
 iput aliceInWonderland/aliceInWonderland-IT.txt.utf-8 archive/
 ```
3. Check sync-status
 
 ```
 irsync -r -l i:archive i:/bobZone/home/di4r-user1#aliceZone/archive
 /aliceZone/home/di4r-user1/archive/aliceInWonderland-IT.txt.utf-8   175251   N
 ```
4. Synchronising and checking sync-status
 
 ```
 irsync -r i:archive i:/bobZone/home/di4r-user1#aliceZone/archive
 irsync -r -l i:archive i:/bobZone/home/di4r-user1#aliceZone/archive
 ```
 
 If you did not calculate the checksums for the source files, the sync-status needs some time to be updated.

### Metadata for remote data (5min)
We created a nother copy of the *archive* collection at *bobZone* but we lost the link to the data at *aliceZone*.
We will now have a loko at how we can use the iCAT metadat catalogues at *bobZone* and at *aliceZone* to link the data.

We can create metadata for iRODS data objects and collections on our home iRODS zone like this:

```
imeta add -C aliceInWonderland "Original" "/aliceZone/home/di4r-user1/aliceInWonderland"
imeta add -d aliceInWonderland/aliceInWonderland-EN.txt.utf-8 \
"Original" "/aliceZone/home/di4r-user1/aliceInWonderland/aliceInWonderland-EN.txt.utf-8"
```

With 

```
imeta ls -C aliceInWonderland
```
and

```
imeta ls -d aliceInWonderland/aliceInWonderland-EN.txt.utf-8
```
we can list all metadata.

We can do exactly the same for the data at the remote site

```
imeta add -d /bobZone/home/di4r-user1#aliceZone/aliceInWonderland-DE.txt.utf-8 \
"Original" "/aliceZone/home/di4r-user1/aliceInWonderland-DE.txt.utf-8"
```

#### Small exercise (5min)

1. Label the files in */bobZone/home/di4r-user1#aliceZone/archive* with information on its original source.
2. Introduce anonther metadata field in the original data to link to the replicas. Use the key "Replica".

## Automatic replication with B2SAFE
To understand B2SAFE we first need to see what iRODS rules are.
### iRODS rules 
We have seen that we can replicate data to a different Zone. Now we want to be sure that we can track replicated files, 
replicate files and collections upon change and we want automatise everything as much as possible. Here, we will make use of iRODS rules.
iRODS rules are short procedure or functions with an own syntax.

Open the file *exampleRules/helloworld.r*

```
HelloWorld{
        writeLine("stdout", "Hello *name!");
}

INPUT *name="World"
OUTPUT ruleExecOut, *name
```

* You can specify the value of parameters in INPUT
* ruleExecOut is the standard output, here the variable *name* is returned too.
Safe the file as *hello.r* somewhere in your account and execute the following command:

```
irule -F exampleRules/helloworld.r
```

Variables are denoted with a '\*' and we can overwrite them by passing the correct value:

```
irule -F exampleRules/helloworld.r "*name='Alice'"
```

### B2SAFE
B2SAFE is a ruleset that extends the core rule set of iRODS and provides tools to replicate data and keep track of the replicas by 
creating persistent identifiers and leaving additional information in the iCAT database.

We will use B2SAFE to replicate our Collection to bobZone, create PIDs for the original data in aliceZone, create PIDs for the replicas 
in bobZone and link the files on PID level.

First let us inspect and adapt the corresponding rule in examples/eudatRepl.r.

```
eudatRepl{
    # Data set replication
    # registered data (with PID registration) (3rd argument - 1st bool("true"))
    # recursive (4th argument 2nd bool("true"))
    EUDATReplication(*source, *destination, "true", "true", *response)
}
INPUT *source='/aliceZone/home/alice/Collection', *destination='/bobZone/home/alice#aliceZone/Collection'
OUTPUT ruleExecOut
```
*EUDATReplication* is a rule specified in the B2SAFE module.

Execute the rule with:

```
irule -vF exampleRules/eudatReplication.r \
"*source='/aliceZone/home/di4r-user1/aliceInWonderland'" \
"*destination='/bobZone/home/di4r-user1#aliceZone/aliceInWonderland'"
```
* The v-option stands for verbose
The execution of the rule takes some time due to several checks and the creation of the PIDs.

We did not specify any output, so we need to find out what happened.
First we inspect the iCAT metadata entry for our data in aliceZone:

```
imeta ls -C aliceInWonderland
```

```
AVUs defined for collection aliceInWonderland:
attribute: EUDAT/ROR
value: 21.T12995/88ea102c-1cff-11e7-a500-040091643b25
units:
----
attribute: PID
value: 21.T12995/88ea102c-1cff-11e7-a500-040091643b25
units:
----
attribute: Original
value: /aliceZone/home/di4r-user1/aliceInWonderland
units:
```

The source collection is labeled with a PID, as is every data object:

```
imeta ls -d aliceInWonderland/aliceInWonderland-EN.txt.utf-8
```

```
AVUs defined for dataObj aliceInWonderland/aliceInWonderland-EN.txt.utf-8:
attribute: PID
value: 21.T12995/89f6c500-1cff-11e7-96d7-040091643b25
units:
----
attribute: EUDAT/ROR
value: 21.T12995/89f6c500-1cff-11e7-96d7-040091643b25
units:
----
attribute: eudat_dpm_checksum_date:demoResc
value: 01491726434
units:
----
attribute: Original
value: /aliceZone/home/di4r-user1/aliceInWonderland/aliceInWonderland-EN.txt.utf-8
units:
```

The B2SAFE rules automatically calculate a checksum and store the date of the last check as an AVU in the iCAT. They also assign a PID. 
You can inspect the information stored in the PID at:

http://hdl.handle.net/21.T12995/88ea102c-1cff-11e7-a500-040091643b25?noredirect

http://hdl.handle.net/21.T12995/aa10125a-1cfb-11e7-802d-040091643b25?noredirect

*NOTE*, do not forget the *?noredirect*, our data is not publicly avaiable and accessible via a URL. Without the *?noredirect* the 
request will fail.

* The field URL shows you the iRODS logical path.
* There is a field with the MD5 checksum
* There is a special field *10320/LOC*. It contains the iRODS path of our file and some other PID.

Let us inspect the PID in the *LOC* field:

```
https://epic4.storage.surfsara.nl:8007/21.T12996/a95d31b2-1cfb-11e7-b9e6-04040a6400c1?noredirect
```
or

```
https://hdl.handle.net/21.T12996/a95d31b2-1cfb-11e7-b9e6-04040a6400c1?noredirect
```

We see here that this file resides in *bobZone*, so it is one of the previously created replicas.
It contains the same checksum as our original file.
There are two additional entries *ROR* and *PPID*. The *ROR* conatins the PID of the original file, the *PPID* contains the PID 
of the direct parent file. In our case both are identical.
You see that the *10320/LOC* only contains the path to the replica. Usually this field collects all direct children of a data file.

These are all B2SAFE specifiactions and have been implemented by EUDAT.

Now let us go back to iRODS verify the information we drew from the PID sytem and go to bobZone on our shell.

The metadata of the replicated collection *aliceInWonderland*

```
imeta ls -C /bobZone/home/di4r-user1#aliceZone/aliceInWonderland
AVUs defined for collection /bobZone/home/di4r-user1#aliceZone/aliceInWonderland:
attribute: EUDAT/ROR
value: 21.T12995/88ea102c-1cff-11e7-a500-040091643b25
units:
----
attribute: EUDAT/PPID
value: 21.T12995/88ea102c-1cff-11e7-a500-040091643b25
units:
----
attribute: PID
value: 21.T12996/886fe52c-1cff-11e7-b046-04040a6400c1
units:
```

The metadata of one of the replicated data objects:

```
imeta ls -d /bobZone/home/di4r-user1#aliceZone/aliceInWonderland/aliceInWonderland-IT.txt.utf-8
AVUs defined for dataObj /bobZone/home/di4r-user1#aliceZone/aliceInWonderland/aliceInWonderland-IT.txt.utf-8:
attribute: eudat_dpm_checksum_date:demoResc
value: 01491726948
units:
----
attribute: EUDAT/PPID
value: 21.T12995/8e54b8a0-1cff-11e7-8219-040091643b25
units:
----
attribute: EUDAT/ROR
value: 21.T12995/8e54b8a0-1cff-11e7-8219-040091643b25
units:
----
attribute: PID
value: 21.T12996/8d9a231e-1cff-11e7-9c51-04040a6400c1
units:
```

### Exercise: Local replication
Adopt the calling of the replication rule to replicate *aliceInWonderland* to another collection in *aliceZone*, e.g. 'lewiscarroll'.

#### Solution

```
irule -vF exampleRules/eudatReplication.r \
"*source='/aliceZone/home/di4r-user1/aliceInWonderland'"\
"*destination='/aliceZone/home/di4r-user1/lewiscarroll'"
```

### Exercise: Extending the replication chain
Now adopt the input to *eudatReplication.r* to replicate *lewiscarroll* from *aliceZone* back to *bobZone*. 

- Inspect the new PIDs for the data in *lewiscarroll* on *bobZone*, especially the fields *PPID* and *ROR*
- What changed in the PID entries of the ROR-PID and the PPID-PID?

#### Solution

```
irule -vF exampleRules/eudatReplication.r \
"*source='/aliceZone/home/di4r-user1/lewiscarroll'" \
"*destination='/bobZone/home/di4r-user1#aliceZone/lewiscarroll'"
```

Example Chain:

- **ROR**

   http://hdl.handle.net/21.T12995/8e54b8a0-1cff-11e7-8219-040091643b25?noredirect
- **Direct child** of the ROR

   http://hdl.handle.net/21.T12995/01932d36-1d02-11e7-8122-040091643b25?noredirect
- **Child of the replica**

   http://hdl.handle.net/21.T12996/4d4d928e-1d02-11e7-9346-04040a6400c1?noredirect


## B2STAGE: Data management in iRODS with gridFTP
We extended the iRODS with a gridFTP endpoint and coupled it to the iRODS instance. 
This is what the technology B2STAGE does. It also includes automatic PID resolving.
As result you can use gridFTP tools like *globus-url-copy* to copy, delete and manage your data in the iRODS logical namespace.

### Upload data to iRODS with *globus-url-copy*
Reupload your collections again and store it under a different iRODS path.

Ensure you are in your user directory of the remote *aliceZone*: 

```
ipwd
icd /aliceZone/home/<username>/
ipwd
```

First create a grid proxy from your certificate:

```
grid-proxy-init
```

then you can use the follwoing command to upload your whole collection to a new iRODS collection

```
imkdir GridFTPColl
globus-url-copy -r aliceInWonderland/ gsiftp://alice-server/aliceZone/home/di4r-user1/GridFTPColl/ 
```
- *gsiftp* dentotes the endpoint and protocol
- *alice-server* is the short cut for the gridFTP server, (inspect mapping in /etc/hosts)
- *aliceZone/home/<username>/GridFTPColl/* is the iRODS path, where `<username>` is replaced with your username.

Check with 

```
ils -L GridFTPColl
```
to see what happened.

### Remarks

With the options *-sync* and *-sync-level* of the `globus-url-copy` command you can determine which files to update. Note, that 
these commands will perform checksum calculations but will not store them in the iCAT catalogue.

With the command `grid-proxy-info` you can get information about the state of the current proxy certificate. Ensure that time left 
is larger than zero.

What is a proxy certificate? To interact directly with a remote service a certificate can be used to prove identity. However, in the 
grid world it is often necessary for a remote service to act on a user's behalf.
One could imagine sending the private key to remote services, however this is very insecure. On the grid, a proxy allows limited 
delegation of rights. Strictly speaking, a proxy is also a certificate, but usually the unqualified term "certificate" is reserved for 
something issued by a certificate authority (CA). Proxies normally have a rather short lifetime, typically 12 hours.

## Retrieve data by PID
In the previous section we labeled files with PIDs. The B2SAFE module, however, does not only label files with PIDs but also Collections. 
These PIDs can be used to list and retrieve and list data with gridFTP.

```
imeta ls -C aliceInWonderland
globus-url-copy -list gsiftp://alice-server/21.T12995/88ea102c-1cff-11e7-a500-040091643b25/
```

Note: replace the pid value in the `globus-url-copy` command with the correct output from the `imeta ls` command.

We replaced the iRODS path with the PID for the collection.
The GridFTP tries to find the file, when this fails it tries to resolve the file path. If this is successful and the URL field in the 
PID contains a path to which this gridFTP instance has access to, you can retrieve the file(s).

Download data via PID from iRODS to your local file system:

```
globus-url-copy -cd gsiftp://alice-server/21.T12995/88ea102c-1cff-11e7-a500-040091643b25/ NewCollGsi/
ls NewCollGsi
```
Note: make sure to update the pid value again.

### Exercise: Retrieving data from a remote iRODS zone (15min)
With iRODS we could access data on *aliceZone* and *bobZone*. However, we could not simply retrieve them by PID.

What happens if we try to list data on the two iRODS servers with gridFTP?
Try the following options, which work and why?

- List data in *aliceZone*

 ```
 globus-url-copy -list \
 gsiftp://alice-server/aliceZone/home/di4r-user1/aliceInWonderland/
 ```
- List data in *bobZone* via the logical path with respect to *aliceZone*
	- globus-url-copy	

 ```
 globus-url-copy -list \
 gsiftp://alice-server/bobZone/home/di4r-user1#aliceZone/aliceInWonderland/
 ```
 	- uberftp

 ```
 uberftp -ls \
 gsiftp://alice-server/bobZone/home/di4r-user1#aliceZone/aliceInWonderland/
 ```
- List data in *aliceZone* referring to the by PID
 
 ```
 imeta ls -C /aliceZone/home/di4r-user1/aliceInWonderland
 ```
 
 ```
 globus-url-copy -list gsiftp://alice-server/<PID>/
 ```
- List data in *bobZone* referring to the by PID

 ```
 imeta ls -C /bobZone/home/di4r-user1#aliceZone/aliceInWonderland
 ```
 Note, the PIDs referring to data in *bobZone* use the prefix **21.T12996**
 ```
 uberftp -ls gsiftp://alice-server/<PID>/
 ```
 Why can the gridFTP server linked to *aliceZone* not retrieve the data?


## Third party transfers
You can steer data flows between gridFTP endpoints from an external client. We will not send data from our iRODS server to another 
gridFTP server (which accidentially also lies on the machine where the iRODS bobZone is located. However, they are NOT connected.).
We will transfer the data behind a PID:

```
imeta ls -C aliceInWonderland
```

to the other gridFTP server. 
You all have access to the same unix account on the second gridFTP server. So it is wise to create and own folder there upon transfer.

```
globus-url-copy -cd gsiftp://alice-server/21.T12995/88ea102c-1cff-11e7-a500-040091643b25/ gsiftp://bob-server/home/di4r/collUser1/
```

```
globus-url-copy -list gsiftp://bob-server/home/di4r/collUser1/
```

On the other server the files in *aliceInWonderland* are saved in *collUser1*.

And we can put data from another gridFTP endpoint into iRODS via the gridFTP protocol:
We fetch one of the data files we have just saved in the *di4r/collUser1* directory of the gridFTP endpoint and save it as *aliceStories* 
in our iRODS (alice) instance:

```
globus-url-copy -cd gsiftp://bob-server/home/di4r/collUser1/ gsiftp://alice-server/aliceZone/home/di4r-user1/aliceStories/

ils aliceStories
```

### Remarks

What is a third party transfer? A third party transfers is a transfer between two remote servers.

# What have we learned?
- We can use iRODS to upload, manage and annotate data
- We can steer dataflows between iRODS instances with the iRODS native icommands
- We can steer data between our laptop/userinterface and iRODS with gridFTP
- We can execute third party transfers with gridFTP between a gridFTP enabled iRODS server and a 'normal' gridFTP server 


