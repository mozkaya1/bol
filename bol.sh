#!/bin/env sh 

## Set alert price -- Only Euro. Not cent --
setPrice=30

## Set bol.com url to be watching -- 
url="https://www.bol.com/nl/nl/p/pd-tang-cv-waterpomptang-29-cm-isolatie-grip-12-profi-stalen-tang-met-softgrip-handvat/9300000160855987"

## Set reasonable interval for price check 
cooldown=10

## Infinite loop for checking price ---
while true ;do
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

## Log writer function for better output
log_write() {
    local message="$1"
    local message2="$2"
    echo "[$timestamp] -- $message -- $message2" 
}

## Get Price of the product with Go Code -- 
output=`go run main.go -set $setPrice -url ${url}`


## split variables from output
status=`echo "${output}"|jq -r .status`
price=`echo "${output}"|jq -r .price`
url=`echo "${output}"|jq -r .url`
discount=`printf "%.0f\n" $(echo ${output}|jq -r .discount)`


if [[ $status == 200 && $discount != 0 ]]; then

  message="$timestamp - Bol.com Discount Alert - % $discount -- $url" 
  setPrice=$price

  #send Telegram Notification with Python Code
  python /home/musti/python-project-server/telegram_v3.py "${message}" >/dev/null

  ## send mail notification 
  # echo "${message}" | mail -s "Bol.com Discount Alert"  -r RECEIVER@hotmail.com
  log_write "Price dropped - % ${discount} --> ${url}"|tee -a bol.log
  continue
else
log_write "No Discount" ${output}|tee -a bol.log
fi

sleep $cooldown
done
