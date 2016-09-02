# Working with Persistent Identifiers - Hands-on
This lecture takes you through the steps to create and administer PIDs employing the HTTP restful API of the handle server version 8.

## Warming-up: Using PIDs
Below you find three different PIDs and their corresponding global resolver

- Handle 

    PID: 11304/cf8956a2-39d3-11e5-8a18-f31aa6f4d448

    Resolver: http://hdl.handle.net/

- Doi

    PID: 10.3389/fgene.2013.00289

    Resolver: http://dx.doi.org/

- Ark 

    PID: ark:/13030/tf5p30086k

    Resolver: https://nbn-resolving.org/

You can either go to the resolver in your web browser and type in the PID to get to the data behind it. You can also concatenate the resolver and the PID.

**Try to resolve the handle PID with the DOI resolver and vice versa.**

**In the handle resolver you will find a box "Don't redirect to URLs", if you tick this box, what information do you get?**

Each PID consists of a *prefix* which is linked to an administratory domain (e.g. a journal) and a *suffix*. The prefix is handed out by an issuer such as CNRI for handle or DataCite for DOIs. Once you are admin of a prefix, you can register as many data objects as you want by extending the prefix with a suffix. Note, that the suffixes need to be unique for each data object.

## Managing PIDs

### Prerequisites

The code is based on cURL. cURL is an open source command line tool and library for transferring data with URL syntax. cURL is used in command lines or scripts to transfer data.

 * Please check the dependencies before you start.
 * You will also need test credentials for the epic server.


#### Install cURL dependencies

CURL: is an open source command line tool and library for transferring data with URL syntax.
On the training machines (Ubuntu) we installed cURL for you with: 

```py
apt-get install curl 
apt-get install uuid-runtime 
```

#### Own laptop

In case you are working on your own laptop with your own python, please install:

```py
easy_install curl
easy_install uuid-runtime
```
Final check
```sh
curl --help
```
##### MAC

The handle server works with certificate authentication and openssl. 
**On a MAC** you need to install curl via [homebrew](http://brew.sh/) and specify that it should use openssl:

```
brew install curl --with-openssl
```
For your convenience you can export this location to a variable and call it by
```
CURL=/usr/local/Cellar/curl/<version>/bin/curl
$CURL --help
```
Please replace \<version\> with the version you installed on your MAC.

If you write the code described below to a file, do not forget to change the permissions. 
You should make each file executable with `#!bash` in the very first line.

Suppose you have a file called `filename.sh` then 
you can make it executable by typing this on a shell:
```sh
chmod +x filename.sh
```

so it will execute when you type on the shell:
`./filename.sh`

#### Example workflow

1. Obtain a prefix from a resolver admin
2. Set up an internet connection to the PID server with a client
3. Create a PID
4. Link PID and location of the data object

In the tutorial below we will work with a test handle server located at SURFsara. 
That means the PIDs we create are not resolvable via the global handle resolver or via the DOI resolver.

#### For resolving PIDs please use:

`http://epic4.storage.surfsara.nl:8001`

### Main Parameters of CURL 

The main command
 
  `curl [options] [URL...]`
  
  
Before we start, we explain the main parameters of CURL used as options 

 * **-X, --request <command>**: (HTTP) Specifies a custom request method to use when communicating with the HTTP server. The specified request method will be used instead of the method otherwise used (which defaults to GET).  Common additional HTTP requests include PUT ,POST and DELETE . ( -X GET) 
 * **-U, --proxy-user <user:password>**: Specify the user name and password to use for proxy authentication. (ex: -u <username>:<pass>) 
 * **-H, --header <header>**: Extra header to include in the request when sending HTTP to a server. You may specify any number of extra headers. (ex: -H "Accept: application/json" so as to accept json data)
 * **-d, --data <data>**: (HTTP) Sends the specified data in a POST or PUT request to the HTTP server, in the same way that a browser does when a user has filled in an HTML form and presses the submit button. 
 * **-D, --dump-header <file>**: Write the protocol headers to the specified file.
 * **-v**: get verbosed information about the connection with the server 
 
These are the main parameters we are going to use in our examples. For more parameters please check [cURL]Chttps://curl.haxx.se/)

### Connect to the SURFsara handle server 

To connect to the handle server you need to provide a **prefix** and its respective **private key** and **certificate**, the latter two are pem-files. We will use a prefix *1000* registered as a test prefix at SURFsara. 
Since we use these parameters everytime we call curl, it is handy to store them in shell variables:

```sh
PRIVKEY=privkey.pem
CERTIFICATE=certificate_only.pem
PID_SERVER=https://epic4.storage.surfsara.nl:8001/api/handles
```
You will find the key and certificate in the folder *credentials* on the provided VMs. If you are using your own laptop, please contact us to obtain a test prefix and the respective pem-files.
```

## Registering a file with PUT

### We will register a public file from figshare. 

We are going to create a new PID by using the PUT request.
The request method is -X PUT followed by the actual json data 
```sh
-X PUT --data '{"values":[ 
    {
        "index":1,
        "type":"URL",
        "data": {
            "format": "string",
            "value": "www.test1.com"
        }
    },
    { 
        "index":100,
        "type":"HS_ADMIN",
        "data":{
            "format":"admin",
            "value":{
                "index":200,
                "handle":"0.NA/1000",
                "permissions":"011111110011",
                "format":"admin"
            }
        }
    }
]
}'
```
The second member of the list behind *values* sets the ownership of the handle and permission.
It will appear as *index 100* in the handle entry. The permissions correspond to 
`[create hdl,delete hdl,read val,modify val,del val,add val,modify admin,del admin,add admin]` 
where 1 means *allowed* and 0 *prohibited*. 

### Building the PID:

- Create a universally unique identifier (uuid)
- Take the function *uuidgen* for this
```sh
SUFFIX=`uuidgen`
```

- Concatenate your PID prefix and the uuid to create the full PID
` 1000/$SUFFIX `

Since the prefix is unique and we employed a uuid to create the suffix, we now have an opaque string which is unique to our resolver (1000/$SUFFIX).

The URL in the CURL request: 
```
https://epic4.storage.surfsara.nl:8001/api/handles/1000/$SUFFIX 
```
or when you set the variable *PID_SERVER*
```
$PID_SERVER/1000/$SUFFIX
```

## Registering a file with PUT

Register the PID, link the PID and the data object. Here we use a public csv file as data which is stored on figshare and publicly available.

```sh

SUFFIX=`uuidgen`

$CURL -k --key $PRIVKEY --cert $CERTIFICATE \
    -H "Content-Type:application/json" \
    -H 'Authorization: Handle clientCert="true"' \
    -X PUT --data \ 
        '{"values": [ 
            { "index": 1, "type": "URL",
                "data": {"format": "string",
                    "value": "data": "https://ndownloader.figshare.com/files/2292172"}}, 
            { "index": 100,"type": "HS_ADMIN",
                "data": {"format": "admin",
                "value": {"handle": "0.NA/1000","index": 200,"permissions": "011111110011"}}} ]}' 
$PID_SERVER/1000/$SUFFIX | python -m json.tool
```
This gives the response:
```
{"responseCode":1,"handle":"1000/AE919576-226E-412D-BC9D-73682DD207F5"}
```
indicating, that the handle was created.

### Responses 

* 1: Success (200 OK or 201 Created)
* 2: An unexpected error on the server (500 Internal Server Error)
* 100: Handle not found (404 Not Found)
* 101: Handle already exists (409 Conflict)
* 102: Invalid handle (400 Bad Request)
* 200: Values not found (in resolution, 200 OK; otherwise 400 Bad Request)
* 201: Value already exists (409 Conflict)
* 202: Invalid value (400 Bad Request)
* 301: Server not responsible for handle (400 Bad Request)
* 402: Authentication needed (401 Unauthorized)
* 40x: Other authentication errors (403 Forbidden)

Let us go to the resolver and see what is stored there
`http://epic4.storage.surfsara.nl:8001`. 
We can get some information on the data from the resolver.
We can retrieve the data object itself via the web-browser.

**Download the file via the resolver. Try to use *wget* when working remotely on our training machine.**

**How is the data stored when downloading via the browser and how via *wget*?**

**Have a look at the metadata stored in the PID entry.**

**Insoect the HS_ADMIN field**

**What happens if you try to reregister the file with the same PID?** 

### Rerieve the handle record

You can retrieve the PID record using the *GET* option of cURL
```sh
$CURL -k -X GET $PID_SERVER/1000/$SUFFIX | python -m json.tool
```
Here we do not need to authorise since the handle record is public.

**Which answer do you get when only retrieving $PID_SERVER/1000?**

### Overwrite handles
We saw in the last exercise, that the data in the handles can be overwritten. That is useful in some cases, as we will see later. However, upon registration you might want to check that you do not overwrite existing data.
A secure way to create handles is:

```sh
$CURL -k --key $PRIVKEY --cert $CERTIFICATE \
    -H "Content-Type:application/json" \
    -H 'Authorization: Handle clientCert="true"' \
    -X PUT --data \
        ''{"values": [ { "index": 1, "type": "URL",
                "data": {"format": "string",
                    "value": "https://ndownloader.figshare.com/files/2292172"}}, 
        { "index": 100,"type": "HS_ADMIN",
            "data": {"format": "admin",
                "value": {"handle": "0.NA/1000","index": 200,"permissions": "011111110011"}}} ]}' ' \
$PID_SERVER/$SUFFIX?overwrite=false | python -m json.tool
```
This will return the response *101*, inidicating that the handle already exists.

## Modify handles and store additional data 

Lets say that we want to add a new type with data 'Data Carpentry pandas example file'.
We have to update the json data
```
    -X PUT --data \
        '{"values":[
        {"index":2,"type":"TYPE",
            "data":"Data Carpentry pandas example file"},
        {"index":100,"type":"HS_ADMIN",
            "format":"admin",
            "data":{"value":{"index":200,"handle":"0.NA/1000",
                "permissions":"011111110011","format":"admin"}}}    
        ]}' \
```

And the actual request to add this to the existing handle is:

```sh
$CURL -k --key $PRIVKEY --cert $CERTIFICATE \
    -H "Content-Type:application/json" \
    -H 'Authorization: Handle clientCert="true"' \
    -X PUT --data \
        '{"values":[
        {"index":1,"type":"URL",
            "data": {"format": "string","value":"https://ndownloader.figshare.com/files/2292172"}},
        {"index":2,"type":"TYPE",
            "data": {"format": "string","value":"Data Carpentry pandas example file"}},
        {"index":3,"type":"FORMAT",
            "data": {"format": "string","value":"csv"}}]},
        {"index":100,"type":"HS_ADMIN",
            "data":{"value":{"index":200,"handle":"0.NA/1000",
                "permissions":"011111110011","format":"admin"},
            "format":"admin"}}]'
$PID_SERVER/1000/$SUFFIX | python -m json.tool
```
The handle API works with indexes. The very first index *index 1* is used by the resolver which expects a url. That is why we use "URL" as type, which makes it easier to debug if something goes wrong. It is a convention to use capital letters to define keys. 
Index 100 is reserved for the *HS_ADMIN*. All other indexes can be determined by the user.
The other indexes are free and can be customised.

With the resolver we can access this information. Note, this data is publicly available to anyone.

### Updating PID entries
In the previous example we have actually not overwritten the data in the handle but we created a new handle with the same suffix but different content.
Now let us see how we can add and modify entries.

We want to store information on the identity of the file that we have registered in the previous example, e.g. the md5 checksum. The file is called *surveys.csv*.
We first have to generate the checksum. However, we can only create checksums for files which we
have locally on our computer. In the step above we downloaded the file. So now we can continue to calculate the checksum. 
**NOTE** the filename might depend on the download method.

```sh
MD5VALUE=` md5 surveys.csv | awk '{ print $4 }'`

$CURL -k --key $PRIVKEY --cert $CERTIFICATE \    
    -H "Content-Type:application/json" \     
    -H 'Authorization: Handle clientCert="true"' \     
    -X PUT --data '{"index":3, "type":"MD5","data": {"format": "string","value": "'$MD5VALUE'"}}' \    
    $PID_SERVER/1000/$SUFFIX?index=3 | python -m json.tool
```

We can also update or add more fields at one time:
```sh
$CURL -k --key $PRIVKEY --cert $CERTIFICATE \
    -H "Content-Type:application/json" \ 
    -H 'Authorization: Handle clientCert="true"' \
    -X PUT --data '{"values": [
        {"index": 2, "ttl": 86400, "type": "TYPE",   "data": {"format": "string","value": "Data Carpentry file"}},
        {"index": 4,               "type": "SIZE",   "data": {"format": "string","value": "bla"}}, 
        {"index": 5, "ttl": 86400, "type": "FORMAT", "data": {"format": "string","value": "csv"}} ]}' \
    $PID_SERVER/1000/$SUFFIX?index=2\&index=4\&index=5
```

## Linking files by PIDs

Let us label the downloaded copy of the csv file with a new PID.
The file should reside in your download folder or at a location that you specified when using *wget* to download the file.
Replace <PATH> with the appropriate path and filename.
```sh
SUFFIX2=`uuidgen`
FILELOC=<PATH>
MD5SUM=` md5 $FILELOC | awk '{ print $4 }'`

$CURL -k --key $PRIVKEY --cert $CERTIFICATE \
    -H "Content-Type:application/json" \
    -H 'Authorization: Handle clientCert="true"' \
    -X PUT --data \
        '{"values":[
        {"index":1,"type":"URL",  "data": {"format": "string","value":"'$FILELOC'"}}, 
        {"index":2,"type":"TYPE", "data": {"format": "string","value":"Data Carpentry pandas example file"}},
        {"index":3,"type":"MD5",  "data": {"format": "string","value":"'$MD5SUM'"}},
        {"index":100,"type":"HS_ADMIN",
            "format":"admin",
            "data":{"value":{"index":200,"handle":"0.NA/1000",
                "permissions":"011111110011","format":"admin"}
            }}]}'
$PID_SERVER/1000/$SUFFIX | python -m json.tool
```

**Try to fetch some metadata on the file from the resolver.**
**Try to resolve directly to the file. What happens?**

We used a local path as "URL" pointing to a personal machine where the data is protected. 
That means you can no longer download the data directly, but you have access to the data stored in the PID.

* Information stored with the PID is ALWAYS public
* Data itself can lie on a protected server/computer and not be accessible for everyone

We have now two PIDs one pointing to the public file
```sh
echo 1000/$SUFFIX
```
and one pointing to our local copy of that public file
```sh
echo 1000/$SUFFIX2
```
We will link the two files using the keywork *REPLICA* and we will use index 4.

```sh
$CURL -k --key $PRIVKEY --cert $CERTIFICATE \
    -H "Content-Type:application/json" \
    -H 'Authorization: Handle clientCert="true"' \
    -X PUT --data '{"index":4, "type":"REPLICA","data": {"format": "string","value":"1000/'$SUFFIX2'"}}' \
    $PID_SERVER/1000/$SUFFIX?index=4 | python -m json.tool

$CURL -k --key $PRIVKEY --cert $CERTIFICATE \
    -H "Content-Type:application/json" \
    -H 'Authorization: Handle clientCert="true"' \
    -X PUT --data '{"index":4, "type":"REPLICA","data": {"format": "string","value":"1000/'$SUFFIX'"}}' \
    $PID_SERVER/1000/$SUFFIX2?index=4 | python -m json.tool
```

## PID resolving
How does the handle resolver actually know to which data object to resolve to? In the cases above we explicitely defined the field *URL* at index 1. What happens if index 1 contains different information, i.e. a different key buta URL as value.

**Exercise**
Create some PIDs and test these options:
* Change the key *URL* at index 1 to something else
* Change the value of the *URL* field to something that is not a URL.
* Define a key avlue pair *URL* and the respective value at a higher index and put somethig else in index 1.

## Delete handle entries and whole handles
In case we wish to remove the information on the checksum from the handle do this:

```sh
$CURL -k --key $PRIVKEY --cert $CERTIFICATE \
    -H "Content-Type:application/json" \
    -H 'Authorization: Handle clientCert="true"' \
    -X DELETE \
    $PID_SERVER/$SUFFIX?index=101 | python -m json.tool
```

Note, if you do not soecify the index in the URL pointing to your PID, the whole PID will be removed.



