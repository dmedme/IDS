#!/bin/bash
timeload="set terminal svg enhanced font "'"'"sans"'"'" fsize 10 size 1024,768
set output 'timeload.svg'
set ytics border out scale 1,0.5 nomirror norotate  offset character 0, 0, 0
set y2tics border out scale 1,0.5 nomirror norotate  offset character 0, 0, 0
set xtics border out nomirror rotate autofreq
set title "'"'"Load versus Response over Time"'"'" font 'sans,14'
set autoscale x
set autoscale y
set y2range [ 0 : 10 ]
set format y "'"'"%.16g"'"'"
set format y2 "'"'"%.16g"'"'"
set xdata time
set format x "'"'"%Y-%m-%d %H"'"'"
set timefmt "'"'"%Y-%m-%d %H"'"'"
set xlabel "'"'"Date Time"'"'" offset 1 font  'sans,12'
set ylabel "'"'"Requests in Hour"'"'" offset 2 font  'sans,12'
set y2label "'"'"Average Response/Seconds in Hour"'"'" offset 1 font  'sans,12'
plot '-' using 1:3 axes x1y1  title "'"'"Requests"'"'" with lines, "'"'"-"'"'" using 1:3 axes x1y2 title "'"'"Average Response/Seconds"'"'" with lines"
timetraffic="set terminal svg enhanced font "'"'"sans"'"'" fsize 10 size 1024,768
set output 'timetraffic.svg'
set ytics border out scale 1,0.5 nomirror norotate  offset character 0, 0, 0
set y2tics border out scale 1,0.5 nomirror norotate  offset character 0, 0, 0
set xtics border out nomirror rotate autofreq
set title "'"'"Traffic versus Response over Time"'"'" font 'sans,14'
set autoscale x
set autoscale y
#set autoscale y2
set y2range [ 0 : 10 ]
set format y "'"'"%.16g"'"'"
set format y2 "'"'"%.16g"'"'"
set xdata time
set format x "'"'"%Y-%m-%d %H"'"'"
set timefmt "'"'"%Y-%m-%d %H"'"'"
set xlabel "'"'"Date Time"'"'" offset 1 font  'sans,12'
set ylabel "'"'"Bytes in Hour"'"'" offset 2 font  'sans,12'
set y2label "'"'"Average Response/Seconds in Hour"'"'" offset 1 font  'sans,12'
plot '-' using 1:3 axes x1y1  title "'"'"Bytes"'"'" with lines, "'"'"-"'"'" using 1:3 axes x1y2 title "'"'"Average Response/Seconds"'"'" with lines"
timeusers="set terminal svg enhanced font "'"'"sans"'"'" fsize 10 size 1024,768
set output 'timeusers.svg'
set ytics border out scale 1,0.5 nomirror norotate  offset character 0, 0, 0
set y2tics border out scale 1,0.5 nomirror norotate  offset character 0, 0, 0
set xtics border out nomirror rotate autofreq
set title "'"'"Users versus Response over Time"'"'" font 'sans,14'
set autoscale x
set autoscale y
#set autoscale y2
set y2range [ 0 : 10 ]
set format y "'"'"%.16g"'"'"
set format y2 "'"'"%.16g"'"'"
set xdata time
set format x "'"'"%Y-%m-%d %H"'"'"
set timefmt "'"'"%Y-%m-%d %H"'"'"
set xlabel "'"'"Date Time"'"'" offset 1 font  'sans,12'
set ylabel "'"'"Users in Hour"'"'" offset 1 font  'sans,12'
set y2label "'"'"Average Response/Seconds in Hour"'"'" offset 1 font  'sans,12'
plot '-' using 1:3 axes x1y1  title "'"'"Users"'"'" with lines, "'"'"-"'"'" using 1:3 axes x1y2 title "'"'"Average Response/Seconds"'"'" with lines"
#DateTime|Count|Total Time|Average Time|Std Dev|Clients|Upload|Download
do_col() {
col=$1
gawk -F"|" 'BEGIN {getline}
{ print $1 " " $'$col'}
END { print "e"}' hourbyhour.txt
}
{
    echo "$timeload"
    do_col 2
    do_col 4
}|gnuplot
{
    echo "$timeusers"
    do_col 6
    do_col 4
}|gnuplot
{
    echo "$timetraffic"
    do_col 7+\$8
    do_col 4
}|gnuplot
exit
