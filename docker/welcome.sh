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
source $HOME/qnx800/qnxsdp-env.sh
cd $HOME/qnx_workspace
echo ""
