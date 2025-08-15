#!/bin/sh
DIR="$(cd -P "$( dirname "$(readlink -f "$0")" )" && pwd )"
LD_LIBRARY_PATH=${DIR}/lib:$LD_LIBRARY_PATH:${DIR}/../lib ${DIR}/openttd -D