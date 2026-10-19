# 关键原始终端输出摘录

以下摘录按真实实验对话中的终端输出整理，省略了系统提示和与观察无关的字段。未执行的操作不列为完成；部分阶段只保存了计数而非完整 Ping 输出。

## 1. 动态学习

```text
Flags: D - DYNAMIC; L - LOCAL
0 D  00:50:79:66:68:00  ether1  bridge-lab
1 D  00:50:79:66:68:01  ether2  bridge-lab
```

## 2. 静态学习状态

```text
0    00:50:79:66:68:00  ether1  bridge-lab
1 D  00:50:79:66:68:01  ether2  bridge-lab
```

## 3. 正常源 MAC 放行

```text
;;; lab-allow-pc1
0 forward accept 470 6
;;; lab-deny-other
1 forward drop     0 0
PC1> ping 2.0.0.2
icmp_seq=1..5: 0.823 / 1.124 / 0.993 / 0.963 / 1.514 ms
```

## 4. 非法源 MAC 丢弃

```text
;;; lab-allow-pc1
0 forward accept   0 0
;;; lab-deny-other
1 forward drop   150 3
```

## 5. 多源 MAC 学习：无防御

```text
1  D 02:AA:BB:CC:00:01 ether3 bridge-lab
2  D 02:AA:BB:CC:00:02 ether3 bridge-lab
3  D 02:AA:BB:CC:00:03 ether3 bridge-lab
4  D 02:AA:BB:CC:00:04 ether3 bridge-lab
5  D 02:AA:BB:CC:00:05 ether3 bridge-lab
6  D 02:AA:BB:CC:00:06 ether3 bridge-lab
7  D 02:AA:BB:CC:00:07 ether3 bridge-lab
8  D 02:AA:BB:CC:00:08 ether3 bridge-lab
9  D 02:AA:BB:CC:00:09 ether3 bridge-lab
10 D 02:AA:BB:CC:00:0A ether3 bridge-lab
11 D 02:AA:BB:CC:00:0B ether3 bridge-lab
12 D 02:AA:BB:CC:00:0C ether3 bridge-lab
16 D 12:DB:3B:80:34:AD ether3 bridge-lab
```

## 6. 防御状态确认

```text
/interface bridge port print detail where interface=ether3
2 interface=ether3 bridge=bridge-lab ... learn=no ...
```

第二批测试后表内只有 PC1 的静态表项及 CHR 的 DL 项，未出现 `02:AA:BB:CC:01:01`—`01:0C` 新地址。

## 7. 恢复 PC1 接线后的最终 Ping

```text
PC2> ping 2.0.0.1
84 bytes from 2.0.0.1 icmp_seq=1 ttl=64 time=0.987 ms
84 bytes from 2.0.0.1 icmp_seq=2 ttl=64 time=0.946 ms
84 bytes from 2.0.0.1 icmp_seq=3 ttl=64 time=0.764 ms
84 bytes from 2.0.0.1 icmp_seq=4 ttl=64 time=1.419 ms
84 bytes from 2.0.0.1 icmp_seq=5 ttl=64 time=0.709 ms
```

## 8. ARP 抓包

```text
5 2.000880 00:50:79:66:68:01 Broadcast ARP Who has 2.0.0.1? Tell 2.0.0.2
6 2.001004 00:50:79:66:68:00 00:50:79:66:68:01 ARP 2.0.0.1 is at 00:50:79:66:68:00
```
