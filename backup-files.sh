#!/bin/bash
function selectFolders() {

    declare folders

    read -p "What folders would you like to backup? 
    
Use comas to seperate each folder path: " folders

    echo $folders

}

function backupChoice() {

    declare -i choice=0

    read -p "What type of backup are you choosing to do?
    1) Total
    2) Incremental
    3) Differential
Select your choice: " \
    choice

    echo $choice
     
}

function lastBackupDate() {

    declare filePath=$(find /backup -type f -name $(ls -1 /backup -tr | tail -1))
    
    echo $filePath

}

function lastTotalBackupDate() {

    declare filePath=$(ls -1 /backup/total* -tr | tail -1)
    
    echo $filePath

}

function preformBackup() {

    declare -i backup_choice=$1

    declare folders=$(echo $2 | tr "," " ")

    declare date=$(date +%Y-%m-%d)

    case $backup_choice in
        1)
            echo "-> Preforming total backup. This may take a while."
            sudo tar -cf /backup/total_$date.tar $folders 2> /dev/null
            echo ""

            echo "-> Compresing total backup. This may take a while"
            sudo gzip -9 /backup/total_$date.tar
            echo ""

            sudo chown $(id -un):$(id -gn) /backup/total_$date.tar.gz

            echo "-> Your backup is saved in /backup/total_$date.tar.gz"
            echo ""
            ;;
        2)

            declare lastBackupDate=$(lastBackupDate)

            echo "-> Preforming incremental backup. This may take a while."
            sudo tar -cf /backup/incremental_$date.tar -N $lastBackupDate $folders 2> /dev/null
            echo ""

            echo "-> Compressing incremental backup. This may take a while."
            sudo gzip -9 /backup/incremental_$date.tar
            echo ""

            sudo chown $(id -un):$(id -gn) /backup/incremental_$date.tar.gz

            echo "-> Your backup is saved in /backup/incremental_$date.tar.gz"
            echo ""
            ;;
        3)
            declare lastBackupDate=$(lastTotalBackupDate)

            echo "-> Preforming differential backup. This may take a while."
            sudo tar -cf /backup/differential_$date.tar -N $lastBackupDate $folders 2> /dev/null
            echo ""

            echo "-> Compressing incremental backup. This may take a while."
            sudo gzip -9 /backup/differential_$date.tar
            echo ""

            sudo chown $(id -un):$(id -gn) /backup/differential_$date.tar.gz

            echo "-> Your backup is saved in /backup/differential_$date.tar.gz"
            echo ""
            ;;
        *)
            echo "Invalid choice"
    esac
}

echo "######################################"
echo "# This script will backup your files #"
echo "######################################"
echo ""
folders=$(selectFolders)
echo ""

backupOption=$(backupChoice)
echo ""

preformBackup $backupOption $folders
