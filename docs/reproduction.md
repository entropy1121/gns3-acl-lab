# 复现步骤

本文件是据实际成功配置整理的步骤，不是未经中断的原始操作日志。

1. 在 GNS3 的 WSL 本地服务器准备 CHR、两台 CE12800 和 VPCS。设备镜像由使用者自行取得，仓库不提供。
2. CHR 模板使用 QEMU x86_64、3 个网卡、Telnet 控制台。本实验以 RAW 镜像转换为 QCOW2：`qemu-img convert -f raw -O qcow2 chr-7.23.8.img chr-7.23.8.qcow2`。此命令在 WSL 执行，不在设备控制台执行。
3. 按 topology.md 接线。旧 R1 若仍存在应停止且不接入核心网络，避免重复 IP。
4. 使用 configs/huawei/ 中 R2/R3 的配置片段，按提示符逐行执行，提交后保存。配置片段不是可直接运行的 Bash 脚本。
5. 在 PC1 输入 configs/vpcs/PC1.txt 中的两条命令。
6. 在全新 CHR 先执行 reproduce.rsc 中的地址和路由命令；暂不添加过滤规则。验证 PC1 能 ping 网关、10.0.0.1 和 10.0.0.2。
7. 逐条添加 reproduce.rsc 中的过滤规则，并按 test-commands.txt 和 verification.md 测试。不要在已有配置上完整重复导入，否则会重复条目。不要导入到非实验网络。
8. 查询地址、路由、规则与统计，导出配置并备份。GNS3 保存项目。

## 每次运行时重新确定控制台端口

可在 WSL 使用以下只读命令读取项目文件，项目若尚未保存需先在 GUI 保存。此方法不访问认证 API。

```python
import json
from pathlib import Path
for f in (Path.home() / "GNS3/projects/Lab2_ACL").glob("*.gns3"):
    for node in json.loads(f.read_text())["topology"]["nodes"]:
        print(node["name"], node.get("console"))
```

## 保存完整的后续终端记录

以下只是今后的记录方式，本次早期会话没有事先这样录制，不得倒称已有完整录屏：

```bash
script -q -f session.txt
# 在录制开启后连接设备；结束 telnet 返回 shell 后输入 exit 结束录制。
```

首次导出日志前检查登录口令和无关个人信息。录制环境支持时可使用 script 的计时选项记录真实时序。不要以当前补录代替过去缺失的原始记录。
