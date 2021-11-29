#!/bin/bash

#Test the json file
#echo `jq '.[0].vmid' CloudInit_Options.json`
#echo `jq '.[1].vmid' CloudInit_Options.json`


command='jq length CloudInit_Options.json'
size=($($command))


# Each virtual machine will be created with the following two commands
#         $ qm clone <vmid> <vmid> --name <name>
#         $ qm set <vmid> [OPTIONS]
# in arr1[i] command 1 for the ith vm will be stored
# in arr2[i] command 2 for the ith vm will be stored

arr1=()
arr2=()
 
for (( i=0; i<$size; i++ ))
do
	echo "qm options for vm${i}:"
        echo

	command='jq -r '.[${i}].tmpid' CloudInit_Options.json'
	tmpid=($($command))
	echo "  tmpid:$tmpid"
        
	
	command='jq -r '.[${i}].vmid' CloudInit_Options.json'
        vmid=($($command))
        echo "  vmid:$vmid"

	command='jq -r '.[${i}].name' CloudInit_Options.json'
        name=($($command))
        echo "  name:$name"

	command='jq -r '.[${i}].ciuser' CloudInit_Options.json'
        ciuser=($($command))
        echo "  ciuser:$ciuser"

	command='jq -r '.[${i}].cipassword' CloudInit_Options.json'
        cipassword=($($command))
        echo "  cipassword:$cipassword"
  
	command='jq -r '.[${i}].nameserver' CloudInit_Options.json'
        nameserver=($($command))
        echo "  nameserver:$nameserver"

        command='jq -r '.[${i}].gw' CloudInit_Options.json'
        gw=($($command))
        echo "  gateway:$gw"

        command='jq -r '.[${i}].ip' CloudInit_Options.json'
        ip=($($command))
        echo "  ip:$ip"

        command='jq -r '.[${i}].sshkey' CloudInit_Options.json'
        sshkey=($($command))
        echo "  sshkey:$sshkey"

        command='jq -r '.[${i}].model' CloudInit_Options.json'
        model=($($command))
        echo "  model:$model"
	
        command='jq -r '.[${i}].bridge' CloudInit_Options.json'
        bridge=($($command))
        echo "  bridge:$bridge"

        command='jq -r '.[${i}].keyboard' CloudInit_Options.json'
        keybrLay=($($command))
        echo "  Keyboard Layout:$keybrLay"

        # in arr1[i] command 1 for the ith vm will be stored
        arr1+=("qm clone $tmpid $vmid --name $name") 
        # in arr2[i] command 2 for the ith vm will be stored       
        arr2+=("qm set $vmid --ciuser $ciuser --cipassword $cipassword --nameserver $nameserver --ipconfig0 gw=$gw,ip=$ip --sshkey $sshkey --net0 model=$model,bridge=$bridge --keyboard $keybrLay")

	echo "======="

done;

echo "Do you want to create ${size} VMs with the previous options? [Y-n]"
read response
#echo $response

if [[ $response = "Y" || $response = "y" || $response = "yes" || $response = "Yes" || $response = "YES" ]]
then
  
        echo "${size} VMs will be created"
        # echo ${arr1[*]}
        for (( i=0; i<$size; i++ ))
        do
                echo `${arr1[$i]}`
                echo
                echo `${arr2[$i]}`
                echo "========="
        done

else
  echo "Concel"
fi

#command=$(jq '.[1].vmid' CloudInit_Options.json)
#echo $command




