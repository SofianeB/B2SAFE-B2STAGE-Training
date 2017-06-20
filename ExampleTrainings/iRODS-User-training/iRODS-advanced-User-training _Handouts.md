# iRODS advanced User Training

## Recap icommands (15 min)

|                      Command                       |                                Meaning                                 |
|----------------------------------------------------|------------------------------------------------------------------------|
| iinit                                              | Login                                                                  |
| ienv                                               | iRODS environment                                                      |
| iuserinfo                                          | User attributes                                                        |
| **ihelp**                                          | List of all commands                                                   |
| **\<command\> -h**                                 | Help                                                                   |
| **Up- and down load**                              |                                                                        |
| iput [-K -r -f -R \<resc\>]                        | Upload data, create checksum, recursively, overwrite, specify resource |
| iget [-K -r -f]                                    | Check checksum, recursively, overwrite                                 |
| **Data organisation**                              |                                                                        |
| ils [-L -A -l]                                     | List collection [long format, access control list, less long format]   |
| imkdir                                             | Create collection                                                      |
| icd                                                | Change current working collection                                      |
| **Metadata**                                       |                                                                        |
| imeta add [-d -C] Name AttName AttValue [AttUnits] | Create metadata [file, collection]                                     |
| imeta ls [-d -C]                                   | List metadata [file, collection]                                       |
| iquest                                             | Find data by query on metadata                                         |
| iquest attrs                                       | List of attributes to query                                            |

**Some predefined attributes for iquest:**

USER\_ID, USER\_NAME, RESC\_ID, RESC\_NAME, RESC\_TYPE\_NAME, RESC\_CHILDREN,
RESC\_PARENT, DATA\_NAME, DATA\_REPL\_NUM, DATA\_SIZE, DATA\_RESC\_NAME,
DATA\_PATH, DATA\_OWNER\_NAME, DATA\_CHECKSUM, COLL\_ID, COLL\_NAME,
COLL\_PARENT\_NAME, COLL\_OWNER,\_NAME META\_DATA\_ATTR\_NAME,
META\_DATA\_ATTR\_VALUE, META\_DATA\_ATTR\_UNITS, META\_DATA\_ATTR\_ID,
META\_COLL\_ATTR\_NAME, META\_COLL\_ATTR\_VALUE, META\_COLL\_ATTR\_UNITS,
META\_COLL\_ATTR\_ID, META\_COLL\_CREATE\_TIME, META\_COLL\_MODIFY\_TIME,
META\_NAMESPACE\_COLL, META\_RESC\_ATTR\_NAME, META\_RESC\_ATTR\_VALUE,
META\_RESC\_ATTR\_UNITS

**Example query**:

```
iquest "select COLL_NAME, DATA_NAME where \
META_DATA_ATTR_NAME like 'author' and META_DATA_ATTR_VALUE like 'Alice'"
```

Remember: in *iquest*, the percent sign (%) is the wildcard character that
matches zero or more characters.

### Exercise (5 min)

Data can be downloaded from iRODS to your local machine with the command
*iget*. Explore the command *iget* to **store the data in you home directory**.
Do **not overwrite** your original data and do **verify checksums**!


## iRODS federations (10 min)
Access to remote zone:

```
ils /bobZone/home/di4r-user1#aliceZone
/bobZone/home/di4r-user1#aliceZone:
```

### Small exercise (10min)

- Try to use *imv* to move *aliceInWonderland-DE.txt.utf-8* from *aliceZone* to
  *bobZone*. Can you use *icp*? What could be the reasoning for the different
  behaviour?
- Download the German version from *bobZone* to the 'local' Unix filesystem (on
  the UI machine). Store it under a different file name. Which commands can you
  use?

### Replicating and synchronising data (15min)

We can replicate the file to *bobZone*

```
irsync i:/aliceZone/home/di4r-user1/aliceInWonderland-EN.txt.utf-8 \
i:/bobZone/home/di4r-user1#aliceZone/aliceInWonderland-EN.txt.utf-8
```

### Small Exercise

Which commands can you use to download the data from the remote iRODS zone to
your 'local' Unix filesystem?

### Exercise (15min)

Verify that *irsync* really just updates data when necessary.

1. Create a collection on *aliceZone*, e.g. *archive*
2. Add some files to this collection, e.g. the German version of Alice in
   Wonderland (use *icp* or *imv*).
3. Check what needs to be synchronised with *irsync -l* flag. What does this
   flag do?
4. Synchronise the whole collection with *bobZone* (not only the file). Which
   flag do you have to use?
5. Check again if there is something to be synchronised.
6. Add another file to *archive* on *aliceZone*, e.g. the Italian version of
   Alice in Wonderland.
7. Check the synchronisation status. (It can take some time until the iRODS
   system marks the new files as 'synchronised')

### Metadata for remote data (5min)

*imeta* works also for data in a different zone.

```
imeta add -C /bobZone/home/di4r-user1#aliceZone/archive \
"Original" "/aliceZone/home/di4r-user1/archive"
```

#### Small exercise (5min)

1. Label the files in */bobZone/home/di4r-user1#aliceZone/archive* with
   information on its original source.
2. Introduce another metadata field in the original data to link to the
   replicas. Use the key "Replica".

### Retrieving data by metadata (10min)

We can retrieve our freshly labeled data at *aliceZone*

```
iquest "select COLL_NAME, DATA_NAME where META_DATA_ATTR_NAME like 'Original'"
COLL_NAME = /aliceZone/home/di4r-user1/archive
DATA_NAME = aliceInWonderland-EN.txt.utf-8
```

To query the metadata in the iCAT catalogue for *bobZone* we need to specify
this using the *-z* flag of *iquest*.

```
iquest "select COLL_NAME, DATA_NAME where \
META_DATA_ATTR_NAME like 'Original' and COLL_NAME like '%bobZone%'"

CAT_NO_ROWS_FOUND: Nothing was found matching your query


iquest -z bobZone "select COLL_NAME, DATA_NAME where \
META_DATA_ATTR_NAME like 'Original' and COLL_NAME like '%bobZone%'"
Zone is bobZone
COLL_NAME = /bobZone/home/di4r-user1#aliceZone/archive
DATA_NAME = aliceInWonderland-EN.txt.utf-8
```

There is no standard way to query multiple iCAT catalogues with a single
*iquest* command.

#### Small exercise (10 min)

Assume your "Original" *archive* collection on *aliceZone* is corrupted. How
would you find out where you can get a copy of that data and how would you
restore the data?

## iRODS rules (30min)

Open *exampleRules/helloworld.r*

```c
HelloWorld{
	writeLine("stdout", "Hello *name!");
}

INPUT *name="YourName"
OUTPUT ruleExecOut, *name
```

and execute the rule with

```
irule -F exampleRules/helloworld.r
```

### Passing arguments, variables and output

### Exercise: Passing variables, data types (10min)

```c
variables{
	writeLine("stdout", "var1 is *var1!");
	writeLine("stdout", "var2 is *var2!");
}

INPUT *var1=1, *var2="string"
OUTPUT ruleExecOut, *name
```

- Alter the type of the input variables: numbers and simple calculations, booleans (true, false), strings
- How do you only change one of the two variables?

```
irule -F exampleRules/variables.r '*var1="Hello"'
```

### Looping over data

```c
recursivelist{
    *home="/$rodsZoneClient/home/$userNameClient"
    writeLine("stdout",*home);
    foreach(*row in SELECT COLL_NAME, DATA_NAME WHERE COLL_NAME like '*home%'){
        *coll = *row.COLL_NAME;
        *data = *row.DATA_NAME;
        writeLine("stdout", "*coll/*data");
    }
}

input null
output ruleExecOut
```
```
irule -F exampleRules/recursivelist.r
```
The '%' works as wild card, variables are denoted by '*'.

### Exercise (15min)
Write a rule that finds all data objects and all collections that carry the same metadata key.
E.g. there is a collection labeled with the attribute 'Easter' and there are some files carrying the same attribute. Make the attribute a variable.

### Solution framework

```c
queryall{
	foreach(*row in SELECT COLL_NAME, <FILL IN> where <FILL IN> like '*var'){
		*coll = *row.COLL_NAME;
       *value = *row.<FILLIN>;
       writeLine("stdout", "<Some output>");
   	}
   	foreach(*row in SELECT COLL_NAME, <FILL IN>, <FILL_IN> where <FILL IN> like '*var'){
		*coll = *row.COLL_NAME;
		*data = *row.<FILL IN>;
       *value = *row.<FILL IN>;
       writeLine("stdout", "<Some output>");
    }
}

input *var='Easter'
output ruleExecOut
```

### If-statements and on-statements
Open *exampleRules/conditionalhello.r*.

```c
conditionalhello{
    if(*name!="Your Name"){
        writeLine("stdout", "Hello *name!");
        }
    else { writeLine("stdout", "Hello world!"); }
}
INPUT *name="Your Name"
OUTPUT ruleExecOut, *name
```
```
irule -F exampleRules/conditionalhello.r "*name='You'"
```
The same rule above looks like this with on-statements (*exampleRules/conditionalhelloon.r*):

```c
hellorule{
    *result = hello(*name);
    writeLine("stdout", "*result");
}

hello(*name){
    on(*name=="Your Name")
        { "Hello world!"; }
}

hello(*name){
    "Hello *name!";
}

INPUT *name="Your Name"
OUTPUT ruleExecOut, *name
```
```
irule -F exampleRules/conditionalhelloon.r
```
### Exercise (15min)
- Switch the two *hello* rules in the rule above. What happens and why?

- Write a rule with different cases (decision between data policies), set the variable "iresource" accordingly:
	- If the data size is large, "iresource" should be "archive"
	- If the data should be highly available, "iresouce" should be "replResc"
	- If the data is classified as sensitive data, "iresource" should always be "storage3"
	- In all other cases the data should go to the "demoResc"
	
- Implement the policies using *if* or *on*.
- Which of the two is more advantageous if you think of what you need to alter when one of the cases (policies) changes?
- Why would you put the cases tested with *on* in different rules (all carrying the same rule name)?

### Solution framework

```c
policydecision{
	# example if
	if(*size=="large"){* resourceName = "archive"}
	else{ ... }
	# example on
	*resourceName = storagepolicy(*size, *privacy, *availability)
	writeLine("stdout", "*resourceName")
}

#example on
storagepolicy(*size, *privacy, *availability){
	on(*availability=="high"){"replResc"}
}

INPUT *size=<FILL IN>, *privacy=<FILL IN>, *availability=<FILL_IN>
OUTPUT ruleExecOut
```

### Implement your own data archiving policy (60min)

The data archiving rule should consist of two rules (policies).

1. Automatically synchronise the *archive* collection to *bobZone*. Watch out! Only replicate your *archive* collection not your neighbours collection.
2. Create metadata to track the data.

We will give examples for replicating collections.

#### Exercise: The replication part
Write a rule that will replicate iRODS collections (template in 
*exampleRules/replicationPart.r*).

```c
myReplicationPolicy{
    # create base path to your home collection and extend with what you want to replicate
    *source="/$rodsZoneClient/home/$userNameClient/<FILL_IN>";
    # by default we stay in the same iRODS zone and use a new collection called 'test'
    if(*destination == ""){ *destination = "/$rodsZoneClient/home/$userNameClient/test"}
    # some sanity checking
    writeLine("stdout", "Replicate *source");
    writeLine("stdout", "Destination *destination");

    replicate("*source", *destination, *syncStat)
    writeLine("stdout", "Irsync finished with: *syncStat");
}

replicate(*source, *dest, *status){
    # check whether it is a collection (-c) or a data object (-d)
    # *source_type catches return value of the function
    msiGetObjType(*source,*source_type);
    writeLine("stdout", "*source is of type *source_type");

    # Only proceed when source_type matches "collection"
    if(<FILL_IN>){
        msiCollRsync(*source, *destination,
            "null","IRODS_TO_IRODS",*status);
        writeLine("stdout", "Irsync status: *status");
    }
    else{
        # Create some useful message on the prompt
        writeLine("stdout", "<FILL_IN>");
        # Propagate the status variable so that it can be taken up by myReplicationPolicy
        *status = <FILL_IN>
    }
}

INPUT *coll="archive", *destination=""
OUTPUT ruleExecOut
```

#### Exercise: The metadata part
Write a rule that attaches metadata to collections and data objects (template in *exampleRules/metadataPart.r*).
The metadata should contain a key-value pair determining whether the data is a collection or a data object (extract that information automatically from iRODS), another metadata entry should be determined by a key value pair given as input of the rule.

```c
myMetadataPolicy{

    # Build absolute path for obaject or collection to label with metadata
    *path=<FILL_IN>
    writeLine("stdout", "Labeling *path");

    # Add metadata on TYPE, defined by system
    addMD("TYPE", "", *path)
    # Add user metadata
    writeLine("stdout", "*mdkey *mdval");
    addMD(*mdkey, *mdval, *path)
}

# Function to attach metadata to any data collection or data object
# Case 1: Metadata to extract from system --> TYPE
addMD(*key, *value, *path){
    on(<FILL_IN>){
        msiGetObjType(*path,*source_type);
        if(*source_type=="-d"){
            *MDValue="data object";
        }
        else{
            *MDValue="collection"
        }
        createAVU(*key, *MDValue, *path);
    }
}

# Case 2: User defined metadata
addMD(*key, *value, *path){
    # Do not add metadata with empty value!
    # Test whether value is empty --> ""
    # Create AVU when value is given.
    <FILL_IN>
}

# Low-level helper function
createAVU(*key, *value, *path){
    #Creates a key-value pair and connects it to a data object or collection
    msiAddKeyVal(*Keyval,*key, *value);
    writeKeyValPairs("stdout", *Keyval, " is : ");
    msiGetObjType(*path,*objType);
    msiSetKeyValuePairsToObj(*Keyval, *path, *objType);
}

INPUT *item="archive", *mdkey="ORIGINAL", *mdval="/aliceZone/home/di4r-user1/archive"
OUTPUT ruleExecOut
```

#### Exercise: Putting it all together
Now that we have the single parts, write a rule, that replicates a collection to *bobZone* and labels the collection and all its contents:

- The original data on *aliceZone* with the links to the replicated data on *bobZone*
 
 ```
attribute: REPLICA
value: /bobZone/home/di4r-user1#aliceZone/archive
 ```
- The replicated data on *bobZone* with the link to the original data on *aliceZone*

 ```
 attribute: ORIGINAL
 value: /aliceZone/home/di4r-user1/archive
 ```
 
- **Start fresh**: Make sure you have some data and some subcollection in an iRODS collection called *archive*
 
 ```
 ils archive

 /aliceZone/home/di4r-user1/archive:
 aliceInWonderland-DE.txt.utf-8
 C- /aliceZone/home/di4r-user1/archive/aliceInWonderland
  
 imeta ls -C archive

 AVUs defined for collection archive:
 None
 ```
 
(template in *exampleRules/replication.r*)
 
```c
 replication{
    # create base path to your home collection
    *source=<FILL_IN>;
    # by default we stay in the same iRODS zone
    if(*destination == ""){ *destination = "/$rodsZoneClient/home/$userNameClient/test"}

    writeLine("stdout", "Replicate *source");
    writeLine("stdout", "Destination *destination");

    replicate("*source", *destination, *syncStat);
    writeLine("stdout", "Irsync finished with: *syncStat");
    writeLine("stdout", "");

    # Use addMD to link the original collection and the replicated collection
    # Create metadata for *collection
    writeLine("stdout", "Create metadata for input collection *source.")
    <FILL_IN>

    # Create metadata for *destination
    writeLine("stdout", "Create metadata for replica collection *destination.")
    <FILL_IN>
    writeLine("stdout", "");

    # Loop over all data objects in your archive collection in aliceZone
    writeLine("stdout", "Create metadata for all data objects in *source.")
    foreach(*row in SELECT COLL_NAME, DATA_NAME where COLL_NAME like "*source"){
        *coll = *row.COLL_NAME;
        *data = *row.DATA_NAME;
        *repl = <FILL_IN>; # build the paths to the original data file and the replica
        *orig = <FILL_IN>;

        linkOrigRepl(*path, *orig);
    }

    # Do the same for the sub collections
    writeLine("stdout", "Create metadata for all subcollections in *source.")
    foreach(*row in SELECT COLL_NAME where COLL_NAME like "%archive/%"){
        *coll = *row.COLL_NAME;
        #might be handy, have a look at the produced variables *parent and *child
        msiSplitPath(*coll, *parent, *child) 
        *repl = <FILL_IN>;

        linkOrigRepl(*coll, *repl);
    }
 }
 
 # Given the original path and the replication path introduce the linking.
 linkOrigRepl(*orig, *repl){
    # label orig with "REPLICA" *repl
    writeLine("stdout", "Metadata for *orig:");
    addMD("REPLICA", *repl, *orig);
    addMD("TYPE", "", *orig)
    writeLine("stdout", "");

    # label repl with "ORIGINAL" *orig
    writeLine("stdout", "Metadata for *repl:");
    addMD("ORIGINAL", *orig, *repl);
    addMD("TYPE", "", *repl)
    writeLine("stdout", "");
}

addMD(*key, *value, *path){
    on(*key=="TYPE"){
        msiGetObjType(*path,*source_type);
        if(*source_type=="-d"){
            *MDValue="data object";
        }
        else{
            *MDValue="collection"
        }
        createAVU(*key, *MDValue, *path);
    }
}

addMD(*key, *value, *path){
    # Do not add metadata with empty value!
    if(*value==""){
        writeLine("stdout", "No mdval given.");
    }
    else{
        createAVU(*key, *value, *path);
    }
}

createAVU(*key, *value, *path){
    msiAddKeyVal(*Keyval,*key, *value);
    writeKeyValPairs("stdout", *Keyval, " is : ");
    msiGetObjType(*path,*objType);
    msiSetKeyValuePairsToObj(*Keyval, *path, *objType);
}

replicate(*source, *dest, *status){
    # check whether it is a collection (-c) or a data object (-d)
    # *source_type catches return value of the function
    msiGetObjType(*source,*source_type);
    writeLine("stdout", "*source is of type *source_type");

    # Only proceed when source_type matches "collection"
    if(*source_type == "-c"){
        msiCollRsync(*source, *destination,
            "null","IRODS_TO_IRODS",*status);
    }
    else{
       writeLine("stdout", "Expected Collection, got data object.");
       *status = "FAIL - No data collection."
    }
}

INPUT *collection="archive", *destination="/bobZone/home/di4r-user1#aliceZone/BACKUP"
OUTPUT ruleExecOut
```

## Last Challenge
**The big cleanup:** Write a policy, that removes all data from your iRODS home collection and from your remote home collection.

Hints:

- Loop over all data objects AND colections in aliceZone
- Loop over all data objects AND colections in bobZone
- Microservices to delete data objects and collections:
	- `msiDataObjUnlink(*data,*status)`
	- `msiRmColl(*collection, "", *status)`


