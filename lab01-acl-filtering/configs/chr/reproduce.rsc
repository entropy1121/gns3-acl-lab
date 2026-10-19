# 手工整理的复现配置，不是设备生成的 Lab2_ACL.rsc 原文件。
# 仅适用于全新 CHR，接口名称为 ether1、ether2、ether3。重复执行会重复添加条目。
# 原 CE12800 R1 应停止并断开三条业务链路，再由 CHR 接管相同地址。
/ip address add address=192.168.1.1/24 interface=ether1
/ip address add address=192.168.2.1/24 interface=ether2
/ip address add address=192.168.3.1/24 interface=ether3
/ip route add dst-address=10.0.0.0/24 gateway=192.168.1.2
/ip firewall filter add chain=forward src-address=10.0.0.0/24 dst-address=192.168.3.0/24 action=drop comment="ACL1"
/ip firewall filter add chain=forward src-address=192.168.3.0/24 dst-address=10.0.0.0/24 protocol=tcp dst-port=80 action=drop comment="ACL2-WEB"
/ip firewall filter add chain=forward src-address=192.168.3.0/24 dst-address=!192.168.3.0/24 protocol=tcp dst-port=21 action=drop comment="ACL3-FTP"
