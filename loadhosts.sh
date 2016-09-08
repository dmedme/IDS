#!/bin/bash
sqlite3 capsess.db << EOF
create table hosts (
ip varchar(16) not null,
name varchar(64) not null,
int_flag int64 not null,
sql_ok int64 not null);
EOF
gawk 'BEGIN {
# Load the database
print "begin transaction;"
print "delete from hosts;"
}
{
    print "insert into hosts ( ip, name, int_flag, sql_ok) values ("
    if (substr($1,1,3) == "10.")
        int_flag = 1
    else
        int_flag = 2
    printf "'\''%s'\'','\''%s'\'',%d, 0);\n", $1, $2, int_flag
}
END { print "commit;" }' allhosts.lis | sqlite3 capsess.db
