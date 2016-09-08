#!/bin/bash
# weblaunch.sh - Spawn the PATH Web interface from the multi-threaded
# sslserv
# **************************************************************************
# Clear down the environment in case fdvars.sh has already been dotted
# **************************************************************************
if [ $# -ne 2 ]
then
    echo "weblaunch.sh - Spawn the IDS Web GUI from multi-threaded sslserv.
You must provide the session cookie and a sequence number (used for allocating
single step and proxy threads."
    exit 1
fi 
unset LD_LIBRARY_PATH
unset MENU_AWK MENU_HOME MENU_SOURCE MENU_OS MENU_EDITOR
# *************************************************************************
# Decide whether we are Windows or some flavour of UNIX
uname_out=`uname`
case "$uname_out" in
*NT*)
export PATH=/c/e2/bin:/c/e2/winbin:/c/e2/bin:/c/e2/winbin:/c/e2/gnuplot/binary:/c/windows/system32:/c/windows:
    export MENU_HOME=c:/e2
    export MENU_OS=NT4
    export MENU_AWK=gawk
    export NAMED_PIPE_PREFIX='\\.\pipe\'
    ;;
Linux)
    export MENU_OS=LINUX
    export MENU_AWK=gawk
    export MENU_HOME=${MENU_HOME:-`pwd`}
    export NAMED_PIPE_PREFIX=$MENU_HOME/sessions/
    ;;
AIX)
    export MENU_OS=AIX
    export MENU_AWK=awk
    export MENU_HOME=${MENU_HOME:-`pwd`}
    export NAMED_PIPE_PREFIX=$MENU_HOME/sessions/
    ;;
SunOS)
    export MENU_OS=SOLAR
    export MENU_AWK=nawk
    export MENU_HOME=${MENU_HOME:-`pwd`}
    export NAMED_PIPE_PREFIX=$MENU_HOME/sessions/
    ;;
*)
    export MENU_OS=UNIX
    export MENU_AWK=awk
    export MENU_HOME=${MENU_HOME:-`pwd`}
    export NAMED_PIPE_PREFIX=$MENU_HOME/sessions/
    ;;
esac
# Set up the environment
# Need to find an fdvars.sh to bootstrap the system. Initially even to browse
# configuration variables we need something sane.
if [ -f $MENU_HOME/bin/fdvars.sh ]
then
    . $MENU_HOME/bin/fdvars.sh
else
    echo MENU_HOME="'$MENU_HOME'" does not have relevant software present
    exit 1
fi
#
# These are needed so that multiple users can share the same directory tree.
# Each user may need their own ports for dependent services.
#
E2_WEB_PID=$1
export E2_WEB_PID
OVERRIDE_E2SINGLE_PORT=`expr $E2SINGLE_PORT + $2`
OVERRIDE_E2_PROXY_PORT=`expr $E2_PROXY_PORT + $2`
export OVERRIDE_E2SINGLE_PORT OVERRIDE_E2_PROXY_PORT
#
# Linux (32 and 64) and Windows (32 bit only for now) have their own
# directories for the binary programs, since in most environments we may well
# make use of machines running all three.
#
# If we were ever to find ourselves with something else again in the future, we
# would put the binary executables in a bin sub-directory as a one-off.
#
if [ "$MENU_OS" = LINUX ]
then
    if uname -m | grep 64
    then
        export PATH=$MENU_HOME/lin64bin:$PATH
    else
        export PATH=$MENU_HOME/lin32bin:$PATH
    fi
else
case $PATH in
*$MENU_HOME/bin*)
    ;;
*)
    export PATH=$MENU_HOME/bin:$PATH
    ;;
esac
fi
# Now run webmenu.sh
# *****************************************************************
# There are two cases.
# 1. On UNIX flavours we must use ptydrive. This ensures that /dev/tty stays
#    legal for the scripts. ptydrive has been doctored to:
#    - Stop it exiting on EOF
#    - Stop it timing out due to inactivity
#    These features now require -DAGGRESIVE_EXIT to be enabled. 
# 2. We are on Windows. /dev/tty doesn't really mean anything.
#
export MENU_WKB=web
if [ $MENU_OS = NT4 ]
then
    exec webmenu.sh </dev/null
else
    exec ptydrive -d -x webmenu.sh /dev/null 1 1 1 </dev/null
fi
