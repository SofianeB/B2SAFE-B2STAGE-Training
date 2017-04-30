# PID Demonstration

We will demonstrate how to use EUDAT's python library B2HANDLE how to 
- generate PIDs
- link a file and a PID
- link two files via PIDs

You can follow and resolve the created PIDs and check their PID entries.

## Setup
```sh
ssh di4r-uerX@145.100.58.13
ipython 
```

## Connection

```py
from b2handle.clientcredentials import PIDClientCredentials
from b2handle.handleclient import EUDATHandleClient

import uuid
import hashlib
import os, shutil

cred = PIDClientCredentials.load_from_JSON(
	'cred_21.T12995.json')
ec = EUDATHandleClient.instantiate_with_credentials(cred)
```

Have look at your credentials
```py
cred.get_all_args()
```

- *baseuri*: Address of the local handle server, needed to create, update and delete Handles
- Certificates to authenticate with the local handle server
- *prefix*: Handle prefix
- *reverse_lookup* parameters: credentials for the reverse lookup servelet on the local handle server, EUDAT specific - not every handle server has such a servelet, will not work with the global handle resolver

## Create a PID for a public file
### 1. Store file location in python variable

```py
location = 'https://ndownloader.figshare.com/files/2292172'
```

### 2. Create suffix

```py
uid = uuid.uuid1()
print(uid)
```

### 3. Create PID in the Handle system

```py
pid = cred.get_prefix() + '/' + str(uid)
print(pid)
Handle = ec.register_handle(pid, location)
print(Handle)
```

## Download file by PID
In **ipython** normal shell commands can be executed with the *!* in front of the command.

```py
Handle
!wget http://hdl.handle.net/<Handle>
uid
!cat <uid>
```
How is the file saved? Try to resolve via the webbrowser. How is the file saved on your laptop?

We will need the file (downloaded with wget) later, keep it safe.

## Retrieving the PID record

```py
ec.retrieve_handle_record(Handle)
```

Retrieving the Handle record via the browser looks slightly different:

```
http://hdl.handle.net/<PID>?noredirect
```

B2HANDLE creates two entries in the Handle record:

- **URL**: The address of the data object, if the string here is compliant with HTTP the PID will resolve, if not the user will receive an error.

- **HS_ADMIN**: 
	- Is stored at index 100 
	- the permissions correspond to: [create hdl,delete hdl,read val,modify val,del val,add val,modify admin,del admin,add admin]; you as the Handle owner are not allowed to recreate the same Handle again, otherwise you are free to do what ever you want **including deleting Handles**.

- Conventions
	- Index 1 is always the URL
	- Keys are always capitalised	

## Create some metadata
We can create some extra metadata that will show up in the PID entry:

```py
args = dict([('TYPE', 'file')])
ec.modify_handle_value(Handle, ttl=None, add_if_not_exist=True, **args)
ec.retrieve_handle_record(Handle)
```

B2HANDLE takes the next free index and creates the key-value pair. B2HANDLE will thus also not overwrite the **HS_ADMIN** entry automatically when you create more than 100 key-value pairs.

## Create a PID for the local file
We will create now a PID for the loaclly downloaded file

```py
location = '/home/user-di4rX/'+str(uid)
uid = uuid.uuid1()
print(uid)
pid = cred.get_prefix() + '/' + str(uid)
print(pid)
HandleLocal = ec.register_handle(pid, location)
print(HandleLocal)
```

## Exercise
Try to download this file. 

- What goes wrong here?
- When would you use non resolvable PIDs?


Lessons to learn:

- If the link provided in the URL field is compliant with HTTP the Handle system cannot resolve. Here the PID is not resolvable since the file is not publicly accessible.
- You can reference private data and include them in a data registry. Registering data with Handles does not mean to open the data for the public.
- If the URL field does not resolve, you should not hand these PIDs out to normal users. But you can employ them in user portals or for applications that know how to access the data behind the PIDs, an example is the usage of PIDs in B2SAFE and B2STAGE.


## Link the two files on PID level
```sh
ec.modify_handle_value(Handle, ttl=None, add_if_not_exist=True, 
	**dict([('REPLICA', HandleLocal)]))
ec.modify_handle_value(HandleLocal, ttl=None, add_if_not_exist=True, 
	**dict([('ORIGINAL', Handle)]))
```

## Move data and update PID
The linux file name of our local name is pretty ugly and we want to rename it.
What would be the workflow to do so without breaking the PID linking?

1. First we create a copy of the respective file under the new shiny name:

 ```py 
 cp \<PATH\> surveys-local.csv
 ```

2. Then we need to redirect the PID pointing to the lopal file and set the field **URL** to the new path:

 ```py
 ec.modify_handle_value(HandleLocal, ttl=None, add_if_not_exist=True, 
	**dict([('URL', '/home/di4r-userX/surveys-local.csv')]))
 ```
 
3. Now we can safely remove the old file.

  ```py
  Handle
  !rm <Handle>
  ```
  
Verify that we did not break the linking between the local and the public file.

## (Extra) Reverse look-ups
We have seen how to retreieve data and PID entries when given the PID. Assume you only know some characteristic like the checksum or the URL. How can you retrieve the PID?

```py
rev = dict([('URL', 'irods:*')])
result = ec.search_handle(**rev)
result
```
This fetches all PIDs stored in iRODS (B2SAFE) on the local Handle server with the respective string in the field **URL** no matter under which prefix they were created.

The reverse lookup works with wildcards.

If we saved the checksum with our files, we could retrieve how many times the same file has been saved.

**Note**, that reverse lookups only work on the local Handle server. I.e. you cannot retrieve PIDs registered on other Handle servers.

