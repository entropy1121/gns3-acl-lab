# 原 CE12800 排障记录（保留真实失败过程）

## 1. 初始状态

`real lab2`：两台 CE12800、四台 VPCS，PC1—PC4 为 `2.0.0.1` 至 `.4/24`，全部规划于 VLAN 2。SW2 的 VLAN 显示 `UT:GE1/0/1(U) GE1/0/2(U)`、`TG:GE1/0/0(U)`；端口 UP/UP 并不能证明收到正确数据包。PC1→PC2 初始 Ping 报 `host not reachable`，MAC 表为 0。

## 2. 接口映射修正

既往 ACL 实验验证过 CE12800 QEMU 模板接口名 +2 偏移：GNS3 GUI `GE1/0/3` 对应设备内部 `GE1/0/1`；GUI `GE1/0/4` 对应内部 `GE1/0/2`。修改接线和重启 SW2 后开始学习 PC1 `0050-7966-6800`；MAC 表重复显示相同的地址，不应误认为两台主机。

## 3. 双端抓包结果

PC2 一侧发送 `ARP Who has 2.0.0.1? Tell 2.0.0.2`。PC1 所在链路看得到相同请求和由 PC1 `00:50:79:66:68:00` 发往 PC2 `00:50:79:66:68:01` 的 `ARP Reply: 2.0.0.1 is at ...:00`；PC2 链路没有看到 Reply。PC2 的 MAC 也曾被 SW2 学习到内部 `GE1/0/2`。

一次 SW2 重启后统计：

- 内部 GE1/0/1：Input 0；Output 12 Broadcast。
- 内部 GE1/0/2：Input 12 Broadcast；Output 0。
- 两个接口 Unicast 计数均为 0。

这些数据与链路 PC1 侧捕获到回复同时存在，反映可能有设备内部数据平面、虚拟 NIC 映射或计数实现异常，不能据此确定唯一根因。

## 4. 最小可运行对照

新建 `link-test`，仅使用 2 个 VPCS 与 GNS3 Ethernet switch：在 PC1/PC2 分别配置 `2.0.0.1/24` 和 `2.0.0.2/24` 后，PC2→PC1 Ping 5/5。这证明 VPCS 本身及 GNS3 基础二层仿真可以通信。此后引入 CHR，复现 MAC 学习与过滤实验。

## 5. 排错与修复案例

- RouterOS `src-mac-address=00:50:79:66:68:00` 返回 `expected /`，应使用 `src-mac-address=00:50:79:66:68:00/FF:FF:FF:FF:FF:FF`；先撤回已生效的 deny 规则，避免反向锁死合法流量。
- 临时将 PC3 替换 ether1 的 PC1，完成非法 MAC 测试后曾忘记恢复。防御后的第一次 Ping 不可达与此有关；恢复 PC1 后 5/5 成功。
- 未将 WSL `eth0` 桥接物理外网，Cloud 只选 `tap-maclab`。

## 6. 排障方法提炼

正确次序：**接口实际映射 → L1/L2 状态 → 源 MAC 学习 → ARP 请求与回复双向抓包 → 交换机计数 → 最小隔离对照 → 平台差异说明**。不把故障现象直接写成已证实的原因。
