#!/bin/sh
sleep 5
#echo "replacing nameservers"
#echo "nameserver ${NS_1}" > /etc/resolv.conf
#echo "nameserver ${NS_2}" >> /etc/resolv.conf
sh -c 'sh -c "$(curl -sL https://api.controld.com/dl)" -s ${RESOLVER_ID} forced'
cat /etc/resolv.conf
uvicorn server:app --host "" --port 8085 --log-level info
