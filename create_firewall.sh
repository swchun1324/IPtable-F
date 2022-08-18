#!/bin/bash

int_subnet=192.168.10.0/24
ext_conn=enp0s3
int_conn=enp0s8
ext_dest_ip=192.168.1.75
firewall_ext_ip=192.168.1.76
firewall_int_ip=192.168.10.1
int_ip=192.168.10.2
tcp_ports=21,443,53,80,22,2000
udp_ports=53,2000

#routing rules

iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o $ext_conn -j MASQUERADE



#iptables -t nat -A POSTROUTING -p tcp --dport 22 -d 192.168.1.75 -j SNAT --to-source 192.168.10.2
#iptables -A PREROUTING -t nat -d 192.168.10.2 -p tcp --dport 22 -j DNAT --to-destination 192.168.1.75:22



#Default Drop Policy
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

#DROP inbound traffic port which is less than 1024 to port 80
iptables -A FORWARD -p tcp --dport 80 --sport 0:1024 -j DROP

iptables -A INPUT -s 192.168.10.0/24 -i enp0s3 -j DROP

#Forwarding rule accept port
iptables -A FORWARD -p tcp --match multiport --dport $tcp_ports -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --match multiport --sport $tcp_ports -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p udp --match multiport --dport $udp_ports -j ACCEPT
iptables -A FORWARD -p udp --match multiport --sport $udp_ports -j ACCEPT

#input/output rule accept
iptables -A INPUT -p tcp --match multiport --dport $tcp_ports -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --match multiport --sport $tcp_ports -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --match multiport --sport $tcp_ports -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --match multiport --dport $tcp_ports -m state --state NEW,ESTABLISHED -j ACCEPT 

#SYN-FIN ATTACK DROP
iptables -A FORWARD -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP

#Drop all the telnet packets
iptables -A FORWARD -p tcp --dport 23 -j DROP
iptables -A FORWARD -p tcp --sport 23 -j DROP



#ssh-server
iptables -t nat -A POSTROUTING -o enp0s8 -p tcp --dport 22 -d 192.168.1.75 -j SNAT --to-source 192.168.10.2
iptables -A PREROUTING -t nat -i enp0s3 -d 192.168.10.2 -p tcp --dport 22 -j DNAT --to-destination 192.168.1.75:22

#httpd-server
iptables -A PREROUTING -i enp0s3 -t nat -p tcp -d 192.168.10.2 --dport 80 -j DNAT --to-destination 192.168.1.75:80
iptables -A POSTROUTING -o enp0s8 -t nat -p tcp -d 192.168.1.75 --dport 80 -j SNAT --to-source 192.168.10.2

#https-server
iptables -A PREROUTING -i enp0s3 -t nat -p tcp -d 192.168.10.2 --dport 443 -j DNAT --to-destination 192.168.1.75:443
iptables -A POSTROUTING -o enp0s8 -t nat -p tcp -d 192.168.1.75 --sport 443 -j SNAT --to-source 192.168.10.2

#ftp server
iptables -A PREROUTING -i enp0s3 -t nat -p tcp -d 192.168.10.2 --dport 21 -j DNAT --to-destination 192.168.1.75:21
iptables -A POSTROUTING -o enp0s8 -t nat -p tcp -d 192.168.1.75 --sport 21 -j SNAT --to-source 192.168.10.2

#DNS server
iptables -A PREROUTING -i enp0s3 -t nat -p tcp -d 192.168.10.2 --dport 53 -j DNAT --to-destination 192.168.1.75:53
iptables -A POSTROUTING -o enp0s8 -t nat -p tcp -d 192.168.1.75 --sport 53 -j SNAT --to-source 192.168.10.2
#udp-server
iptables -A PREROUTING -i enp0s3 -t nat -p udp -d 192.168.10.2 --dport 53 -j DNAT --to-destination 192.168.1.75:53
iptables -A POSTROUTING -o enp0s8 -t nat -p udp -d 192.168.10.2 --sport 53 -j SNAT --to-source 192.168.10.2


#Allow ping request from firewalls to internal&external
iptables -A FORWARD -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 0 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 0 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -m state --state NEW,ESTABLISHED -j ACCEPT



#Minimum Delay for ssh & ftp and FTPdata to "Maximum Throughput"
iptables -A PREROUTING -t mangle -p tcp --sport telnet -j TOS --set-tos Minimize-Delay
iptables -A PREROUTING -t mangle -p tcp --sport ftp -j TOS --set-tos Minimize-Delay
iptables -A PREROUTING -t mangle -p tcp --sport ftp-data -j TOS --set-tos Maximize-Throughput
