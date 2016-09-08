# fdvars.sh - Global variables for PATH
# @(#) $Name$ $Id$
# Copyright (c) E2 Systems Limited 1993
#
ulimit -n 1024
MENU_SOURCE=$MENU_HOME/bin
export MENU_SOURCE
. $MENU_SOURCE/fdbase.sh
pid=$$
export MENU_SOURCE pid
#
# Things needed to support Web Access
#
if [ "$MENU_WKB" = web ]
then
# ***************************************************************************
# Web Interface Support
# ***************************************************************************
E2_WEB_PID=${E2_WEB_PID:-$$}
export E2_WEB_PID
html_head="<HTML>
<LINK rel='stylesheet' type='text/css' href='bin/e2base.css'>
<HEAD>
<meta http-equiv='Pragma' content='no-cache' />
<TITLE>Web Interface</TITLE>
<script language='Javascript' src='bin/e2base.js'></script>
</HEAD>
<BODY onLoad=\"if (typeof drawform != 'undefined') drawform()\">
<CENTER>
<TABLE WIDTH='98%' CELLSPACING=1 CELLPADDING=4 BORDER=1>
<TR><TD CLASS='BASE'>
<TABLE><TR><TD><A HREF='/'><img
src='data:image/gif;base64,R0lGODlhPABQAPQAAAZGBipqK0h4SF2eYFuwYXzShZC0kIzUjY3vlZf7pa/Sr6z7ssD6v8/6y+H2
1Pr++qusrQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEA
ABAAIf4ZU3VibWl0dGVkIEJ5IERhdmlkIFJ1dHRlbgAsAAAAADwAUAAABf4gcohHOSJicRjGeiRI
spStiSwLwzjLzSTAIEooKiIKNZOKRCqpWDCgywTULRwNHCMnhMWAqPBxajsVTVQUrlnaORyMBrBh
/X1jw2gJtWKG938mBjIyeE07CwkNWVw3PV+EhjEqaGYFIixsNAc9PZUIDVhxdIlqj5BgR2KqJ4CV
r2EMCAqyCj4Pb1iGRDFbQgWXf0yWLK81CVikpW+hyXQJOoVDibx7wWEA2drb3N3cB26kDopABQEB
2wIEKJQjZiYP8fLz9PX0i2+yMgsE5wMK8xwYGLAOhpkElRQoZGFAAAADuErAwKeg4ACIWngMESDg
gIIGD37AwPKgAQGEZv7OrBgIZ8XDeClzJONEYEBJRmE4Nhj4gJqMAXIcPLCVstVKASUPAIgnJ0YP
ZDcd2EK6KEwCcw0UBMCFB8cAHgWEKogi5pKLpS7jOdWBYkczqVvfFFkQ4ICDABDtBBkox6YDNUbQ
IECrFOaaRznw9fzacwgDAHQACJUGBulViAqMOnlRuMTSnmvA5MBxpQdINTCWJvhcmuxSFHFjABIh
hTBrIFoSPUNGhwHoR6+3PiD0qIDteGBS1n7gOR4XZMwUANjCDIsWGFsREAD4iJC5B8A+8znhpXnz
B46u4HIwYCs+Kzi8FFCAA2IDx/xsImgP00jyEccxtwAjoUgH0TgDkv5GTQyYKfKAAQEEIYABcnAU
kQ2o9RCgKQM2EABSJcGwBQ5ZeDFLAxxtF9FgVb0kSxk3aPTaav2B8wZeb4QkEh4ltkVdjiL1M5xD
MAmiYEjGMTdYf6BAGBZjpJ3Qmgzj+JLDEAAc8AABAAC0EwkGvIGDKK8V9gA3XgYg1B1FpBJHfDE0
JcBWCwCAFA/usLAFag28tqQ9LEg2HB4mirhIfFVc1eVdwuGBximOLIXDZ/sM+IYCAqwpJRjQbCGS
FzgEYFN7k2nmDpt+franD3GqFUQWvfzwXBh0bQWhUDO8oMkIniwpgnhXIFPcaSMu0mkVsBo0wHQO
ZPrXCD984s5Z6P79CQ6JcCKFwA7rhRLEaHhwCdGBexBSSRA0GKAajejJWmmd6F2BhQwCfEvNDHbi
EiJCqO2xxxokSPondLjh9pqCdAH1rQwHnCPPfQxDqwmJfPj6pwIaRQEErnHStZQcuP2AjlAlefII
rEgUswisKASYzykwTOkxQIQQ4hBAv4nQHQICXFTMDXLEh1af8fgWh2g9WKFVADivxc9LPZlb8QHG
fVSDU6UsOeBnoSSCwwsI5bB0LhDjYJxNjUlh1LJb2WIVEUvx8Jl1bDol7lA2lRKqcA55k42oRdpQ
c5KJzP2UrHyc45t0k8nAgEMk22OPAyudWkrP1Qrn7RsGzRlWT/4fOhcKlzhLbk9mV4+AkKhYgA2Q
Qlcc0N4/Qo1TNS6l5NsYzGDjwKVQLVzdMgB4qbsN8OjYaYACEHLDFApEPtC339rcyZABTSBg+vaS
e60e9/Wgjr0fbRIRX2idnO84omLMVsC9OSBSAxReSDPEKjrrIMsNvYCsuhgmEsMj/oUnJ7SAVt3J
WvvcsCDSlAcVQdjHCwCmOi7kQDD3g4QwaAOaSpXIRIiK4D6+UApQ8atyhCoh/sJAC1CIBFypiAIw
BOgfJhhkBEnoik8cpTo4FCJYVuBFBmmFEquUT3WCCdtTANMmOPhwH3IZIlnCUIAb3i+A4zEC0NiU
igzJohMgw/4fnIxolQUJYQRLuN8OHDGN9rXlMEsMoP2cEsMbiHAV5XJQgdARgALUJBsAEsACzEE8
PxpnG8vaRgDqRDwxZOMGDSskAS4hGpB4iABCQdECIIIev/QxHs3iyTwGFBAE1A4FXEJOXZgyADvQ
Zg1LyYxHtgSWAshBMiLB2A62ogiiDUAGWaDUfmwiA1wmAiDXyMIIMNmek/zlK1UEAgEeMAB1bEsW
r7HlUiAThFgyYJLE/CY1BVDFBpiBAa0AiFQIkC5YJcI3QzmJhoZTTHlgg5pbYgAvswBPKFTsDwNo
Qyabo4aTgCKTMfDTkuySAAEsCSkUeo1JgHnKMgBIlgPQT/5hYtYlEdRESQpVTcMEuZTtwEGiXUrE
R1NwBu2wx04Yi+SgEEJNO10BAejI3FL4KBCkbPIBOYWGlpYlyGq5ogQLwNlfUECy9OCsKXbhivbo
sQB5KGKqPckFKCE1ntmkhIjkI+M0PjjGMh5qh0NkQhoPIrV3UDIPXRgH/oD5KSEOsCgYdFT7yANX
Q0SDUHGCA9bQqjYMfc1fWezqXOUIsggCTR8hPKFiKxhABfLhGgCEVBemkUnS+KKNsCGe6rDzyME0
8hKHPELyjsCNdSTvb2p4bV1GBI0B7e+UqQAJD6q6omWpBRTxyCg9fhC5FZnyYbTwHssUek9QwKta
wv2Cav4EsMuhLOIx1EyMiCSVAIz5BBr37KLW0BlLk3zUC9k052sIsIhtrmxE6+JZ1CThqwOso2W4
uM9SRkWXai0pZhbDpjy8h12vCUxXAUPPAeqFXzsuBSkEwG5zT6Ca3IHnPvWqZzl4CUCqLcUcArjP
fxOQStpJhzke9q/W0KvgD4Esm580yBlyeo6q5LRwPoVITkPr36DymI/GonEfecApNAz3BlblLXrM
ac8EDBga9rxEPURCVWGcKnt2fGzM4GSQQhAiDrjT2GLrl4oZcsIWKCFPCMs4yFd+cA5vJvPbAHgH
HMrrPmqWBFtf+QVegWvOMazj1Pi3LTGpQSPC6AJuimdjlaaQEIuOrTOtmJoPEelFxgXzWipCA42r
2JGrIkyUuTgRIzg8pRB0IF80KjWHBELiOQtzLDV84ZtFE8cLgtXiCDutQae8rQu+qJkbtyDiKxEn
BnL1D3gjgZo5HyHUPgnNEN7ntRAAADs='
 alt='E2 Systems'></A>
</TD><TD>
<h3>Welcome to the $MENU_LOCATION Network!</h3>
<p>Choose an action or press the adjacent button</p>
</TD>
</TR>
</TABLE>
<HR/>"
# Needed when using minitest rather than sslserv as the Web Server
export html_head
#
# Footer
#
html_tail='</TD></TR></TABLE></CENTER></BODY>
</HTML>'
export html_tail
# ************************************************************************
# Form Definition Function that replaces natmenu
#
# This generates three types of input form, corresponding to the three
# types of form natmenu handles:
# - A straightforward menu
# - Picking off a list
# - An input form
#
# Input parameters:
# 1 - The sub_menu variable, which selects the appropriate branch in
#     the main case statement when the data comes back
# 2 ... Any other context information needed to be able to continue the
#     processing after the next user submission
#
render_form() {
    set +x
    echo "$html_head"
    if [ -n "$message_text" ]
    then
        echo "<p style=\"color:red; background-color:white;\"><b>$message_text</b></p>"
        echo "<hr/>"
    fi
$MENU_AWK 'BEGIN {FS="="
    ln = 1
    form_seq = 1
    print "<script>function drawform() { render_json('\''( ['\'' +"
}
/^HEAD=/ {
split($2, arr,":")
if (form_seq > 1)
print "'\''" "," "'\'' +"
print "'\''" "{ name : \"" arr[1] ":\", HEAD : \"" $2 "\"" "'\'' +"
next
}
/^PARENT=/ {
split($2, arr,":")
print "'\''" ", PARENT : \"" arr[1] ":\"" "'\'' +"
next
}
/^(PROMPT|COMMAND)=/ {
print "'\''" ", " $1 " : \"" $2 "\"" "'\'' +"
next
}
/SEL_NO/ { print "'\'',SEL : \"NO\"'\'' +" }
/SEL_YES/ { print "'\'',SEL : \"YES\"'\'' +" }
/COMM_YES/ { print "'\'',COMM : \"YES\"'\'' +" }
/COMM_NO/ { print "'\'',COMM : \"NO\"'\'' +" }
/SYSTEM/ { print "'\'',SYSTEM_OR_MENU : \"SYSTEM\"'\'' +" }
/MENU/ { print "'\'',SYSTEM_OR_MENU : \"MENU\"'\'' +" }
/^SCROLL/ { FS = "/"
print "'\''" ", SCROLL : [" "'\'' +"
next
}
FS == "/" {
    if (NF == 0)
    {
        FS= "="
        print "'\''" "] }" "'\'' +"
        ln = 1
        form_seq++
        next
    }
    else
    {
        if (ln > 1)
            comma=","
        else
            comma=""
        ln++;
        print "'\''" comma "{ LABEL : \"" $1 "\" , VALUE : \"" $2 "\" }"   "'\'' +"
    }
}
END {
if ( FS == "/")
    print "'\''" "] }" "'\'' +"
print "'\''])'\'');"
print "}"
print "</script>"
print "<DIV name=\"loadmarker\" id=\"loadmarker\">"
print "</DIV>"
}'
echo $html_tail
return
}
MENU_EDITOR=fdvi
export MENU_EDITOR
#
# The actual natmenu replacement
#
natmenu() {
# This should get displayed
render_form 0<&3 | e2fifout ${NAMED_PIPE_PREFIX}script_out_fifo.$E2_WEB_PID
e2fifin 1>&4 ${NAMED_PIPE_PREFIX}script_in_fifo.$E2_WEB_PID
return
}
# ****************************************************************************
# An example function
# ****************************************************************************
# Function to handle output in a standard manner
output_dispose() {
{
echo "$html_head"
if [ ! -z "$1" ]
then
    echo "<h1>"
    echo $1
    echo "</h1>"
fi
sed '1 s=.*=<h3>&</h3>=
2,$ s=.*=<p>&</p>='
echo $html_tail
}  | e2fifout ${NAMED_PIPE_PREFIX}script_out_fifo.$E2_WEB_PID
e2fifin 1>&2 ${NAMED_PIPE_PREFIX}script_in_fifo.$E2_WEB_PID
echo 1>&2 "output_dispose() discarding ..."
return
}
fi
