#! /bin/sh

# Set up input provider process
./hid_input_provider &
hid_inp_prov=$!
./usb_input_provider &
usb_inp_prov=$!

# Run ES
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib ./retroarch

# Kill input provider on cleanup
kill $hid_inp_prov
kill $usb_inp_prov