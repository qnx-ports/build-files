#! /bin/sh

# Set up input provider process
./input_provider &
inp_prov=$!

# Run Retroarch
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib ./retroarch

# Kill input provider on cleanup
kill $inp_prov