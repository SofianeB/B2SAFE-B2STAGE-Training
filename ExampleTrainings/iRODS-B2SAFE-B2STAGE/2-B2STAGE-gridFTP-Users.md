# B2STAGE-gridFTP for users
Please follow first part 1 on B2SAFE.

## What will we learn?
- Steer data between our laptop/userinterface and iRODS with gridFTP
- Execute third party transfers with gridFTP between a gridFTP enabled iRODS server and a 'normal' gridFTP server

## B2STAGE: Data management in iRODS with gridFTP
We extended the iRODS with a gridFTP endpoint and coupled it to the iRODS instance. 
This is what the technology B2STAGE does. It also includes automatic PID resolving.
As result you can use gridFTP tools like *globus-url-copy* to copy, delete and manage your data in the iRODS logical namespace.

### Upload data to iRODS with *globus-url-copy*
Reupload your collections again and store it under a different iRODS path.

Ensure you are in your user directory of the remote *aliceZone*: 

```
ipwd
icd /aliceZone/home/<username>/
ipwd
```

First create a grid proxy from your certificate:

```
grid-proxy-init
```

then you can use the follwoing command to upload your whole collection to a new iRODS collection

```
imkdir GridFTPColl
globus-url-copy -r aliceInWonderland/ gsiftp://alice-server/aliceZone/home/di4r-user1/GridFTPColl/ 
```
- *gsiftp* dentotes the endpoint and protocol
- *alice-server* is the short cut for the gridFTP server, (inspect mapping in /etc/hosts)
- *aliceZone/home/<username>/GridFTPColl/* is the iRODS path, where `<username>` is replaced with your username.

Check with 

```
ils -L GridFTPColl
```
to see what happened.

### Remarks

With the options *-sync* and *-sync-level* of the `globus-url-copy` command you can determine which files to update. Note, that 
these commands will perform checksum calculations but will not store them in the iCAT catalogue.

With the command `grid-proxy-info` you can get information about the state of the current proxy certificate. Ensure that time left 
is larger than zero.

What is a proxy certificate? To interact directly with a remote service a certificate can be used to prove identity. However, in the 
grid world it is often necessary for a remote service to act on a user's behalf.
One could imagine sending the private key to remote services, however this is very insecure. On the grid, a proxy allows limited 
delegation of rights. Strictly speaking, a proxy is also a certificate, but usually the unqualified term "certificate" is reserved for 
something issued by a certificate authority (CA). Proxies normally have a rather short lifetime, typically 12 hours.

## Retrieve data by PID
In the previous section we labeled files with PIDs. The B2SAFE module, however, does not only label files with PIDs but also Collections. 
These PIDs can be used to list and retrieve and list data with gridFTP.

```
imeta ls -C aliceInWonderland
globus-url-copy -list gsiftp://alice-server/21.T12995/88ea102c-1cff-11e7-a500-040091643b25/
```

Note: replace the pid value in the `globus-url-copy` command with the correct output from the `imeta ls` command.

We replaced the iRODS path with the PID for the collection.
The GridFTP tries to find the file, when this fails it tries to resolve the file path. If this is successful and the URL field in the 
PID contains a path to which this gridFTP instance has access to, you can retrieve the file(s).

Download data via PID from iRODS to your local file system:

```
globus-url-copy -cd gsiftp://alice-server/21.T12995/88ea102c-1cff-11e7-a500-040091643b25/ NewCollGsi/
ls NewCollGsi
```
Note: make sure to update the pid value again.

### Exercise: Retrieving data from a remote iRODS zone (15min)
With iRODS we could access data on *aliceZone* and *bobZone*. However, we could not simply retrieve them by PID.

What happens if we try to list data on the two iRODS servers with gridFTP?
Try the following options, which work and why?

- List data in *aliceZone*

 ```
 globus-url-copy -list \
 gsiftp://alice-server/aliceZone/home/di4r-user1/aliceInWonderland/
 ```
- List data in *bobZone* via the logical path with respect to *aliceZone*

 With *globus-url-copy*	

 ```
 globus-url-copy -list \
 gsiftp://alice-server/bobZone/home/di4r-user1#aliceZone/aliceInWonderland/
 ```
 
 With *uberftp*

 ```
 uberftp -ls \
 gsiftp://alice-server/bobZone/home/di4r-user1#aliceZone/aliceInWonderland/
 ```
- List data in *aliceZone* referring to the by PID
 
 ```
 imeta ls -C /aliceZone/home/di4r-user1/aliceInWonderland
 ```
 
 ```
 globus-url-copy -list gsiftp://alice-server/<PID>/
 ```
- List data in *bobZone* referring to the by PID

 ```
 imeta ls -C /bobZone/home/di4r-user1#aliceZone/aliceInWonderland
 ```
 Note, the PIDs referring to data in *bobZone* use the prefix **21.T12996**
 ```
 uberftp -ls gsiftp://alice-server/<PID>/
 ```
 Why can the gridFTP server linked to *aliceZone* not retrieve the data?


## Third party transfers
You can steer data flows between gridFTP endpoints from an external client. We will not send data from our iRODS server to another 
gridFTP server (which accidentially also lies on the machine where the iRODS bobZone is located. However, they are NOT connected.).
We will transfer the data behind a PID:

```
imeta ls -C aliceInWonderland
```

to the other gridFTP server. 
You all have access to the same unix account on the second gridFTP server. So it is wise to create and own folder there upon transfer.

```
globus-url-copy -cd gsiftp://alice-server/21.T12995/88ea102c-1cff-11e7-a500-040091643b25/ gsiftp://bob-server/home/di4r/collUser1/
```

```
globus-url-copy -list gsiftp://bob-server/home/di4r/collUser1/
```

On the other server the files in *aliceInWonderland* are saved in *collUser1*.

And we can put data from another gridFTP endpoint into iRODS via the gridFTP protocol:
We fetch one of the data files we have just saved in the *di4r/collUser1* directory of the gridFTP endpoint and save it as *aliceStories* 
in our iRODS (alice) instance:

```
globus-url-copy -cd gsiftp://bob-server/home/di4r/collUser1/ gsiftp://alice-server/aliceZone/home/di4r-user1/aliceStories/

ils aliceStories
```

### Remarks

What is a third party transfer? A third party transfers is a transfer between two remote servers.

# What have we learned?
- We can use iRODS to upload, manage and annotate data
- We can steer dataflows between iRODS instances with the iRODS native icommands
- We can steer data between our laptop/userinterface and iRODS with gridFTP
- We can execute third party transfers with gridFTP between a gridFTP enabled iRODS server and a 'normal' gridFTP server 

