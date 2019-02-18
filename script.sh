#!/bin/bash
#
# version 1.1

# Manual Variables
MAIL_DESTINATION="example@example.com"
PEOPLE_OUTPUT="5"
EXIM_PATH="/var/log/exim_mainlog"
MAIL_PATH="/var/log/maillog"
DOMLOGS_PATH="/var/log/apache2/domlogs"

# Automatic Variables
HOSTNAME=$(hostname)
SUBJECT="Spam check on $HOSTNAME"
MAILBODY="mailbody.txt"
EXIM_DATE=$(tail -n1 $EXIM_PATH | awk '{print $1}')

# Prepare mail body file
PREPARE_ENV () {
    if [ -d "$MAILBODY" ]; then
        echo "Spam check on $HOSTNAME" > $MAILBODY
    else
        touch $MAILBODY && echo "SPAM check on $HOSTNAME" > $MAILBODY
    fi
}

CHECK_WHO () {
    SENDERS_LIST=$(cat $EXIM_PATH | grep $EXIM_DATE | grep home | grep cwd | awk '{print $3}' | uniq -c | awk '{arr[$2]+=$1} END {for (i in arr) {print arr[i],i}}' | sort -n | tail -n$PEOPLE_OUTPUT | awk '{print $2}')
    
    echo "$SENDERS_LIST" | while read -r SENDER
    do
        SENDER_NAME=$(echo $SENDER | awk 'BEGIN { FS = "/" } ; { print $3 }')

        CRON_CHECK=$(cat $EXIM_PATH | grep $SENDER_NAME | grep cwd | awk '{print $7}' | tail -n1)
        if [[ "$CRON_CHECK" =~ \-(FCronDaemon)$ ]]; then
            echo "Użytkownik \"$SENDER_NAME\" prowadzi wysyłkę z zadania CRON" >> $MAILBODY
            continue
        fi

        FORM_CHECK=$(echo $SENDER | awk 'BEGIN { FS = "/" } ; { print $5 }')
        if [[ "$FORM_CHECK" ]]; then
            echo "Użytkownik \"$SENDER_NAME\" prowadzi wysyłkę z katalogu w $(echo $SENDER | awk 'BEGIN { FS = "/" } ; {out=""; for(i=2;i<=NF;i++){out=out"/"$i}; print out}')" >> $MAILBODY
            continue
        fi

        MAILS_LIST=$(cat $EXIM_PATH | grep $EXIM_DATE | exigrep "Sender identification" | exigrep $SENDER_NAME | grep "U=$SENDER_NAME" | awk '$5 ~/\S+@\S+/ {print $5}' | uniq -c | awk '{arr[$2]+=$1} END {for (i in arr) {print arr[i],i}}' | sort -n | awk '{print $2}' )
        echo "$MAILS_LIST" | while read -r MAIL
        do
            if [[ "$MAIL" =~ "$HOSNAME" ]]; then
                SEND_TIMESTAMP=$(cat $EXIM_PATH | grep $EXIM_DATE | grep $SENDER | awk '{print $2}')
                TIME_ANSWER=0
                echo "$SEND_TIMESTAMP" | while read -r STAMP
                do    
                    POST_CHECK=$(cat ${DOMLOGS}/${SENDER_NAME}/* | grep $STAMP | grep -i post)
                    if [[ "$POST_CHECK" ]]; then
                        echo "Użytkownik \"$SENDER_NAME\" prowadzi wysyłkę z katalogu w $(echo $SENDER | awk 'BEGIN { FS = "/" } ; {out=""; for(i=2;i<=NF;i++){out=out"/"$i}; print out}')" >> $MAILBODY
                        TIME_ANSWER=$(($TIME_ANSWER+1))
                        break
                    fi
                done

                if [[ $TIME_ANSWER -ne 0 ]]; then
                    echo "Użytkownikowi \"$SENDER_NAME\" prawdopodobnie wyciekły dane do cPanel" >> $MAILBODY
                    continue
                fi
                continue
            fi

            MAIL_LOGIN_IPS=$(cat $MAIL_PATH | grep $MAIL | grep "Login: " | awk '{print $10}' | awk 'match($0,/(\w+\.\w+\.\w+\.\w+)/) {print substr($0,RSTART,RLENGTH)}')

            echo "$MAIL_LOGIN_IPS" | while read -r IP
            do
                IP_LOCATION=$(csf -i $IP | awk 'match($0,/[A-Z]{2}/) {print substr($0,RSTART,RLENGTH)}')
                if ! [[ "$IP_LOCATION" == PL ]]; then
                    echo "Użytkownik \"$SENDER_NAME\" wysyła z adresu $MAIL który jest z $IP" >> $MAILBODY
                    else
                        continue
                fi
            done
        done
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
