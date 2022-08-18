# IPtable-F

1. Virtual Machine setting

* 1 VM router - 192.168.1.75
* 2 VM Firewall IP Address : 192.168.1.76(External IP Address)
                             192.168.10.1(Internal IP Address)
* 3 VM Internal Machine : 192.168.10.2

Firewall incoming allow port = tcp_ports=21,443,53,80,22,2000 udp_ports=53,2000

Filter the inbound packet
