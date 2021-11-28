#!/bin/bash

#Test the json file
#echo `jq '.[0].vmid' jsonTestFile.json`
#echo `jq '.[1].vmid' jsonTestFile.json`


command='jq length jsonTestFile.json'
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
	      command='jq -r '.[${i}].tmpid' jsonTestFile.json'
	      tmpid=($($command))
	      echo "  tmpid:$tmpid"
        
	
        command='jq -r '.[${i}].vmid' jsonTestFile.json'
        vmid=($($command))
        echo "  vmid:$vmid"

        command='jq -r '.[${i}].name' jsonTestFile.json'
        name=($($command))
        echo "  name:$name"

      	command='jq -r '.[${i}].ciuser' jsonTestFile.json'
        ciuser=($($command))
        echo "  ciuser:$ciuser"

	      command='jq -r '.[${i}].cipassword' jsonTestFile.json'
        cipassword=($($command))
        echo "  cipassword:$cipassword"
  
	      command='jq -r '.[${i}].nameserver' jsonTestFile.json'
        nameserver=($($command))
        echo "  nameserver:$nameserver"

        command='jq -r '.[${i}].gw' jsonTestFile.json'
        gw=($($command))
        echo "  gateway:$gw"

        command='jq -r '.[${i}].ip' jsonTestFile.json'
        ip=($($command))
        echo "  ip:$ip"

        command='jq -r '.[${i}].sshkey' jsonTestFile.json'
        sshkey=($($command))
        echo "  sshkey:$sshkey"

        command='jq -r '.[${i}].model' jsonTestFile.json'
        model=($($command))
        echo "  model:$model"
	
        command='jq -r '.[${i}].bridge' jsonTestFile.json'
        bridge=($($command))
        echo "  bridge:$bridge"

        command='jq -r '.[${i}].keyboard' jsonTestFile.json'
        keybrLay=($($command))
        echo "  Keyboard Layout:$keybrLay"

        # in arr1[i] command 1 for the ith vm will be stored
        arr1+=("qm clone $tmpid $vmid --name $name") 
        # in arr2[i] command 2 for the ith vm will be stored       
        arr2+=("qm set $vmid --ciuser $ciuser --cipassword $cipassword --nameserver $nameserver --ipconfig0 gw=$gw,ip=$ip/24 --sshkey $sshkey --net0 model=$model,bridge=$bridge --keyboard $keybrLay")

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

#command=$(jq '.[1].vmid' jsonTestFile.json)
#echo $command




