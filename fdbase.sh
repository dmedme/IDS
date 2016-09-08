# fdbase.sh - Global variables for Network Monitor
# @(#) $Name$ $Id$
# Copyright (c) E2 Systems Limited 1993
#
ulimit -n 4096
# Establish directory where PATH is run
MENU_LOCATION=Wherever
MENU_LOC=whe
MENU_VLAN=34
MENU_HOST=netperf
MENU_IF=eth0
export MENU_LOCATION MENU_LOC MENU_HOST MENU_IF MENU_VLAN
MENU_HOME=${MENU_HOME:-/home/dme/netcap}
# O/S type for establishing executables directory (MENU_SOURCE) and text editor
# (MENU_EDITOR)
MENU_OS=${MENU_OS:-LINUX}
MENU_SOURCE=${MENU_SOURCE:-/home/dme/netcap/bin}
MENU_EDITOR=${MENU_EDITOR:-vi}
pid=$$
export MENU_OS TERM MENU_HOME MENU_EDITOR MENU_SOURCE pid
# path and name of directory for saved scripts
#
# The file extension of the script files
#
if [ $MENU_OS = NT4 -o $MENU_OS = LINUX ]
then
MENU_AWK=${MENU_AWK:-gawk}
else
MENU_AWK=${MENU_AWK:-nawk}
fi
# Application Redraw String
export MENU_THINK MENU_OS MENU_DRIVER MENU_AWK MENU_STAGGER E2_SCENE_LEN E2_TEST_ID E2_TEST_LEN MENU_EXT E2_WEB_PORTS E2_ORA_WEB_PORTS
if [ ! "$MENU_OS" = NT4 ]
then
case $PATH in
*$MENU_SOURCE*)
     ;;
*)
    if uname -a | grep x86_64
    then
        arch=64
    else
        arch=32
    fi

    PATH=$MENU_HOME/lin${arch}bin:$MENU_SOURCE:$PATH
    export PATH
    ;;
esac
fi
