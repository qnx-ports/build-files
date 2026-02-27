#!/bin/sh

DIR="$(cd -P "$( dirname "$(readlink -f "$0")" )" && pwd )"
export LD_LIBRARY_PATH=${DIR}/lib:$LD_LIBRARY_PATH
export SDL_VIDEODRIVER=qnx

cd ${DIR}
./openttd "$@"
