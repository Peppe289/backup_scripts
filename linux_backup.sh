#!/bin/bash

# platform tools from this repository
export PATH="$(pwd)/linux_tools/:$PATH"

# backup of this directory. root storage path: "/storage/emulated/0"
ROOT_PATH="/storage/emulated/0"
DIR_BACKUP="DCIM Download Documents Pictures WhatsApp Movies Migrate"

ADB_DEVICES=$(adb devices)
echo "$ADB_DEVICES"

# check if this devices is connected
read -p "Write serial number: " device
ADB_DEVICES=($(adb devices | awk '!/devices/' | grep 'device' | grep $device | tr ' ' '\n'))
if [[ "$ADB_DEVICES" =~ .*"$device"*. ]]; then
    echo "Connect as ${ADB_DEVICES[1]}."
else
    echo "Not found"
    exit 1
fi

# make this as array
DIR_BACKUP=($( echo "$DIR_BACKUP" | tr ' ' '\n' ))
echo "This script will backup:"
counter=0
for i in "${DIR_BACKUP[@]}"
do
    counter=($(expr $counter + 1))
    echo "$counter) $ROOT_PATH/$i"
done

read -p "You want start? [y/N]: " ready
if [ "$ready" != "y" ] && [ "$ready" != "Y" ]; then
    echo "Abort!"
    exit 1
fi

# create directory for backup
mkdir "$(pwd)/$device/"

for i in "${DIR_BACKUP[@]}"
do
    echo " "
    echo "Backup : $i"
    adb -s $device pull "$ROOT_PATH/$i" "$(pwd)/$device/"
    if [[ $? -eq 1 ]]; then
        echo "$i not found. Skip..."
    fi
done

if [[ $? -ne 0 ]]; then
    echo "Some error here!"
    echo "Abort"
    exit 1
fi

echo "Done. Your backup in : $(pwd)/$device"