# iRODS compound resource - SWIFT
iRODS provides a plugin for [S3](https://github.com/irods/irods_resource_plugin_s3).
However, when you have an old-fashioned SWIFT cluster not supporting an S3 client you attach the SWIFT cluster in a compound resource as archive resource. Here we provide instructions on how to setup the driver script with the [python-swift-client](https://docs.openstack.org/cli-reference/swift.html).

## Install SWIFT client and test

```sh
sudo pip install python-swiftclient
sudo pip install python-swiftclient --upgrade
```

To test, export your credentials and do a list:

```sh
export ST_AUTH=https://<SWIFT cluster>/auth/v1.0
export ST_USER=<USER>
export ST_KEY=<PASSWORD>
```

Create a container that we can use as iRODS vault:

```sh
swift post iRODS-Vault
swift list
```

## Creating the resource tree

```sh
sudo mkdir /S3cache
sudo chown -R <user who runs iRODS> /S3cache
```

```sh
iadmin mkresc S3cache unixfilesystem <fqdn of your iRODS server>:/S3cache
iadmin mkresc SWIFTresc univmss <fqdn of your iRODS server>:iRODS-Vault univMSSInterface_swift.sh
iadmin mkresc S3compound compound
```

The resource tree should look like this:

```sh
S3compound:compound
├── S3cache
└── SWIFTresc:univmss
```

## Writing the driver script
We provide a very simple deiver script in *scripts/univMSSInterface_swift.sh*.
The script employs the python-swiftclient to implement the relevant functions. Note that you will need 

```sh
swift --version
python-swiftclient 3.3.0
```
or higher.


