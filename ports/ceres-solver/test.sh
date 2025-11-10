#!/bin/sh

cd ~/bin

for file in *; do
  if [ -x "$file" ]; then
    echo "Running $file"
    echo "Running $file" >> ../test.log 2>&1
    "./$file" >> ../test.log 2>&1
  fi
done

cd -
