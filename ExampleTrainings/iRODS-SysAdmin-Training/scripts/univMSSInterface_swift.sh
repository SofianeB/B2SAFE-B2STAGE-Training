#!/bin/bash

# based on https://github.com/irods/irods/blob/master/msiExecCmd_bin/univMSSInterface.sh


export ST_AUTH=https://<server>/auth/v1.0
export ST_USER=<user>
export ST_KEY=<key>

syncToArch () {
	# <your command or script to copy from cache to MSS> ${1:?} ${2:?} 
	# e.g: /usr/local/bin/rfcp ${1:?} rfioServerFoo:${2:?}

	echo "input: ${1} ${2}"

        CONTAINER=$(echo "${2}" | cut -d "/" -f1)
        IRODSCACHE=$(echo "${1}" | cut -d "/" -f2)
	IRODSPATH=${1#/${IRODSCACHE:?}/}
	echo "CONTAINER ${CONTAINER}"
        echo "IRODSCACHE ${IRODSCACHE}"
	echo "IRODSPATH ${IRODSPATH}"
        echo "UNIVMSS swift upload ${CONTAINER:?} ${1:?} --object-name ${IRODSPATH}"
	swift upload "${CONTAINER:?}" "${1:?}" --object-name "${IRODSPATH:?}" 2> /dev/null
	#output=$(swift upload "${CONTAINER}" "${1}")
	return
}

# function for staging a file ${1:?} from the MSS to file ${2:?} on disk
stageToCache () {
	# <your command to stage from MSS to cache> ${1:?} ${2:?}	
	# e.g: /usr/local/bin/rfcp rfioServerFoo:${1:?} ${2:?}

	#swift download exampleContainer var/lib/irods/iRODS/server/bin/cmd/tmp1.txt --output /var/lib/irods/here.txt
	
        CONTAINER=$(echo "${1:?}" | cut -d "/" -f1)
	OBJECT=${1#${CONTAINER:?}/}
        #echo ${CONTAINER}
        #echo ${1}
        echo "UNIVMSS swift download ${CONTAINER} ${OBJECT} --output ${2}"
        swift download "${CONTAINER}" "${OBJECT}" --output "${2}" 2> /dev/null
        return
}

# function to create a new directory ${1:?} in the MSS logical name space
mkdir () {
	# <your command to make a directory in the MSS> ${1:?}
	# e.g.: /usr/local/bin/rfmkdir -p rfioServerFoo:${1:?}
	#ssh remote-host 'mkdir -p foo/bar/qux'
	#echo "UNIVMSS ssh -i ${KEY} ${USER}@${ARCHIVEADDRESS} mkdir -p ${1:?}"
	#ssh -i ${KEY} ${USER}@${ARCHIVEADDRESS} "mkdir -p ${1:?}"
	return
}

# function to modify ACLs ${2:?} (octal) in the MSS logical name space for a given directory ${1:?} 
chmod () {
	# <your command to modify ACL> ${2:?} ${1:?}
	# e.g: /usr/local/bin/rfchmod ${2:?} rfioServerFoo:${1:?}
	############
	# LEAVING THE PARAMETERS "OUT OF ORDER" (${2:?} then ${1:?})
	#    because the driver provides them in this order
	# ${2:?} is mode
	# ${1:?} is directory
	############
        #op=`which chmod`
        #`$op ${2:?} ${1:?}`

	#echo "UNIVMSS ssh -i ${KEY} ${USER}@${ARCHIVEADDRESS} chmod ${2:?} ${1:?}"
	return
}

# function to remove a file ${1:?} from the MSS
rm () {
	# <your command to remove a file from the MSS> ${1:?}
	# e.g: /usr/local/bin/rfrm rfioServerFoo:${1:?}
    	#op=`which rm`
	#`$op ${1:?}`
        CONTAINER=$(echo "${1:?}" | cut -d "/" -f1)
        OBJECT=${1#${CONTAINER:?}/}
        #echo ${CONTAINER}
        #echo ${1}
        echo "UNIVMSS swift delete ${CONTAINER} ${OBJECT} "
        swift delete "${CONTAINER}" "${OBJECT}" 2> /dev/null
	return
}

# function to rename a file ${1:?} into ${2:?} in the MSS
mv () {
    	# <your command to rename a file in the MSS> ${1:?} ${2:?}
    	# e.g: /usr/local/bin/rfrename rfioServerFoo:${1:?} rfioServerFoo:${2:?}
    	#op=`which mv`
    	#`$op ${1:?} ${2:?}`
	#echo "UNIVMSS ssh -i ${KEY} ${USER}@${ARCHIVEADDRESS} mv ${1:?} ${2:?}"
	#ssh -i ${KEY} ${USER}@${ARCHIVEADDRESS} "mv ${1:?} ${2:?}"

	#mv 'iRODS-Vault/home/rods/hello' 'iRODS-Vault/trash/home/rods/hello'
        CONTAINER=$(echo "${1:?}" | cut -d "/" -f1)
        OBJECT=${1#${CONTAINER:?}/}
	NEWOBJ=${2#${CONTAINER:?}/}

	echo "CONTAINER $CONTAINER"
	echo "OBJECT $OBJECT"
	echo "NEWOBJ $NEWOBJ"
	echo "UNIVMSS swift copy ${CONTAINER} ${OBJECT} --destination /${CONTAINER}/${NEWOBJ}"
	swift copy ${CONTAINER} ${OBJECT} --destination /${CONTAINER}/${NEWOBJ} 2> /dev/null

	echo "UNIVMSS swift delete ${CONTAINER} ${OBJECT}"
	swift delete "${CONTAINER}" "${OBJECT}" 2> /dev/null

    	return
}

# function to do a stat on a file ${1:?} stored in the MSS
stat () {
        #op=`which stat`
	#output=`$op ${1:?}`
	# <your command to retrieve stats on the file> ${1:?}
	# e.g: output=`/usr/local/bin/rfstat rfioServerFoo:${1:?}`
	#error=$?
	#if [ $error != 0 ] # if file does not exist or information not available
	#then
	#	return $error
	#fi
	# parse the output.
	# Parameters to retrieve: device ID of device containing file("device"), 
	#                         file serial number ("inode"), ACL mode in octal ("mode"),
	#                         number of hard links to the file ("nlink"),
	#                         user id of file ("uid"), group id of file ("gid"),
	#                         device id ("devid"), file size ("size"), last access time ("atime"),
	#                         last modification time ("mtime"), last change time ("ctime"),
	#                         block size in bytes ("blksize"), number of blocks ("blkcnt")
	# e.g: device=`echo $output | awk '{print ${3:?}}'`	
	# Note 1: if some of these parameters are not relevant, set them to 0.
	# Note 2: the time should have this format: YYYY-MM-dd-hh.mm.ss with: 
	#                                           YYYY = 1900 to 2xxxx, MM = 1 to 12, dd = 1 to 31,
	#                                           hh = 0 to 24, mm = 0 to 59, ss = 0 to 59

       	# Get the stat info from the SWIFT server 
    	#output=`swift stat ${1:?} 2> /dev/null`

	CONTAINER=$(echo "${1}" | cut -d "/" -f1)
        OBJECT=${1#${CONTAINER}/}
	#echo ${CONTAINER}
	#echo ${OBJECT}
	output=$(swift stat "${CONTAINER}" "${OBJECT}" 2> /dev/null)
	#echo ${output}
	#error=$?

	if [ -z "$output" ]; # if file does not exist or information not available
        then
		#echo "Not a file"
                return "1"
        fi

	device="0"
	inode="0"
	mode="0600"
	nlink="0"
	#uid="999"
	uid=` echo $output | awk '{print $2}'` #swift user
	gid="999" #irods on irods server
	size=` echo $output | awk '{print $12}'`
	blksize="0"
	blkcnt="0"
    	devid="0"
	utime=` echo $output | awk '{print $31}'` 
    	tmp=` date -d @${utime} +%F-%T `
	atime=` echo "$tmp" | sed -r 's/:/./g' `
	mtime=` echo "$tmp" | sed -r 's/:/./g' `
    	ctime=` echo "$tmp" | sed -r 's/:/./g' `
	echo "$device:$inode:$mode:$nlink:$uid:$gid:$devid:$size:$blksize:$blkcnt:$atime:$mtime:$ctime"
	#echo "File exists"
	return
}

#############################################
# below this line, nothing should be changed.
#############################################

case "${1:?}" in
	syncToArch ) ${1:?} ${2:?} ${3:?} ;;
	stageToCache ) ${1:?} ${2:?} ${3:?} ;;
	mkdir ) ${1:?} ${2:?} ;;
	chmod ) ${1:?} ${2:?} ${3:?} ;;
	rm ) ${1:?} ${2:?} ;;
	mv ) ${1:?} ${2:?} ${3:?} ;;
	stat ) ${1:?} ${2:?} ;;
esac

exit $?
