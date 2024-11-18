#!/bin/ksh

echo "" > full_result.txt
echo "" > result.txt

# For qnx700, use the following instead:
# for i in /system/libexec/installed-tests/glib/*
for i in /usr/libexec/installed-tests/glib/*
do
  if [ -x "$i" ] && ! [[ "$i" = *(\.so|\.py)$ ]] && ! [ -d "$i" ]; then
    echo "Running test $i..."
    if gtester "$i" >> full_result.txt; then
      echo "PASS: $i" >> result.txt
    else
      echo "FAIL: $i" >> result.txt
    fi
  fi
done
