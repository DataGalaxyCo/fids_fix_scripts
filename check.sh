#! /bin/bash

echo ""
echo "...:::FIDS SERVICE CHECKER:::..."
echo ""
echo " - System Services Status: "

function checkIt()
{
 ps auxw | grep $1 | grep -v grep > /dev/null

 if [ $? != 0 ]
 then
    echo "" ; echo $1" :It's Down!";
 else
    echo "" ; echo $1" :It's Up!";
 fi;
}

checkIt "mongod";
checkIt "nginx";
checkIt "redis";
checkIt "postgresql";

echo ""
echo "Done!"

# THIS CODE IS NOTE COMPLETE
