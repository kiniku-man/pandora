#!/bin/bash
##########################################################
# PandoraFMS ENTERPRISE  online installation entrypoint
##########################################################

# define variables
S_VERSION='2024062501'
LOGFILE="/tmp/pandora-deploy-$(date +%F).log"

# Ansi color code variables
red="\e[0;91m"
green="\e[0;92m"
cyan="\e[0;36m"
yellow="\e[33m"
reset="\e[0m"

#Check if possible to get os version
if [ ! -e /etc/os-release ]; then
    echo -e "${red}Imposible to determinate the OS version for this machine, please make sure you are intalling in a compatible OS${reset}"
    echo -e "${red}> More info: https://pandorafms.com/manual/en/documentation/02_installation/01_installing#minimum_software_requirements${reset}"
    exit -1
fi

install_script=""
#Detect OS
os_name=$(grep ^PRETTY_NAME= /etc/os-release | cut -d '=' -f2 | tr -d '"')

if grep -q rhel /etc/os-release ; then
    if [[ $(sed -nr 's/VERSION_ID+=\s*"([0-9]).*"$/\1/p' /etc/os-release) -eq '7' ]] ; then #el 7
        echo -e "${yellow} OS detected: ${os_name}. PandoraFMS installation tool has detected a non-supported OS${reset}"
        echo -e "${yellow} Unfortunately CentOS 7 (EL7) is out of support for installation tool, please run the installation on a EL9 or EL8 environment${reset}"
        exit 1
    elif [[ $(sed -nr 's/VERSION_ID+=\s*"([0-9]).*"$/\1/p' /etc/os-release) -eq '8' ]] ; then #el8
        install_script='https://packages.pandorafms.com/projects/deploy/enterprise/ndzcb6JI3MWu8e6HfyLc/pandora_deploy_enterprise_el8.sh'
    elif [[ $(sed -nr 's/VERSION_ID+=\s*"([0-9]).*"$/\1/p' /etc/os-release) -eq '9' ]] ; then #el9
        install_script='https://packages.pandorafms.com/projects/deploy/enterprise/ndzcb6JI3MWu8e6HfyLc/pandora_deploy_enterprise_el9.sh'
    else
        echo -e "${red}Error OS version: $os_name detected, RHEL/Almalinux/Centos/Rockylinux 8.x or 9.x is expected${reset}"
        exit 1
    fi
elif grep -q ubuntu /etc/os-release ; then
    if [[ $(sed -nr 's/VERSION_ID+=\s*"([0-9][0-9].[0-9][0-9])"$/\1/p' /etc/os-release) == "22.04" ]]; then  # ubuntu 22.04
        install_script='https://packages.pandorafms.com/projects/deploy/enterprise/ndzcb6JI3MWu8e6HfyLc/pandora_deploy_enterprise_ubuntu_2204.sh'
    else 
        echo "${red} Error OS version: $os_name, Ubuntu 22.04 is expected. ${reset}"  
        exit 1
    fi

else
    echo "OS version: $os_name" &>> $LOGFILE
    echo -e "${red}Error OS version: $os_name detected, not supported version${reset}"
    exit 1
fi

## Main
curl -LSs "$install_script" | bash
