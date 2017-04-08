replication{
    # create base path to your home collection
    *home="/$rodsZoneClient/home/$userNameClient";
    # by default we stay in the same iRODS zone
    # --> How do you have to alter *destination to replicate to bobZone? 
    if(*destination == ""){ *destination = *home++"/test"}  
    writeLine("stdout", "Replicate *home/*source");
    writeLine("stdout", "Destination *destination/*source");

    # check whether it is a collection (-c) or a data object (-d)
    # *source_type catches return value of the function
    msiGetObjType(*home++"/"++*source,*source_type);
    writeLine("stdout", "*source is of type *source_type");

    # choose the right replication microservice 

    # iRODS microservice for irsync for collections
    # 3rd parameter is the target resource which we leave empty.
    # *rsyncStatus is a variable returned by the function
    msiCollRsync(*home++"/"++*source, *destination++"/"++*source,"null","IRODS_TO_IRODS",*rsyncStatus);
    # iRODS microservice for irsync for data objects
    #msiDataObjRsync(*home++"/"++*source,"IRODS_TO_IRODS","null",*destination++"/aliceText.txt",*rsyncStatus);
    writeLine("stdout", "Irsync status: *rsyncStatus"); # is 0 when there is nothing to sync

    # create some metadata and link it to the source and
    # example for the collection "archive"
    # Verify with icommands imeta ls -C archive

    *MDKey   = "TYPE";
    *MDValue = *source_type;
    *Path = *home++"/"++*source;
    createAVU(*MDKey, *MDValue, *Path);

    writeLine("stdout", "");
    # Loop over all data objects in your archive collection in aliceZone
    # Set the field REPLICA for the data objects in archive
    # Set the field ORIGINAL for the data objects in the replicas 
    foreach(*row in SELECT COLL_NAME, DATA_NAME where COLL_NAME like "*home/*source"){
        *coll = *row.COLL_NAME;
        *data = *row.DATA_NAME;
        *repl = *destination++"/"++*source++"/"++*data;
        *path = *coll++"/"++*data;
        writeLine("stdout", *path);
        writeLine("stdout", "Metadata for *path:");

        msiGetObjType(*path,*objType);
        createAVU("TYPE", *objType, *path);
        createAVU("REPLICA", *repl, *path);
        writeLine("stdout", "");

        writeLine("stdout", "Metadata for *repl:");
        createAVU("TYPE", *objType, *repl);
        createAVU("ORIGINAL", *path, *repl);
        writeLine("stdout", "");
    }
}

createAVU(*key, *value, *path){
    msiAddKeyVal(*Keyval,*key, *value);
    writeKeyValPairs("stdout", *Keyval, " is : ");
    msiGetObjType(*path,*objType);
    msiSetKeyValuePairsToObj(*Keyval, *path, *objType);
}

INPUT *source="archive", *destination="/bobZone/home/di4r-user1#aliceZone"
OUTPUT ruleExecOut
