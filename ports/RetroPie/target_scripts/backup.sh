#! /bin/sh

# Set up input provider process
./hid_input_provider &
hid_inp_prov=$!
./usb_input_provider &
usb_inp_prov=$!

START_SELECTION=""

#prompt user input
while [ "$START_SELECTION" != "Q" ]
do
	read -p "Menu not available - Please select an option for startup in Terminal. \n O - OpenTTD \n R - RetroArch \b Q - Quit" START_SELECTION

	case "$START_SELECTION" in 
		*"O"*)
			LD_LIBRARY_PATH=$PWD/OpenTTD/lib:$LD_LIBRARY_PATH:$PWD/lib ./openttd
		;;
		*"R"*)
			LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib ./retroarch
		;;
	esac

done



# Kill input provider on cleanup
kill $hid_inp_prov
kill $usb_inp_prov