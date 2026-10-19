# 本文件由本次手动操作顺序整理；并非运行配置的 export。请逐节执行并核实。
# 运行环境：MikroTik RouterOS 7.23.8 CHR

# A. 创建网桥及 VPCS 所在接口：执行一次
/interface bridge add name=bridge-lab
/interface bridge port add bridge=bridge-lab interface=ether1
/interface bridge port add bridge=bridge-lab interface=ether2
/interface bridge port print

# B. 观察动态学习；确认 PC1/PC2 接线和 Ping 成功
/interface bridge host print

# C. PC1 静态 FDB 条目
/interface bridge host add bridge=bridge-lab interface=ether1 mac-address=00:50:79:66:68:00
/interface bridge host print

# D. 入口过滤。顺序很重要！allow 规则成功后才加入 drop 规则
/interface bridge filter add chain=forward in-interface=ether1 src-mac-address=00:50:79:66:68:00/FF:FF:FF:FF:FF:FF action=accept comment=lab-allow-pc1
/interface bridge filter add chain=forward in-interface=ether1 action=drop comment=lab-deny-other
/interface bridge filter print
/interface bridge filter print stats

# E. GNS3 Cloud TAP 接入 CHR ether3 后：
/interface bridge port add bridge=bridge-lab interface=ether3
/interface bridge port print
/interface bridge host print

# F. 第一次 Scapy 12 帧实验后检查
/interface bridge host print

# G. 关闭 ether3 学习，再做第二批 Scapy 12 帧实验
/interface bridge port set [find where interface=ether3] learn=no
/interface bridge port print detail where interface=ether3
/interface bridge host print

# H. 可逆恢复（不要在保留防御配置时执行）
# /interface bridge port set [find where interface=ether3] learn=auto
# /interface bridge filter remove [find where comment="lab-deny-other"]
# /interface bridge filter remove [find where comment="lab-allow-pc1"]
