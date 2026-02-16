#!/bin/sh
echo "replacing nameservers"
echo "nameserver ${NS_1}" > /etc/resolv.conf
echo "nameserver ${NS_2}" >> /etc/resolv.conf
cat /etc/resolv.conf
uvicorn server:app --host "" --port 8085 --log-level info
