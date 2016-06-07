# B2SAFE-B2STAGE-Training
<img align="right" src="img/B2SAFE.png" width="100px">
<img align="right" src="img/B2STAGE.png" width="100px">
<img align="right" src="img/B2HANDLE.png" width="100px">
## Contents
This training module provides hands-on material for iRODS4, EUDAT B2SAFE, B2STAGE and persistent identifiers, more specifically handles (handle version 8).

Please consult the user [documentation on the services](https://eudat.eu/services/userdoc) for a general introduction, if needed, before following the contents of this git repository. The online training material foresees two types of trainees: those who want to learn how to **deploy**  and integrate the EUDAT B2SAFE and B2STAGE services as *site admins*; and those who prefer to only learn how to **use** such services. I.e. following the "use" part of the training will familiarise you with the APIs of the services, but not with the underlying technology and its wiring, whereas following the full in-depth tutorial will allow you to understand how the components of a service are combined and thus enables you to also extend the integration of services at the low-level (technology-level rather than API level).

The order of the markdown files proposes the curriculum of the training. Each component takes about 1 hour.

File | Target audience
------|-------------------
00-install-iRODS4.md | site admins
01-iRODS-handson-user.md | researchers
02-iRODS-handson-admin.md	| site admins and interested researchers
03-install-B2SAFE.md	| site admins
04-iRODS_federations_configuration.md	| site admins and interested researchers
05-iRODS-advanced-users.md	| site admins and researchers
06-B2SAFE-handson.md	| site admins and data managers
07\*-Working-with-PIDs_\*.md | site admins and interested researchers
08-install-B2STAGE.md | site admins
09-using-B2STAGE.md | researchers, last exercise is a joint effort between researchers and site admins

## Setup
During the tutorial site admins and users will jointly setup an infrastructure like indicated in the picture below.

<img align="centre" src="img/VM-setup.png" width="800px">

### Users - Training
Users can get access to a setup of virtual machines (VMs) like above. The tutorial will show them the functionality of single components and how to combine them in order to arrive at proper data management.
Users can either choose to setup their personal computer to resemble the user interface machine or they can receive a login on a user interface VM.
Via the user interface machine they can access the first VM which contains an iRODS server, a gridFTP server, and the B2SAFE module.
Another VM holds another iRODS server. Both iRODS grids are federtated and users can transfer data from one grid to the other.
The client VM also provides the necessary python libraries to work with the *epicclient* and b2handle.

To get access to the training environment, please use the [EUDAT contact pages](https://eudat.eu/support-request?service=DOCUMENTATION); and provide some details on which community you are from and in which context you would like to follow the tutorial. 

The appropriate parts of the tutorial you can follow in the training environment are labeled with "researchers", "interested researchers" and "datamanagers" in the table above.

### Site admins - Training
Site admins will be guided through all steps to setup the environment, covering iRODS installation and federation, setting up B2SAFE, deploying a gridFTP endpoint and pointing it to the iRODS server via the data staging interface. To build the setup you will need to prepare or have access to three distinct (potentially virtualised) computational resources; each with e.g. 2 vCPU, 8GB memory, 100GB disk; running a Linux operating system (Ubuntu preferred); in which you have sudo rights. You will also need extra credentials for the persistent identifiers part. To receive some credentials please use the [EUDAT contact pages](https://eudat.eu/support-request?service=DOCUMENTATION); and provide some details on which community you are from and in which context you would like to follow the tutorial. 

### Persistent identifiers (PIDs)
In the tutorial we will explain how to create, update and delete PIDs. The infrastructure to manage PIDs is provided by SURFsara.
Note that all instances (B2SAFE, user modules) will make use of the same PID prefix. To follow this part of the tutorial you need extra credentials. We will provide you with these credentials via [EUDAT contact pages](https://eudat.eu/support-request?service=DOCUMENTATION); please provide some details on which community you are from and in which context you would like to follow the tutorial. 

