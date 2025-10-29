#!/bin/sh

# This should be on the target in the /tests/unbound directory
# along with the various test binaries and the testdata directory.

# Do what the "make test" target does

./unittest
if [ $? -ne 0 ]
then
    echo failed
    exit 1
fi

./testbound -s
if [ $? -ne 0 ]
then
    echo failed
    exit 1
fi

for x in testdata/*.rpl
do
	printf "%s" "$x "
	if ./testbound -p $x >/dev/null 2>&1
	then
	    echo OK
	else
	    echo failed
	    ./testbound -p $x -o -vvvvv
	    printf "%s" "$x "
	    echo failed
	    exit 1
	fi
done
echo test OK
