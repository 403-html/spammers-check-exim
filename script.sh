#!/bin/bash
#
# version 1.0.8-dev
# pre 1.1

# Variables
HOSTNAME=$(hostname)
EXIM_LOG="/var/log/exim_mainlog"
MAIL_LOG="/var/log/maillog"
SUBJECT="Spam check on $HOSTNAME"
MAIL_DESTINATION="example@example.com"
BODY_FILE="msg-body.txt"
NUMBER_OF_PEOPLE=5

EXIM_TODAY_DATE=$(tail -n1 $EXIM_LOG | awk '{print $1}')
MAILLOG_TODAY_DATE=$(tail -n1 $MAIL_LOG | awk '{print $1 " " $2}')

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
    COMMAND=$(cat $EXIM_LOG | grep cwd | grep home | awk '{print $3}' | uniq -c | awk '{arr[$2]+=$1} END {for (i in arr) {print arr[i],i}}' | sort -n | tail -n$NUMBER_OF_PEOPLE)
    echo "$COMMAND" | while read -r user
    do
        # Check if it's path to user
        if [[ $user =~ .*(cwd=.*) ]]
        then
            CHECK_FROM_WHERE "$user"
        fi
    done
}

CRON_CHECK () {
    USER=$1
    MAIL_USER=$(echo $USER | awk -F "/" '{print $3}')
    CRON_SEARCH=$(tail -n1 $EXIM_LOG | grep $USER | grep $EXIM_TODAY_DATE | grep cwd | awk '{print $7}')

    # Check if it's cron-job
    if $CRON_SEARCH | grep 'FCronDaemon'; then
        WRITE_TO_FILE "$MAIL_USER wysyła maile najprawdopodobniej przez zadanie crona"
        return
    fi
    false
}
PASS_LEAK () {
    USER=$1
    MAIL_USER=$(echo $USER | awk -F "/" '{print $3}')
    MAIL_ADDRESSES=$(cat $EXIM_LOG | grep $EXIM_TODAY_DATE | exigrep $MAIL_USER | awk '/^([0-9]*-[0-9]*-[0-9]*) ([0-9]*:[0-9]*:[0-9]*) ([0-9a-zA-Z]*-[0-9a-zA-Z]*-[0-9a-zA-Z]*) (<=).*\n/ {print $5}')
    LOGGED_IP=$()

    echo "$MAIL_ADDRESSES" | while read -r mail
    do
        LOGGED_IP=$(cat $MAIL_LOG | grep $MAILLOG_TODAY_DATE | grep $mail | grep "Login: " | awk '{print $10}' | awk '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/{print $1}' | uniq -c | awk '{arr[$2]+=$1} END {for (i in arr) {print arr[i],i}}' | sort -n)
    done
    # Check if it's possibility of mail password leaking
    echo "$LOGGED_IP" | while read -r ip
    do
        IP_LOCATION=$(csf -i $ip | awk -F "(" '{print $2}' | awk -F "/" '{print $1}')
        if ! [[ $IP_LOCATION = "PL" ]]
        then
            WRITE_TO_FILE "Dla $MAIL_USER prawdopodobnie nastąpił wyciek hasła do skrzynki pocztowej"
            return
        fi
    done
    false
}
FORM_SPAM () {
    USER=$1
    MAIL_USER=$(echo $USER | awk -F "/" '{print $3}')
    echo "$USER"
    # Check if it's form spam
    SCRIPT_CHECK=$(tail -n1 $EXIM_LOG | grep $USER | awk '{print $3}' | awk -F "/" '{print $4}')
    if [[ $(SCRIPT_CHECK) =~ "public_html" ]]
    then
        WRITE_TO_FILE "$MAIL_USER prawdopodobnie prowadzi wysyłkę z formularza/skrypu"
        return
    fi
    false
}
CHECK_FROM_WHERE () {
    AMOUNT=$(echo $1 | awk -F' ' '{print $1}')
    USER=$(echo $1 | awk -F' ' '{print $2}')
    
    if [ $(echo $USER | awk -F "/" '{print $4}') ]; then
        MAIL_USER=$(echo $USER | awk -F "/" '{print $3}')
        
        # Check if it's cron-job
        CRON_SEARCH=$(tail -n1 $EXIM_LOG | grep $USER | grep $EXIM_TODAY_DATE | grep cwd | awk '{print $7}' | grep -i 'Cron')

        if ! [[ $CRON_SEARCH == "" ]]; then
            WRITE_TO_FILE "$MAIL_USER wysyła maile najprawdopodobniej przez zadanie crona"
            return
        fi
    fi
    
    # ANSWER=$(CRON_CHECK "$USER")
    # if [[ $ANSWER ]]
    # then
    #     WRITE_TO_FILE "Ilość: $AMOUNT Miejsce wysyłki: $USER"
    #     WRITE_TO_FILE ""
    #     return
    # fi

    # ANSWER=$(FORM_SPAM "$USER")
    # if [[ $ANSWER ]]
    # then
    #     WRITE_TO_FILE "Ilość: $AMOUNT Miejsce wysyłki: $USER"
    #     WRITE_TO_FILE ""
    #     return
    # fi

    # ANSWER=$(PASS_LEAK "$USER")
    # if [[ $ANSWER ]]
    # then
    #     WRITE_TO_FILE "Ilość: $AMOUNT Miejsce wysyłki: $USER"
    #     WRITE_TO_FILE ""
    #     return
    # fi
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
    exit
}

RUN
