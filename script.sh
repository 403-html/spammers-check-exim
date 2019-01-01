#!/bin/bash
#
# version 1.0.0
#

# Variables
HOSTNAME=$(hostname)
MAIL_LOG="/var/log/exim_mainlog"
SUBJECT="Spam check on $HOSTNAME"
MAIL_DESTINATION="example@example.com"
BODY_FILE="msg-body.txt"

# Main Script

if [ -f "$BODY_FILE" ]
#if body file exist - clear it
then
    echo "$HOSTNAME" > $BODY_FILE
#if body file don't exist - make it
else
    touch $BODY_FILE
    echo "$HOSTNAME" > $BODY_FILE
fi

# Prepare body - senders
echo "Najwieksza wysyłka pochodzi od:" >> $BODY_FILE

# List last 10 most valuable senders from server
cat $MAIL_LOG | awk '{print $3}' | uniq -c | awk '{arr[$2]+=$1} END {for (i in arr) {print arr[i],i}}' | sort -n | tail | while read -r line
do
    if [[ $line =~ .*(cwd=.*) ]]
    then
    echo "$line" >> $BODY_FILE
    fi
done

####### SEND #######
mail -s "$SUBJECT" $MAIL_DESTINATION < $BODY_FILE

##### CLEAR BODY #####
rm -rf $BODY_FILE
