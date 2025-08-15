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
echo "QNX Environment variables are set to:"
source /usr/local/qnx/env/bin/activate
source $QNX_SDP/qnxsdp-env.sh
export PATH=/usr/local/qnx/depot_tools:$PATH
cd $HOME/qnx_workspace
echo ""
