#!/bin/bash
echo "
******************************************************************
*
*     Welcome to QNX development environment
*     -------------------------------------------------------
*
* Default password for user is \"password\".
*
******************************************************************
"

# Setup environment variables
source /usr/local/qnx/env/bin/activate
echo "QNX Environment variables are set to:"
source $QNX_SDP/qnxsdp-env.sh
export PATH=/usr/local/qnx/depot_tools:$PATH
if [ -d "$QNX_WORKSPACE" ]; then
    cd "$QNX_WORKSPACE"
fi
echo ""
