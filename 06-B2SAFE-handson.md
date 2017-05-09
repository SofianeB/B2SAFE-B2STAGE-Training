# EUDAT B2SAFE hands-on
This hands-on will illustrate how B2SAFE rules can be employed to manage data across iRODS zones by policies.
It explicitely uses **B2SAFE v4**.
The tutorial makes use of the icommands. If you did not so then please first follow the tutorial on [using iRODS](https://github.com/chStaiger/B2SAFE-B2STAGE-Training/blob/master/01-iRODS-handson-user.md).

## B2SAFE data transfer workflow (Using B2SAFE)
### To follow this tutorial it is advised to first follow the tutorial on using iRODS.

### Outline
The tutorial will guide you through Step2 in the figure below.

As B2SAFE admin you will copy data from a user, which he/she ingested into the iRODS instance, to another location in iRODS. You will register the data and by that build the so-called repository of records and replicate the collection to another iRODS server using the B2SAFE rules. 

<img align="center" src="img/workflow.png" width="500px">

### Prerequisites
- Installation of the icommands
- As iRODS user ingest data into iRODS and give your B2SAFE admin (if you work with two accounts) access to the collection. These steps are explained in the iRODS-using tutorial. 

### iRODS rules
iRODS provides a way to execute data management procedures automatically and on regular bases or upon a certain action. To this end these procedures are defined in so-called iRODS rules.

A simple rule is:

```sh
HelloWorld {
  writeLine("stdout", "Hello, world!");
}
INPUT null
OUTPUT ruleExecOut
```

You can save this rule as hello.r and call it via the icommands:
```sh
irule -F hello.r
```
The option *-F* indicates that the next argument is a file.
iRODS provides some standard rules which you can find here
```sh
/etc/irods/core.re
```

You can retrieve and examine the B2SAFE rule base.
In your /home directory do
```sh
git clone https://github.com/EUDAT-B2SAFE/B2SAFE-core
```
You will find the B2SAFE rulebase in *B2SAFE-core/rulebase* and some testrules in *B2SAFE-core/rules*.

### Example: Using B2SAFE to register a file
You can use the B2SAFE rule *EUDATCreatePID* to register a single file. The rule is located in *B2SAFE-core/rulebase/pid-service.re*.

First let's ingest a data file into iRODS.
```sh
iput -f test.txt
```
Now let's write a rule which calls *EUDATCreatePID* and registers our *put1.txt*.
```sh
registerFile {
        #parameters: *parent_pid , *source, *ror, *fio, "true"(fixed content) , *newPID
        # *newPID is the return value
        EUDATCreatePID("None", *path, "None", "None", "false", *newPID);
}
INPUT *path = "/aliceZone/home/alice/put1.txt", *ror = "", *parent_pid =""
OUTPUT *newPID, ruleExecOut
```
Replace the variable *\*path* with the iRODS path to a file you uploaded and save this file as registerFile.r

The function takes several input parameters:
- *parent_pid*: If the data object or the collection is a replica, you can gove here the PID to the direct parent.
- *source*: The iRODS path to the data object or collection you want to label with a PID.
- *ror*: The repository of records. Of your file is a replica of a file from a repository you can provide the PID to the repository
- *fio*: The very first ingest point in the EUDAT domain. If the data object/collection is a replica of another data object/collection in EUDAT you can link here to the PID of the very first ingest point.
- *fixed-conetent*: Sets the policy to the collection/data object. If true, the object or collection is not to change anymore.

For replication B2SAFE uses these fields to introduce the correct linking between original data, parent data and replicas.
In *OUTPUT* we define which variables should be prompted on the command line, in this case we would like to receive the newly created PID.

Execute the rule:
```sh
irule -F testRules/registerFile.r
```
The answer will be the PID, e.g.:
```sh
*newPID = 21.T12995/2F2D7ED6-28F6-11E7-96FE-FA163EDB14FF
```

### Metadata in iRODS and the Handle registry for registered data

As soon as data is registered with the EUDAT rules some extra metadata in the iCAT metadata catalogue is stored:

```sh
imeta ls -d <FILE>
```

```
attribute: eudat_dpm_checksum_date:demoResc
value: 01493042347
units:
----
attribute: PID
value: 21.T12995/2f2d7ed6-28f6-11e7-96fe-fa163edb14ff
units:
----
attribute: EUDAT/FIXED_CONTENT
value: False
units:
```

This PID can be resolved here: http://hdl.handle.net. 

Enter the full PID string and tick the box *do not redirect to URLs*. This will show you the metadata stored with the PID. *URL* contains the iRODS path where to find the file. You will find that the B2SAFE rule also automatically calculated and stored a checksum. 

### B2SAFE Replication workflow


1. Copy the some user's data to an iRODS collection, here we take the example collection *aliceInWonderland*

        iput -K -r aliceInWonderland

2. Register all files in the collection using *EUDATPidsForColl*. Save the following file as testRules/eudatPidsColl.r and replace the user and collection name with your respective user and collection name.

  ```sh
  eudatPidsColl{
  # Create PIDs for all collections and objects in the collection recursivel            
  # The second variable designates the 'fixed_content'
  EUDATPidsForColl(*coll_path, *fixed_content);
  }
  INPUT *coll_path='/aliceZone/home/<user>/aliceInWonderland', *fixed_content="false"
  OUTPUT ruleExecOut
  ```    
 **Exercise**: Write a script, an iRODS rule or use a simple icommand to retrieve all PIDs of a data collection.

 **Exercise**: Do the PIDs change when you call the rule several times on a data object?

3. Replicate the data collection from aliceZone to bobZone. 

 Merely transferring the data could also be done by the icommand *irsync*. However, we would like to 1) calculate checksums, create PIDs  and link the replicas' PIDs with their parent counterparts. This is all already implemented by B2SAFE rules.
 Create the file testRules/Replication.r with the following content:
 ```sh       
 Replication {
  EUDATReplication(*source, *destination, "true", "true", *response)
 }
 INPUT *source="/aliceZone/home/<user>/aliceInWonderland",*destination="/bobZone/home/<user>#aliceZone/aliceInWonderland"
 OUTPUT ruleExecOut
 ```
### Metadata for replication

Let us first inspect the iCat metadata for our collection on *alice*.
- The previous metadata information was extended with a field *EUDAT/REPLICA*:

 ```
attribute: EUDAT/REPLICA
value: 21.T12996/fc186a38-28fa-11e7-8059-fa163ed79f1d
units:
----
attribute: EUDAT/FIXED_CONTENT
value: False
units:
----
attribute: PID
value: 21.T12995/877cb306-28f9-11e7-b391-fa163edb14ff
units:
 ```

**Exercise** Inspect the Handle entry of the PID.

Via the Handle system we can get to the replica. Here we find much more metadata:
- *EUDAT/ROR*: Repository of records, a (community) repository holding the very original file
- *EUDAT/FIO*: First ingest point in the EUDAT domain, i.e. first EUDAT repository holding a copy or the original
- *EUDAT/PARENT*: Direct parent of the replica

Via the iCAT keys and PID entries *EUDAT/REPLICA* and *EUDAT/PARENT*, a double linked list is introduced which can be employed to fetch all replicated data.

### Exercise: Using the linked PIDs. Retrieve the PIDs of the replicas.

Option 1)

Via iRODS you have access to the PIDs of the parent PID in your iCAT catalogue. 

**Exercise** If you already followed the [PID tutorial](https://github.com/eudat-training/B2SAFE-B2STAGE-Training) write a script to fetch all PIDs of the replicas and check whether original and replica indeed have the same checksum

Option 2)

**Exercise** Same as in Option 1) but use the information the two iCAT catalogues and the function *ichksum*. Tip: you can access the data and the iCAT of bobZone like this:

```sh
ils -L /bobZone/home/alice#aliceZone/DataCollection
imeta ls -d /bobZone/home/alice#aliceZone/DataCollection/test.txt
```
You can also use the *iquest* command to fetch information and files from the iCAT metadata catalogue.

**Exercise** Replicate the data from bobZone in a different collection in aliceZone, inspect the PID entries and write a script to communicate the whole linked list of PIDs to your irods user, e.g. as a text file.


For more exercises please refer to the [ExampleTrainings](https://github.com/EUDAT-Training/B2SAFE-B2STAGE-Training/tree/master/ExampleTrainings).

[]()|[]()|[]()
----|----|----
[Previous](05-iRODS-advanced-users.md)|[Index](B2SAFE-B2STAGE-Training)  | Next **PID Training - Module 07 **
