# Automation For ProxMox VMs
A simple bash script that automates the creation of virtual machines from a ready cloud-init-template using $qm command and a json file.


# Deploy Proxmox virtual machines using Cloud-init, bash scripting and JSON.

## Table of Contents

1.  Task description
2.  Deploy the template by cloning it from a ready cloud-init template
3.  set the configuration with the `qm set <vmid> [OPTIONS]` command
4.  Automate the task with Bash and JSON
    **i.** Fetch the JSON values with the `$ vq` command
    **ii**. The Bash script that automates the task

* * *

## Task description

With Proxmox its pretty easy to create a Virtual Machine either with GUI or from the terminal with command line. But with a large number of VMs the process becomes frustrating and especially time consuming.
We can automate this task with a simple bash script, that automatically creates any number of VMs from a ready cloud-init image and a JSON file that contains the parametres of each VM.

* * *

## Deploy the template by cloning it from a ready cloud-init template

Deploying a template (Creating a VM from a template) on Proxmox server can be done in two ways:

- **From Gui:**
    ![](https://e.top4top.io/p_2166gltnp1.png)
    
- **With command line we can create a VM with the following command** :
    `qm clone <tmpid> <vmid> --name <string>`
    
    - tmpid: The template's ID
    - vmid: The new VM's ID

* * *

## Set the configuration with the `qm set <vmid> [OPTIONS]` command

After cloning the template into a new VM, we can customize its cloud-init parametres either by editing the cloud-init drive of with the following command:
`qm set <vmid> [OPTIONS]`

- vmid                : the VM's ID
- --ciuser            : user name
- --cipassword   : password
- --nameserver  : DNS server
- --ipconfig0      : network configuration
    - gw             : The gateways address(x.x.x.x)
    - ip               : The IP address(x.x.x.x/yy)
- --sshkey         : ssh public key
- --net0             : network hardware
- --keyboard     : keyboard layout

**Exemple**
`$ qm clone 8000 8008 --name ubuntuSaifTestVM`
The previous command creates a VM with the ID "8008" and the name "ubuntuSaifTestVM" from the template with the ID "8000".

`$ qm set 8008 --ciuser saif8008 --cipassword Saif8008ls --nameserver 8.8.8.8 --ipconfig0 gw=192.168.1.1,ip=192.168.1.8/24 --sshkey CloudInitSshPubKeys/vm8008_ssh.pub --net0 model=virtio,bridge=vmbr1 --keyboard fr`
Then set the cloud-init parametres to the created VM with the ID "8008"

* * *

## Automate the task with Bash and JSON
### Fetch the JSON values with the `$ vq` command
Lets assume that we have a JSON file with the following content where each object presents a VM, the bash script will use this file to automatically get the Cloud-init parametres and create VMs:
```
[{
     "tmpid":"8000",
     "vmid":"8008",
     "name":"ubuntuSaifTestVM",
     "ciuser":"saif8008",
     "cipassword":"ubuntupwd",
     "nameserver":"8.8.8.8",
     "gw":"192.168.1.1",
     "ip":"192.168.1.8/24",
     "sshkey":"CloudInitSshPubKeys/vm8008_ssh.pub",
     "model":"virtio",
     "bridge":"vmbr1", 
     "keyboard":"fr"
   },

   {
     "tmpid":"8000",
     "vmid":"8009",
     "name":"ubuntuSaifTestVM1",
     "ciuser":"saif8009",
     "cipassword":"ubuntupwd",
     "nameserver":"8.8.8.8",
     "gw":"192.168.1.1",
     "ip":"192.168.1.9/24",
     "sshkey":"CloudInitSshPubKeys/vm8008_ssh.pub",
     "model":"virtio",
     "bridge":"vmbr1", 
     "keyboard":"fr"
   }]
   
 ```
**Important**: Note that I have a folder named CloudInitSshPubKeys where i store all my ssh keys
* Get the size of the JSON file:
 `jq length VmsConfig.json`
 Output:
	>     2
* Get the first object from the JSON file:
 `jq -r '.[0]' VmsConfig.json`
 Output:
 
	>{
  "tmpid": "8000",
  "vmid": "8008",
  "name": "ubuntuSaifTestVM",
  "ciuser": "saif8008",
  "cipassword": "ubuntupwd",
  "nameserver": "8.8.8.8",
  "gw": "192.168.1.1",
  "ip": "192.168.1.8/24",
  "sshkey": "CloudInitSshPubKeys/vm8008_ssh.pub",
  "model": "virtio",
  "bridge": "vmbr1",
  "keyboard": "fr"
}
* Get a specific value from an object:
 `jq -r '.[0].tmpid' VmsConfig.json`
 Output:
	>     8000

Now we will combine these simple commands in a simple bash script
that iterates over the JSON array, get each value, construct the command `qm clone <tmpid> <vmid> --name <string>`
and store it in array arr1, then construct the command `qm set <vmid> [OPTIONS]`and store it in array arr2, then just iterate over both arrays and run each command in order to create every VM and set its cloud-init parametres.
- - --
### The code of the Bash script:

```
	#!/bin/bash

	#Test the json file
	#echo `jq '.[0].vmid' VmsConfig.json`
	#echo `jq '.[1].vmid' VmsConfig.json`


	command='jq length VmsConfig.json'
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

		command='jq -r '.[${i}].tmpid' VmsConfig.json'
		tmpid=($($command))
		echo "  tmpid:$tmpid"


		command='jq -r '.[${i}].vmid' VmsConfig.json'
			vmid=($($command))
			echo "  vmid:$vmid"

		command='jq -r '.[${i}].name' VmsConfig.json'
			name=($($command))
			echo "  name:$name"

		command='jq -r '.[${i}].ciuser' VmsConfig.json'
			ciuser=($($command))
			echo "  ciuser:$ciuser"

		command='jq -r '.[${i}].cipassword' VmsConfig.json'
			cipassword=($($command))
			echo "  cipassword:$cipassword"

		command='jq -r '.[${i}].nameserver' VmsConfig.json'
			nameserver=($($command))
			echo "  nameserver:$nameserver"

			command='jq -r '.[${i}].gw' VmsConfig.json'
			gw=($($command))
			echo "  gateway:$gw"

			command='jq -r '.[${i}].ip' VmsConfig.json'
			ip=($($command))
			echo "  ip:$ip"

			command='jq -r '.[${i}].sshkey' VmsConfig.json'
			sshkey=($($command))
			echo "  sshkey:$sshkey"

			command='jq -r '.[${i}].model' VmsConfig.json'
			model=($($command))
			echo "  model:$model"

			command='jq -r '.[${i}].bridge' VmsConfig.json'
			bridge=($($command))
			echo "  bridge:$bridge"

			command='jq -r '.[${i}].keyboard' VmsConfig.json'
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
					echo ${arr1[$i]}
					echo
					echo ${arr2[$i]}
					echo "========="
			done

	else
	  echo "Concel"
	fi

	#command=$(jq '.[1].vmid' VmsConfig.json)
	#echo $command

```
