# iRODS User training (4hours)
## Connect to iRODS (10 minutes)
Goal: We will see how to connect to an iRODS instance and will have a look at the environment.
Login to the User Interface machine. This machine provides a commandline tool with which you can connect to iRODS, send data to and download from iRODS etc.

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

### Environment

With the command

```
ienv
```
you can check how the iRODS zone is composed

```
NOTICE: Release Version = rods4.1.9, API Version = d
NOTICE: irods_session_environment_file - 
	/home/ubuntu/.irods/irods_environment.json.22864
NOTICE: irods_user_name - rods
NOTICE: irods_host - 145.100.59.37
...
NOTICE: irods_port - 1247
...
NOTICE: irods_zone_name - aliceZone
...
NOTICE: created irodsHome=/aliceZone/home/rods
NOTICE: created irodsCwd=/aliceZone/home/rods
```
The ".irods.irods_environment.json" stores the data that you just provided to login. Next time you login iRODS will check this file, so you do not have to provide these details again.

Have a look at the iRODS session environment:

```
cat /home/ubuntu/.irods/irods_environment.json
```

The file contains the minimal information for a session.

With

```
iuserinfo
```
you can retrieve information on your account.

### HELP

- List all commands available for iRODS
```
ihelp
```
- Get help on a specific commands
`ihelp iuserinfo` or `iuserinfo -h`


### The working directory
With the command 

```
ils
```
we can check whether there is data in our iRODS-home directory

```
/aliceZone/home/alice:
``` 

- aliceZone: the name of the iRODS zone
- `/home/<user>`: your default working directory 

## Data up and download (20 minutes)
### Create data
Open a file with `nano` on the linux filesystem

```
nano <filename>
```

### Data upload
With the linux command `ls` you can check that the file has been created and is accessible on the User Interface machine:

```
ls 
test.txt
```

We now upload the data to the iRODS server and remove the original file:

```
iput -K test.txt
rm test.txt
```

The file is now only available on the iRODS server:

```
ils
ubuntu@alice-server:~$ ils
/aliceZone/home/rods:
  test.txt
```
But not on the local linux system (check with `ls`).

**Note:** the commands to steer iRODS are very similar to bash commands and can easily be confused!

Data can be deleted with the command:

```
irm <filename>
```

### Connection between logical and physical namespace
iRODS provides an abstraction from the physical location of the files. I.e. `/aliceZone/home/rods/test.txt` is the logical path which only iRODS knows. But where is the file actually on the server that hosts iRODS?

```
ils -L 
/aliceZone/home/rods:
  rods              0 demoResc           27 2017-02-23.16:05 & test.txt
    a8216b70fd3c9049213be59a96ad6c15    generic    /irodsVault/home/rods/test.txt
```

Aha, what does this mean?
The file `test.txt` that we uploaded is known in iRODS as `/aliceZone/home/rods/test.txt`. It is owned by the user 'rods' and lies on the storage resource `demoResc` and there is no other replica of that file in the iRODS system (0 in front of 'demoResc'). The size of the file is 27KB. It is stored with a time stamp and a checksum. Actually, the checksum calculation was triggered by the option '-K' of the `iput` command.

### Data download
We deleted our local copy of our test file and want to restore it. We can download the version stored in iRODS with:

```
iget -K test.txt test-restore.txt
```

We downloaded test.txt and renamed our local copy to test-restore.txt. With the option '-K' we trigger that the checksum of the local file is compared with the checksum of the file on the iRODS server.

**Note,** iRODS can be used as external storage service, we can store extra system information, i.e. checksums which are used to verify data integrity upon data moving.

### Small exercise:
- Store the German version of Alice in wonderland `aliceInWonderland-DE.txt.utf-8` on iRODS.
- Verify that the checksum in iRODS is the same as for your local file. You can calculate the checksum in linux with `md5sum aliceInWonderland-DE.txt.utf-8`.


## Structuring data in iRODS (20 minutes)
On a normal PC you would create folder structures to keep the overview over your data. In iRODS you can also create folders, however, they are called collections.

In iRODS you have the commands `imkdir` and `imv`.

To create an iRODS collection:

```
imkdir lewiscarroll
```

Now let us move our test file to that collection and list the contents of the collection

```
imv aliceInWonderland-DE.txt.utf-8 lewiscarroll
ils -L lewiscarroll
```

or list the whole home directory recursively

```
ils -L -r
```

```
  C- /aliceZone/home/rods/MyColl
/aliceZone/home/rods/MyColl:
  rods              0 demoResc           27 2017-02-24.08:09 & test.txt
    a8216b70fd3c9049213be59a96ad6c15    generic    
    /irodsVault/home/rods/MyColl/test.txt
```

You see that the logical iRODS collection '/aliceZone/home/rods/lewiscarroll' has the physical counterpart '/irodsVault/home/rods/lewiscarroll'. So data does not end up on the iRODS server randomly but follows a structure.

We can also put data directly into an iRODS collection. Let us move the folder 'aliceInWonderland' in one go to iRODS under the collection 'lewiscarroll'

```
iput -K -r aliceInWonderland lewiscarroll/book-aliceInWonderland
```

We need to use the flag `-r` for recursive upload and we gave a different name to the folder in iRODS.

### Small exercise
- Move the German version of Alice in Wonderland to the sub collection 'book-aliceInWonderland'.

### Working directory
All data that you uploaded so far went automatically to the logical iRODS collection '/aliceZone/home/rods/'. Why is that?

You have a command

```
ipwd
```

So if you do not specify a full path '/aliceZone/home/rods/<file>' but only a partial path e.g. 'lewiscarroll/file.txt' iRODS automatically uses the current working directory as a prefix.

You can change your current working directory with

```
icd lewiscarroll
```

### Small exercise:
- What happens in the following two lines?

 ``` 
 ils -L
 ```
 ```
 iput -K test-restore.txt
 ```
- How can you list your iRODS home directory now?
- Change your working directory again to your iRODS home collection. Verify with ipwd!!!
- Remove test-restore.txt from iRODS (but not from your linux home!)

## Exercise: Moving data in iRODS (10 minutes)
1. Create a new collection for another author under you iRODS home collection.
2. Add a file from 'gutenberg.org' to the new collection.
 Download a file to your linux account:
 `wget http://www.gutenberg.org/files/52521/52521-0.txt`
 Upload it to iRODS using `iput`
3. Create some subcollections
4. List the content of the collection including the content of all possible subcollections.

 For experts (outlook to the next section):
5. How can you grant access to the data in your collection?

## Access control and data sharing (20min)
Check the current access of your data with

```
ils -r -A lewiscarroll
```

```
/aliceZone/home/di4r-user1/lewiscarroll:
        ACL - di4r-user1#aliceZone:own
        Inheritance - Disabled
  C- /aliceZone/home/di4r-user1/lewiscarroll/book-aliceInWonderland
/aliceZone/home/di4r-user1/lewiscarroll/book-aliceInWonderland:
        ACL - di4r-user1#aliceZone:own
        Inheritance - Disabled
  aliceInWonderland-DE.txt.utf-8
        ACL - di4r-user1#aliceZone:own
  aliceInWonderland-EN.txt.utf-8
        ACL - di4r-user1#aliceZone:own
  aliceInWonderland-IT.txt.utf-8
        ACL - di4r-user1#aliceZone:own
```

The collection and all its data is owned by the user 'rods'. Noone else has access rights.

Collections have a flag 'Inheritance'. If this flag is set to true, all content of the folder will inherit the accession rights from the folder.

Let us change the accession rights of 'lewiscarroll'. Choose another irods user who you want to give access (as your neighbour team):

```
ichmod read di4r-user2 lewiscarroll
```

The user 'di4r-user1' can list the collection and see the data to which he has the respective permission.

```
ils -Ar lewiscarroll

/aliceZone/home/di4r-user1/lewiscarroll:
        ACL - di4r-user1#aliceZone:own   di4r-user2#aliceZone:read object
        Inheritance - Disabled
  C- /aliceZone/home/di4r-user1/lewiscarroll/book-aliceInWonderland
/aliceZone/home/di4r-user1/lewiscarroll/book-aliceInWonderland:
        ACL - di4r-user1#aliceZone:own
        Inheritance - Disabled
  aliceInWonderland-DE.txt.utf-8
        ACL - di4r-user1#aliceZone:own
  aliceInWonderland-EN.txt.utf-8
        ACL - di4r-user1#aliceZone:own
  aliceInWonderland-IT.txt.utf-8
        ACL - di4r-user1#aliceZone:own
```

Change the inheritance and place some new data in the collection:

```
ichmod inherit lewiscarroll
iput -K test-restore.txt lewiscarroll/test1.txt
```
```
ils -A -r lewiscarroll 

```
Only the newly placed file will inherit the ACLs from the folder. Old data will keep their ACLs.

### Small exercise
1. Pair up with another team.
2. Make one of your collections or subcollections accessible to other team
3. Switch on the inheritance
4. Put some data in the folder (`imv` or `icp` some data that is already in iRODS)
5. Use `iget` and try to download the data your partnering team gave access to  

## Metadata (30 minutes)
In the previous section we up and downloaded data to an iRODS server and set permissions. So far it is nothig special compared to a normal (unix) filesystem apart from the strange commands.

What does iRODS offer to the user that exceeds such functionality?

### Create Attribute, Value, Unit triples
We can annotate files with so-called AVUs triples. These triples are added to a database and are searchable, e.g. you can ask the iRODS system give me all data (files and collections) whose author is "Alice" and which were created in 2016.

First we will explore how to create these cues for which we can search later.

- Annotate a data file:
 
 ```
 imeta add -d test.txt 'distance' '12' 'meter'
 ```

 ```
 imeta add -d test.txt 'author' 'Alice'
 ```
 Here the 'Unit part is empty'.
 
- Annotate a collection 
 
 ```
 imeta add -C lewiscarroll 'collection' 'books' 
 ```
 
### List metadata
To list metadata do:

```
imeta ls -d test.txt
```
and

```
imeta ls -C lewiscarroll
```

With `imeta ls` you can retrieve the AVUs when given a file or collection name. In the next Section we will see how we can retrieve the file and folder names when given an attribute or value.

### Exercise: Create Metadata (15min)
1. Create the author Bob for the file test.txt
2. Inspect the list of AVUs
3. Add a new triple 'distance' '36' 'miles' 
4. Explore the options of `imeta` (`imeta -h`)
5. Overwrite the unit in (distance, 36, miles) with feet. Do not create a new triple and delete the old one. 
Find a way to update the existing triple.
6. Remove the author Alice

 (For experts)

7. What does `imeta set` do?
Collapses all metadata entries with the same key to one with the new value.


### Queries for data
Previously we calculated a checksum. The checksum was stored in the iCAT metadata catalogue but we cannot fish it out with `imeta`. 
To query the iCAT metadata catalogue we need another command, the `iquest` command.

With this command we can fetch the data file, given e.g. the attribute 'author'.

```
iquest "select COLL_NAME, DATA_NAME, META_DATA_ATTR_VALUE where \
META_DATA_ATTR_NAME like 'author'" 
``` 

And we can filter for a specific attribute values:

```
iquest "select COLL_NAME, DATA_NAME where \
META_DATA_ATTR_NAME like 'author' and META_DATA_ATTR_VALUE like 'Alice'"
```

Or we can retrieve all data with a certain checksum:

```
iquest "select COLL_NAME, DATA_NAME, DATA_CHECKSUM where \
DATA_CHECKSUM like 'a8216b70fd3c9049213be59a96ad6c15'"
```

```
iquest "select COLL_NAME, DATA_NAME, DATA_CHECKSUM where DATA_NAME like '%test%'"
```
This quest will return all files with substring 'test' in file name.

**NOTE**: the '%' is a wildcard. 

There are a lot of predefined attributes that you can use in your searches:

```
iquest attrs
```

The most important ones are listed on your cheat-sheet.

You might see that you get as a result several files. These are the files of your fellow course members. You can see and query the metadata pf these files and collections because you do have the correct ACLs.

### Small exercise
Command  | Meaning
---------|--------
iquest		| Find data by query on metadata
iquest attrs	| List of attributes to query 

```
USER_ID, USE_NAME, RESC_ID, RESC_NAME, RESC_TYPE_NAME, 
RESC_CHILDREN, RESC_PARENT, DATA_NAME, DATA\_REPL_NUM, 
DATA_SIZE, DATA_RESC_NAME, DATA_PATH, DATA_OWNER_NAME, 
DATA_CHECKSUM, COLL_ID, COLL_NAME, COLL_PARENT_NAME, 
COLL_OWNER_NAME, META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE, 
META_DATA_ATTR_UNITS, META_DATA_ATTR_ID, META_COLL_ATTR_NAME, 
META_COLL_ATTR_VALUE, META_COLL_ATTR_UNITS, META_COLL_ATTR_ID, 
META_COLL_CREATE_TIME, META_COLL_MODIFY_TIME, META_NAMESPACE_COLL, 
META_RESC_ATTR_NAME, META_RESC_ATTR_VALUE, META_RESC_ATTR_UNITS
```

- Pair up with another team.
- Create some data and annotate the data, with own attributes and values.
- Can you search for that data with `iquest` and the attribute-value pair? Can you find the data of your partnering team? 
What does the team have to do to make you and only you see the metadata?
- Do the permissions of the files have any influence on the metadata search?

## Exercise: Find the easter bunny (20 min)
- In the system there are some clues under the attribute 'Easter'. Gather the clues and download the easter bunny. 

## iRODS resources (30 minutes, optional)
(Note: commands and resource hierarchies are still todo)

With the command `ils -L` we explored the link between the iRODS logical namespace and the the physical location of files and folders. The same is done with resources.

iRODS resources are pieces of a file system, external servers or software in which data can be stored.

You can list all resources you have available with:

```
ilsresc
``` 
You will see the resource tree.
```
demoResc
knmiDataResc
roundRobin:roundrobin
├── storage1
└── storage2
storage3
```
There are the storage resources: demoResc, knmiDataResc, storage1, storage2, ...

The resources demoResc, storage3 and knmiDataResc can be used directly to store data.
The resources storage1 and 2 are managed by a coordinating resource called roundRobin and ...

If not further specified all your data will go to 'demoResc'.

You can specify the resource on which your data shall be stored directly with the put command. Let us put some data on storage3 resource.

```
iput -K -R storage3 test-restore.txt testfile-on-storage3.txt
```

BIG advantage: As a user you do not need to know which storage medium is hidden behind the resource, you simply use the 
icommands to steer your data movements in the backend.

### User defined replication of data
Once your data is lying in iRODS you can also replicate your data to another predefined resource.
Use `irepl` to replicate the German version of Alice in Wonderland to storage3

```
irepl -R storage3 irepl -R storage3 \
lewiscarroll/book-aliceInWonderland/aliceInWonderland-DE.txt.utf-8
```

```
ils -L lewiscarroll/book-aliceInWonderland/aliceInWonderland-DE.txt.utf-8
 rods              0 demoResc      4909056 2017-02-22.12:40 & testfile.txt
        generic    /irodsVault/home/rods/testfile.txt
  rods              1 knmiDataResc      4909056 2017-02-27.18:44 & testfile.txt
        generic    /data/home/rods/testfile.txt
```
The replicas are enumerated. With this number you can specifically remove a replica. Let us remove the replica on the demoResc:

```
irm -n 0 lewiscarroll/book-aliceInWonderland/aliceInWonderland-DE.txt.utf-8
``` 
We still have a copy of the German version in our system, so the logical name still exists:

```
ils lewiscarroll/book-aliceInWonderland
/aliceZone/home/di4r-user1/lewiscarroll/book-aliceInWonderland:
  aliceInWonderland-DE.txt.utf-8
  aliceInWonderland-EN.txt.utf-8
  aliceInWonderland-IT.txt.utf-8
```

If you do an 

```
irm testfile.txt
```
all replicas will be removed. The filename will only be removed from the logical namespace if there is no replica left.

### Small exercise
1. Replicate a file to three different resources
2. Explore `itrim` and trim the number of replicas to 1 (1 original and 1 replica)

### Resources have a life of their own
In iRODS the system admin can group resources and enforce certain data replication or copying policies.

- Round Robin

```
iput -K -R roundRobin test-restore.txt testfile-on-rr.txt
ils -L testfile-on-rr.txt
```

### Small exercise
- Where is your data stored physically. 
- Where is your neighbours data stored?
- Upload several files after each other. Where does the data land physically?
- Try to put data on storage1 directly.


- Replication
Replication resource that automatically copies your data on two child resources.

## Exercise: Explore the data policy behind replResc (20min)

1. We have seen that a round robin implements a certain data policy. Which data policy is hidden behind 'replResc'?
2. Where are all the resources located? (`ilsresc -l`)
3. How many servers does the iRODS system use?

**Note** As an iRODS user you do not need to know which servers and storage systems are involved. 
You only need an idea about the policies hidden behind grouped resources.



















