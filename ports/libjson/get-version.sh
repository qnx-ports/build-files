#! /bin/bash
echo "Finding Versions..."
MAJOR=$(grep "MAJOR = * " $QNX_PROJECT_ROOT/Makefile | sed 's/MAJOR = //g' | sed 's/ //g')
MINOR=$(grep "MINOR = * " $QNX_PROJECT_ROOT/Makefile | sed 's/MINOR = //g' | sed 's/ //g')
MICRO=$(grep "MICRO = * " $QNX_PROJECT_ROOT/Makefile | sed 's/MICRO = //g' | sed 's/ //g')

echo "Setting CMakeLists.txt..."
sed -i 's/%MAJOR%/'"${MAJOR}"'/g' $QNX_PROJECT_ROOT/CMakeLists.txt
sed -i 's/%MINOR%/'"${MINOR}"'/g' $QNX_PROJECT_ROOT/CMakeLists.txt
sed -i 's/%MICRO%/'"${MICRO}"'/g' $QNX_PROJECT_ROOT/CMakeLists.txt
