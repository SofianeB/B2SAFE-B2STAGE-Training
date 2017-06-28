# PID Demonstration

Training material for the EUDAT summer school on 3-7 July 2017 in Heraklion. 
In this training we are going to use the last version of B2Handle (1.1.1).
The library offers methods to create, update and delete Handles as well as advanced functionality such as searching over Handles using an additional search servlet and managing multiple location entries per Handle.

Sofiane Bendoukha (DKRZ), Christine Staiger (SURFsara) July 2017

## Plan

We will cover:
 * Resolving Handle records 
 * Authenticating with the Handle server using certificates 
 * Modifying and updating Handles
 * Registering a file 
 * Reverse look-ups
 
## What is B2Handle?

The b2handle Python library is a client library for interaction with a [Handle System](https://handle.net) server, using the native REST interface introduced in Handle System 8. The library offers methods to create, update and delete Handles as well as advanced functionality such as searching over Handles using an additional search servlet and managing multiple location entries per Handle.

The library currently supports Python 2.6, 2.7 and 3.5, and requires at least a Handle System server 8.1.

## Setup

ssh di4r-user*@145.100.59.156

ipython



## 1. The EUDATHandleClient 


First, we have to import the B2Handle library. 
The library is used by creating a client object and using its methods to interact with the Global Handle System.


```py
from b2handle.handleclient import EUDATHandleClient 
```
The help() method gives us usefull information about its methods.


## 2. Resolving Handles
It is easy to resolve a handle and read its handle record using the B2Handle library. For this, we instantiate the 
client in read-mode and use its reading methods.

### (2.1) Instantiation of the client

```py
client = EUDATHandleClient.instantiate_for_read_access()
```

Now we can use its various reading methods, for example get_value_from_handle(handle) or retrieve_handle_record(handle).

For example, retrieve_handle_record(handle) returns a dictionary of the record's entries:

```py
handle = '21.T12995/TESTHANDLE'
record = client.retrieve_handle_record(handle)
print(record)
```

{'URL': 'https://ndownloader.figshare.com/files/2292172', 'HS_ADMIN': "{'index': 200, 'handle': '0.NA/21.T12995', 
'permissions': '011111110011'}", 'CREATION_DATE': '04-07-2017'}


We can access individual values using:

```py 
value1 = client.get_value_from_handle(handle, 'URL')
value2 = client.get_value_from_handle(handle, 'CREATION_DATE') 
print(value1)
print(value2)
```

https://ndownloader.figshare.com/files/2292172

04-07-2017

### (2.2) Decreasing server interactions (optional) 

The method get_value_from_handle() accesses the Handle Server each time. This is a performance slowdown. To avoid it, it is possible to retrieve the record once and then pass it on to the reading methods.

This retrieves the record from the server:

```python
handlerecord_json = client.retrieve_handle_record_json(handle)
```

If you pass it to the reading methods, these do not access the Handle Server anymore:

```python
print(client.get_value_from_handle(handle, 'CREATION_DATE', handlerecord_json))
```

03-07-2017

## 3. Updating Handle records

Now we are going to modify one of the values of that Handle record. 
The client provides a method for this: 

```python
modify_handle_value(handle, ...)
```

Let's try it - let's change the creation date from '03-07-2017' to '04-07-2017'.


### 3.1 Write access to the Handle server

For modifying, creating and deleting Handle records, we first need to authenticate. In this tutorial, we will use 
client certificates. There is other methods, e.g. username and password.
  

####  Authentication with client certificates 

Authenticating using client certificates is secure. 
For this, the user provides his private key and his certificate with every write request.

To use client-side certificates for authentication, the user has to pass a certificate and a private key along with every write request. Just like the password authentication, the library handles this for the user.

For this, the library either needs a file containing private key and certificate, or both as separate files. To simplify those three different ways of authenticating, there is a special class, called PIDClientCredentials

```python
from b2handle.clientcredentials import PIDClientCredentials
cred = PIDClientCredentials.load_from_JSON(
	'cred_21.T12995.json')
client = Client.instantiate_with_credentials(cred)
```

Have a look at your credentials

```python
cred.get_all_args()
```

```
{'HTTPS_verify': 'False',
 'certificate_only': '308_21.T12995_TRAINING_certificate_only.pem',
 'credentials_filename': 'cred_21.T12995.json',
 'handle_server_url': 'https://epic4.storage.surfsara.nl:8007',
 'handleowner': '200:0.NA/21.T12995',
 'prefix': '21.T12995',
 'private_key': '308_21.T12995_TRAINING_privkey.pem',
 'reverselookup_baseuri': None,
 'reverselookup_password': '6754czhf65jhgujzg65765',
 'reverselookup_username': '21.T12995'}

```


### 3.2  modifying Handle records

#### modify existing values

Now we can try to modify again:

```python
client.modify_handle_value(handle, CREATION_DATE='04-07-2017')
```
Let's check again if it worked!

```python
print(client.get_value_from_handle(handle, 'CREATION_DATE'))
```

04-07-2017

#### adding new values (create some Metadata)

With the same method, we can add new values to the Handle record.

```python
client.modify_handle_value(handle, TYPE='file')
print(client.retrieve_handle_record(handle))
```

```
{'URL': 'https://ndownloader.figshare.com/files/2292172', 'TYPE': 'file', 'HS_ADMIN': "{'index': 200, 'handle': '0
.NA/21.T12995', 'permissions': '011111110011'}", 'CREATION_DATE': '04-07-2017'}

```
To prevent adding new values (for example in case of typos) we can set a flag:

```python
client.modify_handle_value(handle, CREATION_DATE='03-07-2017', add_if_not_exist=False)
client.modify_handle_value(handle, RCEATION='04-07-2017', add_if_not_exist=False)
print(client.retrieve_handle_record(handle))
```

#### deleting values 
In case we did not set the flag and accidently wrote a wrong entry, the _delete_handle_value()_
methos allows to delete that entry:

```python
client.modify_handle_value(handle, RCEATION_DATE='04-07-2017')
print('added wrong value:')
print(client.get_value_from_handle(handle, 'RCEATION_DATE'))
```
```python
client.delete_handle_value(handle, 'RCEATION_DATE')
print('deleted wrong value')
print(client.get_value_from_handle(handle, 'RCEATION_DATE'))
```

None

# 4. Creating Handle records

In their simple form, PIDs are simple redirection to URL. In this case all they have is an entry that stores the URL.
You can simply create such a handle using the method register_handle():

## Store file location in python variable

```python
location = 'https://ndownloader.figshare.com/files/2292172'
```


## Create PID for the public file

```python
newhandle = prefix+'/TESTHANDLE'

Handle = client.register_handle(newhandle, location)
```

The prefix can also be retrieved from credentials

```python
prefix = cred.get_prefix()
```
```commandline

'21.T12995/TESTHANDLE'
```

If we execute this code a second time - or if another participant of the course has already executed it -, we run into an error: "HandleAlreadyExistsException". Of course - that handle record has already been created! 

```commandline

HandleAlreadyExistsException              Traceback (most recent call last)
<ipython-input-93-6cb89defe343> in <module>()
----> 1 client.register_handle(handle, url)

/usr/local/lib/python2.7/dist-packages/b2handle-1.1.1-py2.7.egg/b2handle/handleclient.pyc in register_handle(self, handle, location, checksum, additional_URLs, overwrite, **extratypes)
    854                 msg = 'Could not register handle'
    855                 LOGGER.error(msg + ', as it already exists.')
--> 856                 raise HandleAlreadyExistsException(handle=handle, msg=msg)
    857 
    858         # Create admin entry

HandleAlreadyExistsException: Handle 21.T12995/TESTHANDLE already exists: Could not register handle.

```

If we are really sure we would like to overwrite it, we can specify this:

```python
client.register_handle(newhandle, location, overwrite=True)
```


To avoid running into this problem and having to decide whether to overwrite or not, it is always preferrable to use UUIDs as handle suffixes. Using "speaking names", i.e. suffixes with semantics, is strongly discouraged.

The library provides an easy way to generate such a handle name. In this case, don't forget to store the handle name in a variable for further use.

```python
uuidhandle = client.generate_PID_name(prefix)
print(uuidhandle)
```

```commandline
21.T12995/33c686e5-4a7e-44c6-a8fe-81cd91ca32d6
```

And it's even easier to generate the name and register the handle at the same time. Again, don't forget to store the 
name.

```python
uuidhandle = client.generate_and_register_handle(prefix, location)
print(uuidhandle)
```

```python
21.T12995/33c686e5-4a7e-44c6-a8fe-81cd91ca32d6

```


We can check the contents of this newly created handle record:

```python
record = client.retrieve_handle_record(uuidhandle)
```

# Download file by PID

In ipython normal shell commands can  be executed with !in front of the command

```commandline
Handle
!wget http://hdl.handle.net/<handle>
uuidhandle
!cat <uuidhandle>

```

## Create a PID for the local file 

We will create now a PID for the locally downloaded file

```python
location = '/home/user-di4rX/'+ str(uid)
uid = uuid.uuid1()
print(uid)
pid = cred.get_prefix() + '/' + str(uid)
print(pid)
HandleLocal = client.register_handle(pid, location)
print(HandleLocal)
```

## Link the two files on PID level

```python
client.modify_handle_value(Handle, ttl=None, add_if_not_exist=True, **dict([('REPLICA', HandleLocal)]))
client.modify_handle_value(HandleLocal, ttl=None, add_if_not_exist=True, **dict([('ORIGINAL', Handle)]))

```

## Move data and update PID

The linux file name of our local name is pretty ugly and we want to rename it. What would be the workflow to do so without breaking the PID linking?

1. First we create a copy of the respective file under the new shiny name:
```commandline
cp \<Path\> surveys-local.csv
```

2. Then we need to redirect the PID pointing to the lopal file and set the field URL to the new path:

```python
client.modify_handle_value(HandleLocal, ttl=None, add_if_not_exist=True, 
   **dict([('URL', '/home/di4r-userX/surveys-local.csv')]))
```

3. Now we can safely remove the old file 

```python
!rm <Handle>
```

Verify that we did not break the linking between the local and the public file.

# 5. (Extra) Reverse look-ups

We have seen how to retreieve data and PID entries when given the PID. Assume you only know some characteristic like the checksum or the URL. How can you retrieve the PID?

```python
rev = dict([('URL', 'irods:*')])
result = ec.search_handle(**rev)
result
```

This fetches all PIDs stored in iRODS (B2SAFE) on the local Handle server with the respective string in the field URL no matter under which prefix they were created.

The reverse lookup works with wildcards.

If we saved the checksum with our files, we could retrieve how many times the same file has been saved.

Note, that reverse lookups only work on the local Handle server. I.e. you cannot retrieve PIDs registered on other Handle servers.
