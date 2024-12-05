#!/bin/sh

if [ -z $QNX_PROJECT_ROOT ]; then
DIST_BASE="../../../libxml2"
else
DIST_BASE=$QNX_PROJECT_ROOT
fi
echo "hi"
echo $DIST_BASE

cd ${DIST_BASE} && ./autogen.sh &
pid=$!
wait $pid
echo "waited!"
echo $PWD