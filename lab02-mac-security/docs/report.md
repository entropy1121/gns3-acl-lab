# 实验二：MAC 地址表与端口安全（2026-10-19）

## 一、实验任务

课程《第五章 MAC地址表及端口安全2.pdf》第 2—3 页要求设计 GNS3 拓扑，使用物理 / 虚拟 Ubuntu 向交换机 SW2 发送 MAC 泛洪并进行防护；第 4—10 页给出了 Huawei 与 Cisco 的原生 Port Security 参考命令。实际实施首先在华为 CE12800 上验证了 VLAN 2、接口映射和 ARP；因数据平面现象不一致，采用最小对照网络，并将实操的交换角色改为 MikroTik CHR。没有把 CHR 配置混写成 Huawei / Cisco 命令。

## 二、实验技术原理

交换机按入接口与源 MAC 学习动态表项，并根据目的 MAC 定向转发。不断变化的源 MAC 会占用更多表项。静态 MAC 项固定目的 MAC 对应的接口；源 MAC `accept/drop` 是入口方向的帧过滤；bridge port `learn=no` 阻止从对应端口学习新的动态 MAC。三者目的不同。

本实验两轮各发送 12 个有限测试帧，目的是验证学习变化，不是 CAM 表耗尽攻击。使用保留实验用 EtherType `0x88B5`，每帧间隔 0.1 秒。

## 三、环境与拓扑

- Windows 11 + WSL2 Ubuntu + GNS3 2.2.61。
- MikroTik CHR RouterOS 7.23.8 long-term；`bridge-lab` 具有 `ether1` / `ether2` / `ether3`。
- PC1 `2.0.0.1/24` / `00:50:79:66:68:00` → `ether1`。
- PC2 `2.0.0.2/24` / `00:50:79:66:68:01` → `ether2`。
- Cloud（WSL TAP `tap-maclab`）→ `ether3`。

## 四、按顺序验证

### 4.1 正常动态 MAC 表

`/interface bridge host print` 显示：

```text
0 D  00:50:79:66:68:00 ether1 bridge-lab
1 D  00:50:79:66:68:01 ether2 bridge-lab
```

PC2 Ping PC1：5/5 成功（1.032、0.662、1.007、0.682、1.060 ms）。

### 4.2 静态地址

执行 `/interface bridge host add bridge=bridge-lab interface=ether1 mac-address=00:50:79:66:68:00`，PC1 项不再有 `D`，PC2 仍为动态。

### 4.3 源 MAC 合法 / 非法接入

先接受 `ether1` 的源 MAC `00:50:79:66:68:00/FF:FF:FF:FF:FF:FF`，再丢弃同接口的其他源 MAC。合法 PC1 → PC2 Ping 5/5 成功；Accept 6 包 / 470B，Drop 0。临时用 PC3 接入该端口后的计数：Accept 0，Drop **3 包 / 150B**。未保留 PC3 完整 Ping 输出，因此此处以过滤计数作为测试结果。

### 4.4 第一轮有限多源 MAC 帧测试

WSL2 `Scapy` 经 TAP / Cloud / CHR ether3 发送 12 个源 MAC `02:AA:BB:CC:00:01` 到 `02:AA:BB:CC:00:0C`，在 `bridge host print` 中全部动态学习于 ether3。另有 `tap-maclab` 本机 MAC `12:DB:3B:80:34:AD`。

### 4.5 禁止攻击测试端口学习与第二轮对照

在 CHR 上设置 `/interface bridge port set [find where interface=ether3] learn=no`；`print detail` 显示 `learn=no`。然后用第二批 `02:AA:BB:CC:01:01` 到 `02:AA:BB:CC:01:0C` 进行对照。新一轮 MAC 表没有出现 12 个新地址。旧记录同时老化消失并不构成反证，比较依据是**新地址是否学习**。

### 4.6 防御后正常业务恢复

测试前曾把 PC1 从 ether1 暂时换为 PC3，首次防御后 PC2→PC1 Ping 不可达。恢复 PC1 接线后，5/5 成功，RTT 依次 0.987、0.946、0.764、1.419、0.709 ms。因此**不能把首次失败归因于 `learn=no`**。

## 五、CE12800 的排障价值

初始实验在华为 CE12800 双交换机中进行；Access 与 Trunk 配置处于 VLAN 2，接口 UP/UP 却无法 Ping。根据旧实验查到该模板 GUI `GE1/0/3` 与 `GE1/0/4` 分别映射设备内部 `GE1/0/1` 和 `GE1/0/2`，调整后 PC1 的广播得到 MAC 学习。随后 Wireshark 从 PC2 侧观察到 ARP Request，PC1 侧观察到该 Request 和 PC1 的 ARP Reply，但 PC2 侧未观察到 Reply；部分交换机接口计数与链路抓包不一致。最小网络更换为 GNS3 内置 Ethernet switch 后，两台 VPCS 互 Ping 成功，故未无根据地将责任归于 PC IP、路由或 VLAN。

详细过程参见 [`troubleshooting.md`](troubleshooting.md) 和 [`evidence.md`](evidence.md)。原 CE12800 异常最终原因仍待验证。

## 六、讨论与结论

实测说明伪造源 MAC 会进入动态学习表，接口 `learn=no` 抑制了新的学习记录，而 Bridge Filter 的 allow / deny 则在另一个独立实验中直接阻断不受信任源 MAC 的转发。此工作不涉及真正的 CAM 耗尽，也不能声称已验证华为原生 Sticky、port security maximum、blackhole 或三种违规处理模式。
