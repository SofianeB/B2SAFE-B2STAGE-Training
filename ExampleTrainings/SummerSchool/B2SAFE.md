# iRODS and B2SAFE for users

## What will we learn?
- Use iRODS to upload, manage and annotate data
- Steer dataflows between iRODS instances with the iRODS native icommands
- Do automatic data replication between iRODS servers with the B2SAFE module

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


## Basic commands (15min)
### Listing and collection creation
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

## Replication across iRODS Zones
To keep data safe you sometimes want to store them at a different site belonging to a different administrative unit. 
iRODS offers to federate iRODS Zones for specific users.
In our little example we set up such a federation.

### iRODS federations (15 min)
iRODS federations are connections between different iRODS servers or - in iRODS terms - *zones*. iRODS federations are setup by the 
system administrators. They also exchange users which allows you as a user to read and write data at a different iRODS zones.

In our example our users are known and authenticated at *aliceZone*. Each of your accounts has a counter part at the remote zone *bobZone*. 

```
ils /bobZone/home/<user>#aliceZone
```
* *bobZone* denotes the zone on the different server, i.e a physically different machines and running an own iCAT database
* Your username needs to be extended with *#aliceZone* to indicate that you are a remote user
* Authentication: You authenticate with your iRODS instance 'aliceZone'. System administrators at the other iRODS instance added you as a remote user and gave you user rights on 'bobZone'.

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

### Small exercise
 
- Try to use *imv* to move *aliceInWonderland-DE.txt.utf-8* from *aliceZone* to *bobZone*. Can you use *icp*? What could be the reasoning for the different behaviour?
- Download the German version from *bobZone* to your local linux filesystem (store it under a different file name). Which commands can you use?

The command *imv* edits the corresponding entry in the iCAT metadata catalogue at *aliceZone* and moves the data physically to a new location in the *Vault*.

```
ils -L aliceInWonderland-DE.txt.utf-8
imv aliceInWonderland-DE.txt.utf-8 aliceGerman.txt
ils -L aliceGerman.txt
```
*imv* would mean that the metadata entry is at *aliceZone*, while the data is physically stored at *bobZone*.
With *icp* you create a new data object with a metadata entry at its iRODS zone and storage site.

### Replicating and synchronising data (5min)
As with *gridFTP* and *rsync* iRODS offers a command to synchronise data between either your local unix filesystem or between different 
iRODS zones.
In the following we will use the remote iRODS zone as a backup server. 

We can replicate the collection *lewiscarroll* to *bobZone*

```
irsync -r i:/aliceZone/home/di4r-user1/lewiscarroll \
i:/bobZone/home/di4r-user1#aliceZone/lewiscarroll
```
The *i:* indicates that the following path corresponds to an iRODS logical path. You can also use *irsync* to synchronise collections between your local unix account and an iRODS instance.

Check 

```
ils -L /bobZone/home/di4r-user1#aliceZone/lewiscarroll 
```

You see that the data at the remote site carries a checksum. *irsync* calculates the checksums and uses them to determine 
whether the file needs to be transferred.
File transfers with *irsync* are quicker when first calculating the checksum and then transferring them.

### Small Exercise
Which commands can you use to download the data from the remote iRODS zone to your local unix file system?

### Exercise (20min)
Verify that *irsync* really just updates data when necessary.

1. Create a collection on *aliceZone*, e.g. *archive* or reuse the collection *lewiscarroll*
2. Add some (new) files to this collection, e.g. the English version of Alice in Wonderland (use *icp* or *imv* to move data from *aliceInWonderland*).
3. Check what needs to be synchronised with *irsync -l* flag. What does this flag do?
4. Synchronise the whole collection with *bobZone* (not only the file). Which flag do you have to use?
5. Check again if there is something to be synchronised.
6. Add another file to * aliceInWonderland* on *aliceZone*, e.g. the Italian version of Alice in Wonderland.
7. Check the synchronisation status. (It can take some time until the iRODS system marks the new files as 'synchronised')

### Solution

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
We created another copy of the *archive* (*lewiscarroll*) collection at *bobZone* but we lost the link to the data at *aliceZone*.
We will now have a look at how we can use the iCAT metadat catalogues at *bobZone* and at *aliceZone* to link the data.

We can create metadata for iRODS data objects and collections on our home iRODS zone like this:

```
imeta add -C aliceInWonderland "TYPE" "collection"
imeta add -d lewiscarroll/aliceInWonderland-DE.txt.utf-8 \
"TYPE" "object"
```

With 

```
imeta ls -C aliceInWonderland
```
and

```
imeta ls -d lewiscarroll/aliceInWonderland-DE.txt.utf-8
```
we can list all metadata.

We can do exactly the same for the data at the remote site

```
imeta add -d /bobZone/home/di4r-user1#aliceZone/lewiscarroll/aliceInWonderland-DE.txt.utf-8 \
"Original" "/aliceZone/home/di4r-user1/lewiscarroll/aliceInWonderland-DE.txt.utf-8"
```

### Small exercise (10min)

1. Label the files in */bobZone/home/di4r-user1#aliceZone/archive* (or *lewiscarroll*) with information on its original source.
2. Introduce anonther metadata field in the original data to link to the replicas. Use the key "Replica".

## Automatic replication with B2SAFE
To understand B2SAFE we first need to see what iRODS rules are.
### iRODS rules (5min)
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

* The name of the rule does not have to correspond with the file name
* Variables are denoted by '*'
* You can specify the value of parameters in INPUT
* ruleExecOut is the standard output, here the variable *name* is returned too.
Safe the file as *helloworld.r* somewhere in your account and execute the following command:

```
irule -F exampleRules/helloworld.r
```

Variables are denoted with a '\*' and we can overwrite them by passing the correct value:

```
irule -F exampleRules/helloworld.r "*name='Alice'"
```

If you want to pass two variables the syntax looks like this.

```
irule -F exampleRules/helloworld.r "*name='Alice'" "*anotherVar=5"
```

### B2SAFE (20min)
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
*EUDATReplication* is a rule specified in the B2SAFE module which is installed on the iRODS server and accessible for everyone.

Execute the rule with:

```
irule -vF exampleRules/eudatReplication.r \
"*source='/aliceZone/home/di4r-user1/aliceInWonderland'" \
"*destination='/bobZone/home/di4r-user1#aliceZone/aliceInWonderland'"
```
* The v-option stands for verbose
The execution of the rule takes some time due to several checks and the creation of the PIDs.

We did not specify any output, so we need to find out what happened.
B2SAFE creates metadata for our data in aliceZone which is stored in the iCAT:

```
imeta ls -C aliceInWonderland
```

```
attribute: PID
value: 21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25
units:
----
attribute: EUDAT/REPLICA
value: 21.T12996/92916c0a-28ea-11e7-a883-04040a6400c1
units:
----
attribute: EUDAT/FIXED_CONTENT
value: False
units:
```
The collection received a PID and is marked as 'none-fixed content', a data policy which allows this collection to change.
And we see that the collection has a replica.

Replicated files in that collection also receive a PID and a special iCAT entry

```
imeta ls -d aliceInWonderland/aliceInWonderland-EN.txt.utf-8
```

```
attribute: EUDAT/REPLICA
value: 21.T12996/93c8530e-28ea-11e7-89ed-04040a6400c1
units:
----
attribute: PID
value: 21.T12995/968ac9aa-28ea-11e7-9e3e-040091643b25
units:
----
attribute: EUDAT/FIXED_CONTENT
value: False
units:
----
attribute: eudat_dpm_checksum_date:demoResc
value: 01493036011
units:
```
### B2SAFE: iCAT metadata and the Handle records

The B2SAFE rules automatically calculate a checksum and store the date of the last check as an AVU in the iCAT. They also assign a PID. 
You can inspect the information stored in the PID at:

- Collection:
	http://hdl.handle.net/21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25?noredirect
- File:
	http://hdl.handle.net/21.T12995/968ac9aa-28ea-11e7-9e3e-040091643b25?noredirect

*NOTE*, do not forget the *?noredirect*, our data is not publicly avaiable and accessible via a URL. Without the *?noredirect* the 
request will fail.

* The field URL shows you the iRODS logical path.
* There is a field with the MD5 checksum
* There is a special field *EUDAT/REPLICA*. It contains the iRODS path of our file and the replica PID.

Let us inspect the replica PID for the collection:

http://hdl.handle.net/21.T12996/92916c0a-28ea-11e7-a883-04040a6400c1?noredirect

- URL: We see here that this collection resides in *bobZone*, so it is one of the previously created replicas.
- It contains the same checksum as our original file.
- There are three additional entries *EUDAT/ROR*, *EUDAT/PARENT* and *EUDAT/FIO*. Here all three are the same, but the can contain ifferent information:
	- *EUDAT/ROR*: Repository of records, a (community) repository holding the very original file
	- *EUDAT/FIO*: First ingest point in the EUDAT domain, i.e. first EUDAT repository holding a copy or the original
	- *EUDAT/PARENT*: Direct parent of the replica

These are all B2SAFE specifiactions and have been implemented by EUDAT.

The replicated file holds the same information:

http://hdl.handle.net/21.T12996/93c8530e-28ea-11e7-89ed-04040a6400c1?noredirect

Now let us go back to iRODS verify the information we drew from the PID sytem and go to bobZone on our shell. We can use the irods paths to the replicated files from the Handle registry:

The metadata of the replicated collection *aliceInWonderland*

```
imeta ls -C /bobZone/home/di4r-user1#aliceZone/aliceInWonderland
attribute: EUDAT/PARENT
value: 21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25
units:
----
attribute: EUDAT/ROR
value: 21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25
units:
----
attribute: EUDAT/FIXED_CONTENT
value: False
units:
----
attribute: PID
value: 21.T12996/92916c0a-28ea-11e7-a883-04040a6400c1
units:
----
attribute: EUDAT/FIO
value: 21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25
units:
```

The metadata of one of the replicated data objects:

```
imeta ls -d /bobZone/home/di4r-user1#aliceZone/aliceInWonderland/aliceInWonderland-EN.txt.utf-8
attribute: EUDAT/FIXED_CONTENT
value: False
units:
----
attribute: EUDAT/FIO
value: 21.T12995/968ac9aa-28ea-11e7-9e3e-040091643b25
units:
----
attribute: eudat_dpm_checksum_date:demoResc
value: 01493037359
units:
----
attribute: EUDAT/ROR
value: 21.T12995/968ac9aa-28ea-11e7-9e3e-040091643b25
units:
----
attribute: PID
value: 21.T12996/93c8530e-28ea-11e7-89ed-04040a6400c1
units:
----
attribute: EUDAT/PARENT
value: 21.T12995/968ac9aa-28ea-11e7-9e3e-040091643b25
units:
```

### Exercise: Local replication (5min)
Adopt the calling of the replication rule to replicate *aliceInWonderland* to another collection in *aliceZone*, e.g. 'lewiscarroll/aliceIW'.

Inspect the metadata and PID handles of the original data *aliceInWonderland*.

### Solution

```sh
irule -vF exampleRules/eudatReplication.r \
"*source='/aliceZone/home/di4r-user1/aliceInWonderland'"\
"*destination='/aliceZone/home/di4r-user1/lewiscarroll/aliceIW'"
```

With

```sh
imeta ls -C aliceInWonderland
```
you can see that the entry *EUDAT/REPLICA* was extended with another PID.

### Exercise: Extending the replication chain (20min)
Now adopt the input to *eudatReplication.r* to replicate *aliceIW* from *aliceZone* back to *bobZone*. 

- Inspect the metadata of lewiscarroll/aliceIW. How is it extended?
- How does the metadata of aliceIW at bobZone look like.
- It helps to draw a picture to keep track of the replication chain.

### Solution

```
irule -vF exampleRules/eudatReplication.r \
"*source='/aliceZone/home/di4r-user1/lewiscarroll/aliceIW'" \
"*destination='/bobZone/home/di4r-user1#aliceZone/aliceIW'"
```
Metadata entry of *lewiscarroll/aliceIW* (the previous replica which now serves as new parent)

```
attribute: EUDAT/PARENT
value: 21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25
units:
----
attribute: EUDAT/ROR
value: 21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25
units:
----
attribute: EUDAT/FIXED_CONTENT
value: False
units:
----
attribute: EUDAT/FIO
value: 21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25
units:
----
attribute: EUDAT/REPLICA
value: 21.T12996/b726985c-28ee-11e7-a909-04040a6400c1
units:
----
attribute: PID
value: 21.T12995/c6a3ac80-28ed-11e7-8b29-040091643b25
units:
```

Metadata entry of *aliceIW* at bobZone (the very last replica in the chain)

```
attribute: EUDAT/FIO
value: 21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25
units:
----
attribute: EUDAT/FIXED_CONTENT
value: False
units:
----
attribute: EUDAT/PARENT
value: 21.T12995/c6a3ac80-28ed-11e7-8b29-040091643b25
units:
----
attribute: EUDAT/ROR
value: 21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25
units:
----
attribute: PID
value: 21.T12996/b726985c-28ee-11e7-a909-04040a6400c1
units:
```

Example Chain:

- **ROR** and **FIO**

   http://hdl.handle.net/21.T12995/94e4e9b4-28ea-11e7-ada6-040091643b25?noredirect
- **Direct child** of the ROR

   http://hdl.handle.net/21.T12995/c6a3ac80-28ed-11e7-8b29-040091643b25?noredirect
- **Child of the replica**

   http://hdl.handle.net/21.T12996/b726985c-28ee-11e7-a909-04040a6400c1?noredirect