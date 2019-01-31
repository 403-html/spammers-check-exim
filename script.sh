#!/bin/bash
#
# version 1.0.3
# pre 1.1

# Variables
HOSTNAME=$(hostname)
MAIL_LOG="/var/log/exim_mainlog"
SUBJECT="Spam check on $HOSTNAME"
MAIL_DESTINATION="example@example.com"
BODY_FILE="msg-body.txt"
NUMBER_OF_PEOPLE=5

# Script

# Prepare environment
PREPARE_ENV () {
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
}

# Write line to file
WRITE_TO_FILE () {
    line=$1
    echo "$line" >> $BODY_FILE
}

# Check the last 5 people sending the most messages. 
CHECK_WHO () {
    COMMAND=`cat $MAIL_LOG | awk '{print $3}' | uniq -c | awk '{arr[$2]+=$1} END {for (i in arr) {print arr[i],i}}' | sort -n | tail -$NUMBER_OF_PEOPLE`
    echo "$COMMAND" | while read -r line
    do
        # Check if it's path to user
        if [[ $line =~ .*(cwd=.*) ]]
        then
            WRITE_TO_FILE "$line"
        fi
    done
}

CHECK_FROM_WHERE () {
    user=$1
    today_date=`cat $MAIL_LOG | awk '{}'`
    # Check if it's cron-job
    COMMAND=`cat $MAIL_LOG | grep $user | `
}

SEND_MAIL () {
    ####### SEND #######
    mail -s "$SUBJECT" $MAIL_DESTINATION < $BODY_FILE

    ##### CLEAR BODY #####
    rm -rf $BODY_FILE
}

RUN () {
    PREPARE_ENV
    CHECK_WHO
    SEND_MAIL
}

RUN
