#! /bin/sh

# Set up input provider process
./input_provider &
inp_prov=$!

# Run ES
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib ./emulationstation

# Kill input provider on cleanup
kill $inp_prov