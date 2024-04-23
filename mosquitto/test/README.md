# Testing mosquitto on QNX

mosquitto normally wants to be tested on the same machine it was built on. This obviously doesn't work when cross-compiling for QNX. The gist is to build, then copy the whole mosquitto source tree on a target. This will include all the relevant files and directory structure which mosquitto expects when running its test suite.

# Running the Test Suite
Compile the mosquitto source for the desired architecture, e.g.

    OSLIST=nto CPULIST=x86_64 make -C qnx/build install

Once the target has booted run the tests

```bash
# Required for running tests
export SNAP_NAME=mosquitto

# Change directory to the test directory
cd mqtt_tests
TEST_PATH=${PWD}

# Generate ssl stuff
cd test/ssl
./gen.sh
cd $TEST_PATH

# Set permissions
chmod -R 777 $TEST_PATH/*

# Run broker test
cd test/broker
python3 ./test_qnx.py
cd $TEST_PATH

# Run client test
cd test/client
./test_qnx.sh
cd $TEST_PATH

# Run lib test
cd test/lib
python3 ./test_qnx.py
```

### Failed Test
#### QEMU: possibly due to VM internet config
- ./02-subpub-qos2-receive-maximum-1.py
- ./02-subpub-qos2-receive-maximum-2.py
- ./06-bridge-clean-session-csF-lcsF.py
- ./06-bridge-clean-session-csF-lcsN.py
- ./06-bridge-clean-session-csF-lcsT.py
- ./06-bridge-clean-session-csT-lcsF.py
- ./06-bridge-clean-session-csT-lcsN.py
- ./06-bridge-clean-session-csT-lcsT.py
- ./08-ssl-bridge.py

#### QEMU and RPI4: failed when run in batch but succeeded when run individually
- ./02-subscribe-qos1.py