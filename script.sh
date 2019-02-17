#!/bin/bash
#
# version 1.0.8-dev
# pre 1.1

# Manual Variables
MAIL_DESTINATION="example@example.com"
PEOPLE_OUTPUT="15"
EXIM_PATH="/var/log/exim_mainlog"

# Automatic Variables
HOSTNAME=$(hostname)
SUBJECT="Spam check on $HOSTNAME"
MAILBODY="mailbody.txt"

# Prepare mail body file
PREPARE_ENV () {
    if [ -d "$MAILBODY" ]; then
        echo "Spam check on $HOSTNAME" > $MAILBODY
    else
        touch $MAILBODY && echo "SPAM check on $HOSTNAME" > $MAILBODY
    fi
}

CHECK_WHO () {
    SENDERS_LIST=$(cat $EXIM_PATH | grep home | grep cwd | awk '{print $3}' | uniq -c | awk '{arr[$2]+=$1} END {for (i in arr) {print arr[i],i}}' | sort -n | tail -n$PEOPLE_OUTPUT | awk '{print $2}')
    
    echo "$SENDERS_LIST" | while read -r SENDER
    do
        SENDER_NAME=$(echo $SENDER | awk 'BEGIN { FS = "/" } ; { print $3 }')

        FORM_CHECK=$(echo $SENDER | awk 'BEGIN { FS = "/" } ; { print $5 }')
        if [[ "$FORM_CHECK" ]]; then
            echo "Użytkownik \"$SENDER_NAME\" prowadzi wysyłkę z katalogu w $(echo $SENDER | awk 'BEGIN { FS = "/" } ; {out=""; for(i=4;i<=NF;i++){out=out"/"$i}; print out}')" >> $MAILBODY
            continue
        fi
        
        CRON_CHECK=$(cat $EXIM_PATH | grep $SENDER_NAME | grep cwd | awk '{print $7}' | tail -n1)
        if [[ "$CRON_CHECK" =~ \-(FCronDaemon)$ ]]; then
            echo "Użytkownik \"$SENDER_NAME\" prowadzi wysyłkę z zadania CRON" >> $MAILBODY
            continue
        else
            echo "Użytkownik \"$SENDER_NAME\" najprawdopodobniej ma leak hasła do skrzynki pocztowej" >> $MAILBODY
        fi
    done
}

SEND_MAIL () {
    ####### SEND #######
    mail -s "$SUBJECT" $MAIL_DESTINATION < $MAILBODY

    ##### CLEAR BODY #####
    rm -rf $MAILBODY
}

RUN () {
    PREPARE_ENV
    CHECK_WHO
    SEND_MAIL
    exit
}

RUN
