#!/bin/sh

for i in $(seq 0 198); do
	case "$i" in
		55|56|57|65|67|68)
			{
				echo "Skippped Test ${i}" >> results.log
				continue
			}
			;;
	esac
	echo "Test ${i}" >> results.log
	echo ${i} | ./aws-crt-cpp-tests >> results.log 2>&1
done
