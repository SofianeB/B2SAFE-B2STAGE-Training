#Hand outs - iRODS User training (4hours)
## Login to user interface machine
```
ssh di4r-userX@ui.eudat-sara.surf-hosted.nl
```

## Connect to iRODS (10 minutes)

Command 	| Meaning
---------|--------
iinit		| Login
ienv		| iRODS environment
iuserinfo	| User attributes
**ihelp**		| List of all commands
**\<command\> -h** | Help
**ils** [-L A l] | List collection	


## Data up and download (20 minutes)
Command 	| Meaning
---------|--------
iput [-K r] | Upload data to iRODS [create checksum, recursive]
ils [-L A l] | List collection [Long format, Accessions, less long format]
irm 		| Remove data from iRODS
iget [-K r]	| Download data to local file system [Verify checksum, recursive]

### Small exercise:
- Store the German version of Alice in wonderland `aliceInWonderland-DE.txt.utf-8` on iRODS.
- Verify that the checksum in iRODS is the same as for your local file. You can calculate the checksum in linux with `md5sum aliceInWonderland-DE.txt.utf-8`.


## Structuring data in iRODS (20 minutes)
Command 	| Meaning
---------|--------
imkdir		| Create collection
imv			| Rename and move data in iRODS
icp			| Copy data in iRODS 
ipwd		| Print current working directory
icd			| Change working directory

### Small exercise
- Move the German version of Alice in Wonderland to the sub collection 'book-aliceInWonderland'.

### Working directory

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
Command 	| Meaning
---------|--------
ils -A	[-r]	| List Accession control lists [recursive]
ichmod	inherit	| Set inheritance of a collection
ichmod [read, write, null, own]	| Set access rights

### Small exercise
1. Pair up with another team.
2. Make one of your collections or subcollections accessible to other team
3. Switch on the inheritance
4. Put some data in the folder (`imv` or `icp` some data that is already in iRODS)
5. Use `iget` and try to download the data your partnering team gave access to  

## Metadata (30 minutes)
Command 	| Meaning
---------|--------
imeta add [-d C] Name AttName AttValue [AttUnits]	| Create metadata [file, collection]
imeta ls [-d C]	| List metadata [file, collection]

### Exercise: Create Metadata (15min)
1. Create the author Bob for the file test.txt
2. Inspect the list of AVUs
3. Add a new triple 'distance' '36' 'miles' 
4. Explore the options of `imeta` (`imeta -h`)
5. Overwrite the unit in (distance, 36, miles) with feet. Do not create a new triple and delete the old one. Find a way to update the existing triple.
6. Remove the author Alice

 (For experts)
7. What does `imeta set` do?

### Queries for data
Example - Find all data with an attribute 'author'

```
iquest "select COLL_NAME, DATA_NAME, META_DATA_ATTR_VALUE where \
META_DATA_ATTR_NAME like 'author'" 
``` 

Example - Filter data for an 'author' with name 'Alice'

```
iquest "select COLL_NAME, DATA_NAME where \
META_DATA_ATTR_NAME like 'author' and META_DATA_ATTR_VALUE like 'Alice'"
```

Command 	| Meaning
---------|--------
iquest		| Find data by query on metadata
iquest attrs	| List of attributes to query 
			| USER\_ID, USER\_NAME, RESC\_ID, RESC\_NAME, RESC\_TYPE\_NAME, RESC\_CHILDREN, RESC\_PARENT, DATA\_NAME, DATA\_REPL\_NUM, DATA\_SIZE, DATA\_RESC\_NAME, DATA\_PATH, DATA\_OWNER\_NAME, DATA\_CHECKSUM, COLL\_ID, COLL\_NAME, COLL\_PARENT\_NAME, COLL\_OWNER,\_NAME META\_DATA\_ATTR\_NAME, META\_DATA\_ATTR\_VALUE, META\_DATA\_ATTR\_UNITS, META\_DATA\_ATTR\_ID, META\_COLL\_ATTR\_NAME, META\_COLL\_ATTR\_VALUE, META\_COLL\_ATTR\_UNITS, META\_COLL\_ATTR\_ID, META\_COLL\_CREATE\_TIME, META\_COLL\_MODIFY\_TIME, META\_NAMESPACE\_COLL, META\_RESC\_ATTR\_NAME, META\_RESC\_ATTR\_VALUE, META\_RESC\_ATTR\_UNITS

**NOTE**: the '%' is a wildcard and state

### Small exercise
- Pair up with another team.
- Create some data and annotate the data, with own attributes and values.
- Can you search for that data with `iquest` and the attribute-value pair? Can you find the data of your partnering team? What does the team have to do to make you and only you see the metadata?
- Do the permissions of the files have any influence on the metadata search?

## Exercise: Find an island with sunshine (20 min)
In the system there are some clues under the attribute 'Easter'. Gather the clues and download the your personal island with sunshine. There is a chocolatry prize for the first one who finds it!

## iRODS resources (30 minutes, optional)
Command 	| Meaning
---------|--------
ilsresc [-l]	| List all storage resource [long format]
iput -R \<resource\>	| Upload data to specific resource
irepl -R \<resource\>	| Replicate data in iRODS to another resource
irm -n \<number\>		| Remove replica with a certain number
itrim	-N \<number\>				| Trim number of replicas to specific number

### Small exercise
1. Replicate a file to three different resources
2. Explore `itrim` and trim the number of replicas to 1 (1 original and 1 replica)

### Small exercise
- Where is your data stored physically when you upload it to 'roundRobin'. 
- Where is your neighbours data stored?
- Upload several files after each other to 'roundRobin'. Where does the data land physically?
- Try to put data on storage1 directly.

## Exercise: Explore the data policy behind replResc (20min)

1. We have seen that a round robin implements a certain data policy. Which data policy is hidden behind 'replResc'?
2. Where are all the resources located? (`ilsresc -l`)
3. How many servers does the iRODS system use?

**Note** As an iRODS user you do not need to know which servers and storage systems are involved. You only need an idea about the policies hidden behind grouped resources.



















