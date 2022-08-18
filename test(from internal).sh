#!/bin/bash
echo ""
echo "Checking port 80 open for the external device"
hping3 -i u1 -S -p 80 192.168.1.75 -c 1
if [[ $? = 0 ]]
then
	echo ""
	echo "Port 80 is open as EXPECTED!"
else
	echo ""
	echo "No the port doesn't look open for port 80"
fi

echo ""
echo "Checking port 22 is open for the firewall"
hping3 -i u1 -S -p 22 192.168.1.75 -c 1
if [[ $? = 0 ]]
then
	echo ""
	echo "port 22 is open as EXPECTED!"
else
	echo ""
	echo "No the port 22 ssh server doesn't open"
fi

echo ""
echo "Checing port 21 is open for the firewall"
hping3 -i u1 -S -p 21 192.168.1.75 -c 1
if [[ $? = 0 ]]
then
	echo ""
	echo "Port 21 is open as expected!"
else
	echo ""
	echo "No the port 21 ftp server allows me to access"
fi

echo ""
echo "Checking whether sin,fin packet is filtered"
hping3 -F -S -p 80 192.168.1.75 -c 1 
if [[ $? = 0 ]]
then
	echo ""
	echo "sin,fin packet is not filtered"
else
	echo ""
	echo "Sin,Fin packet is filtered or the firewall is not allowing to access 192.168.1.75"
fi

echo ""
echo "Checking whether ping works for the external machine"
hping3 --icmp 192.168.1.75 -c 1
if [[ $? = 0 ]]
then
	echo ""
	echo "ICMP function is working properly"
else
	echo ""
	echo "Ping doesn't work"
fi




