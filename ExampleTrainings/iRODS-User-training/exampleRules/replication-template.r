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
    msiCollRsync(*home++"/"++*source, *destination++"/"++*source,
        "null","IRODS_TO_IRODS",*rsyncStatus);
    # iRODS microservice for irsync for data objects
    #msiDataObjRsync(*home++"/"++*source,"IRODS_TO_IRODS","null",
    #   *destination++"/aliceText.txt",*rsyncStatus);
    writeLine("stdout", "Irsync status: *rsyncStatus");
    
    # create some metadata and link it to the source and
    # example for the collection "archive"
    # Verify with icommands imeta ls -C archive
    # How do you create an AVU for your remote collection?

    *MDKey   = "TYPE";
    *MDValue = *source_type;
    *Path = *home++"/"++*source;
    createAVU(*MDKey, *MDValue, *Path);

    writeLine("stdout", "");
    
    # Loop over all data objects in your archive collection in aliceZone
    # Set the field REPLICA for all data objects in archive
    # Set the field ORIGINAL for all replicated data objects
    
    #foreach(*row in SELECT COLL_NAME, DATA_NAME where COLL_NAME like <FILL_IN>){
        #*coll = *row.COLL_NAME;
        #*data = *row.DATA_NAME; # this is your local file on alice
        #*repl = <FILL IN the string that determines the remote file>;
        #*path = <FILL IN your local path on aliceZone>;
        #writeLine("stdout", *path);
        #writeLine("stdout", "Metadata for *path:");
        
        #createAVU("TYPE", <FILL IN>, <FILL IN>);
        #createAVU("REPLICA", <FILL IN>, <FILL IN>);
        #writeLine("stdout", "");

        #writeLine("stdout", "Metadata for *repl:");
        #createAVU("TYPE", <FILL IN>, <FILL IN>);
        #createAVU("ORIGINAL", <FILL IN>, <FILL IN>);
        #writeLine("stdout", "");
    #}
}

createAVU(*key, *value, *path){
    #Creates a key-value pair and connects it to a data object or collection 
    msiAddKeyVal(*Keyval,*key, *value);
    writeKeyValPairs("stdout", *Keyval, " is : ");
    msiGetObjType(*path,*objType);
    msiSetKeyValuePairsToObj(*Keyval, *path, *objType);
}

INPUT *source="archive", *destination=""
OUTPUT ruleExecOut
