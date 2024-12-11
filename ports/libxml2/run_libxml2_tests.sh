#! /bin/sh

## Status
echo "Running tests..."

## Run each unit test file
echo "Running testsuite"
./runsuite
echo "Running runtest"
./runtest

## Not Used.
#echo "Running runxmlconf"
#./runxmlconf

echo "Running testapi"
./testapi
echo "Running testchar"
./testchar
echo "Running testdict"
./testdict
echo "Running testlimits"
./testlimits
echo "Running testparser"
./testparser
echo "Running testrecurse"
./testrecurse

## Deprecated
#echo "Running testModule"
#./testModule
