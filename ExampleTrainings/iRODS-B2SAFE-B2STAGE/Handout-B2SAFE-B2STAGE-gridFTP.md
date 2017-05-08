# Handout - iRODS, B2SAFE and B2STAGE-gridFTP


<img align="centre" src="https://github.com/EUDAT-Training/B2SAFE-B2STAGE-Training/blob/develop/ExampleTrainings/iRODS-B2SAFE-B2STAGE/Slide10.jpg" width="800px">

Login to the user interface machine. This machine provides you with:

- icommands (iRODS, B2SAFE)
- globus-url-copy and uberFTP (gridFTP, B2STAGE-gridFTP)
- B2HANDLE python library (PID training)

```sh
ssh di4r-userX@145.100.58.13
```

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

## Basic icommands for up and download
### Login to iRODS

```sh
iinit

Enter the host name (DNS) of the server to connect to: 145.100.59.37
Enter the port number: 1247
Enter your irods user name: di4r-userX
Enter your irods zone: aliceZone
```
Password is the same as your unix-user password.

### Exercise (5 min)

Data can be downloaded from iRODS to your local machine with the command *iget*.
Explore the command *iget* to **store the data in your home directory**. Do **not overwrite** your original data and **verify checksums**!

## iRODS federations
You have access to another iRODS zone. You can list data like this:

```sh
ils -L /bobZone/home/di4r-userX#aliceZone
```

### Exercise
Which commands can you use to download the data from the remote iRODS zone to your local unix file system?

### Metadata for remote data
#### Example

```sh
imeta add -d \
	/bobZone/home/di4r-userX#aliceZone/lewiscarroll/aliceInWonderland-DE.txt.utf-8 \
	"Original" \
	"/aliceZone/home/di4r-userX/lewiscarroll/aliceInWonderland-DE.txt.utf-8"
```
#### Small exercise (5min)

Create some metadata for the remote collection *lewiscarroll* and its file.

- Link the remote collection to the local collection by creating a key-value pair ("Original", "/aliceZone/home/di4r-userX/lewiscarroll")
	
- Link the remote file in the collection *lewiscarroll* in the same way as above to its original.

## Automatic replication with B2SAFE
### iRODS rules
Example rules are listed in */home/di4r-userX/exampleRules*.

### Exercise: Local replication (5min)

Adopt the calling of the replication rule to replicate aliceInWonderland to another collection in aliceZone, e.g. 'lewiscarroll/aliceIW'.

Inspect the metadata and PID handles of the original data aliceInWonderland.

### Exercise: Extending the replication chain

Now adopt the input to eudatReplication.r to replicate aliceIW from aliceZone back to bobZone.

- Inspect the metadata of lewiscarroll/aliceIW. How is it extended?
- How does the metadata of aliceIW at bobZone look like.
- It helps to draw a picture to keep track of the replication chain.

## B2STAGE-gridFTP

### CLI: globus-url-copy and uberftp

globus-url-copy  | uberftp | Meaning
------|------|-----
-help | -help |Help
-list | -ls |List directory
 |-cat| List contents of file
-p <n> | -parallel <n>
-r | -r (for deleting, transferring only single files) |Recurse
-cd | | Create destination upon transfer
|-mkdir |Create remote directory
-sync, -sync-level |  |Synchronise data
| -rm (-r), -rmdir | Remove files and folders


