#!/bin/bash
sqlite3 whois.db << EOF
delete from parties where hndle in (select b.hndle from parties b group by b.hndle having count(*) > 1) and length(name||address||email) !=
(select max(length(b.name||b.address||b.email)) from parties b where b.hndle = parties.hndle);
delete from parties where hndle in (select b.hndle from parties b group by b.hndle having count(*) > 1) and rowid != 
(select min(rowid) from parties b where b.hndle = parties.hndle);
EOF
