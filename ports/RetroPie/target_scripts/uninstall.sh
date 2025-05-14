#! /bin/bash

# Move to parent folder & set some variables
target=$(dirname "$0")
echo Uninstalling at $target

# Use rarch_shared as a test
if [ ! -d "rarch-shared" ]; then
	echo "ERROR: Installation partially not installed or moved."
	exit 1
fi

# Remove local directories
rm -rf $target/data
rm -rf $target/emulationstation
rm -rf $target/lib
rm -rf $target/lua
rm -rf $target/rarch-shared
rm -rf $target/resources 
rm -rf $target/retroarch
rm -f  $target/start-ra.sh
rm -f  $target/startup.sh
rm -rf $target/tmp

# wipe .emulationstation
read -p "Clean ~/.emulationstation (configs) as well? [Y/n]" input

if [ $input != "Y" -a $input != "n" -a $input != "y" -a $input != "n" ]; then
	read -p "Invalid input. Try again [Y/n]" input
	if [ $input != "Y" -a $input != "n" -a $input != "y" -a $input != "n" ]; then
		echo "Invalid input, assuming [n]"
		input="n"
	fi
fi

if [ $input = "Y" -o $input = "y" ]; then
	echo Removing ~/.emulationstation ...
	rm -rf ~/.emulationstation
fi

# Remove retropie
rm -rf $target/../retropie