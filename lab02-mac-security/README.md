# Lab 02 · MAC 地址表与端口安全

网络安全课程 · 课堂实验二 · 2026-10-19

## 实验内容

本实验使用 GNS3、VPCS、MikroTik CHR 和 WSL2 Ubuntu 完成 MAC 地址动态学习、静态 MAC 表项、端口源 MAC 过滤、受控多源 MAC 学习及防护测试。初期采用华为 CE12800 搭建网络，相关通信异常及排查过程记录在报告中。

## 实验结果

| 项目 | 结果 |
|---|---|
| 动态 MAC 学习 | PC1→ether1，PC2→ether2 |
| 静态 MAC 表项 | PC1 MAC 固定在 ether1 |
| 正常主机通信 | PC2→PC1，Ping 5/5 |
| 端口允许规则 | Accept 6 packets / 470 bytes，合法 Ping 5/5 |
| 其他源 MAC 过滤 | Drop 3 packets / 150 bytes |
| 多源 MAC 学习 | 首轮 12 个源 MAC 均进入 MAC 表 |
| 学习控制 | ether3 learn=no，第二轮 12 个新 MAC 未被学习 |
| 防护后连通性 | PC2→PC1，Ping 5/5 |

## 文件

- [最终 Word 实验报告](report/297高小雅_课堂实验二重制版.docx)
- [在线实验正文](docs/report.md)
- [最初 CE12800 排障记录](docs/troubleshooting.md)
- [实验输出摘录](docs/evidence.md)
- [RouterOS 命令](configs/routeros_commands.rsc)
- [Scapy 测试程序](scripts/controlled_mac_probe.py)
- [测试结果 CSV](results/observations.csv)

## 实验连接

```text
PC1 2.0.0.1/24 ─ ether1 ┐
                       ├── MikroTik CHR / bridge-lab
PC2 2.0.0.2/24 ─ ether2 ┤
WSL2 Ubuntu ─ Cloud ─ ether3
```

测试由隔离 GNS3 TAP 接口发出，每次限量发送 12 帧。最终报告以本目录的 Word 文件为准。
