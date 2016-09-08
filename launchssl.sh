#!/bin/bash
MENU_HOME=/home/dme/netcap
PATH=$MENU_HOME/lin64bin:$MENU_HOME/bin:$PATH
MENU_SOURCE=$MENU_HOME/bin
NAMED_PIPE_PREFIX=$MENU_HOME/sessions/
export MENU_HOME PATH MENU_SOURCE NAMED_PIPE_PREFIX
cd $MENU_HOME
. $MENU_SOURCE/bin/fdbase.sh
rm -f $NAMED_PIPE_PREFIX/*
E2_SECURE_HOST="127.0.0.1 10.200.34.142 10.200.68.142"
export E2_SECURE_HOST
minitest 5000 >remsh.log 2>&1 &
E2_WEBSHELL_TEMPLATE="weblaunch.sh %s %d >sessions/%s.log 2>&1 &"
export E2_WEBSHELL_TEMPLATE
sslserv -p 443 -c 1:$MENU_SOURCE/server.pem:password > webpath.log 2>&1 &
