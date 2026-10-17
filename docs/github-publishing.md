# 上传 GitHub 与提交前收尾

## 当前状态

本目录已经具备可上传的结构，但尚未创建或推送任何 GitHub 仓库。Word 中“仓库链接”和“提交版本”保留待填写项。实验过程不是实时用 Git 记录的；首次提交只表示整理归档时间。

## 使用 Git 上传

1. 在自己的 GitHub 创建空仓库，建议名 `gns3-acl-lab`。不要把账户密码发给协作者。若设为私有，需给教师相应访问权限。
2. 解压文件包，进入含 README.md 的目录，在有 Git 的终端执行：

```bash
git init
git add .
git commit -m "Archive ACL lab report, configuration and evidence"
git branch -M main
```

3. 从 GitHub 仓库页面复制自己的 HTTPS 地址，用真实地址替换下面占位内容后执行：

```bash
git remote add origin https://github.com/YOUR-USERNAME/gns3-acl-lab.git
git push -u origin main
git rev-parse HEAD
```

这段是待执行指南，本文件不声称上述命令已在用户电脑上执行。GitHub 登录通过 Git 自己的认证流程完成。

也可以用网页 Add file → Upload files 上传解压后的文件夹内容；不要只上传 ZIP，否则教师不便在线阅读。若网页拒绝隐藏的 .gitignore，可用 Git 或网页创建该文件。

## Word 中留给教师的链接

先完成第一次上传，再将仓库根链接填入 Word 的“仓库链接”，将第一次证据归档 commit SHA 填入“证据归档提交”。可以使用 `https://github.com/用户名/仓库名/tree/提交SHA` 指向固定版本，另提供主分支链接查看后续报告。Word 填好链接后再提交一次；不需要让报告包含它自身所在提交的 SHA，避免自引用。

## 建议补充的实际文件

- `topology/final-gns3.png`：最终完整拓扑截图，标注 CHR 承担 R1 角色。
- `configs/chr/device-export.rsc`：从 CHR 实际取出的、经过检查的文本导出。当前 reproduce.rsc 是重建命令集，不替代它。
- 若上传真实 .gns3 项目，先确认节点镜像引用和本机路径；项目文件不等于可携带系统磁盘的一键环境。记录所需镜像和软件即可。
- 二进制 .backup 在设备上留存，不放公开仓库。大型系统镜像与课程 PDF 不收入本项目。

## 检查清单

- [ ] GNS3 本机项目已保存；报告中的 GitHub 链接和归档提交填写完成。
- [ ] 教师能访问仓库，Word 与在线报告描述一致。
- [ ] 原始记录、整理摘录、复现命令三类材料清楚区分。
- [ ] 未把 TCP 探测描述为真实 Web/FTP 应用测试。
- [ ] 未上传设备口令、服务认证文件、系统镜像或二进制备份。
- [ ] 未制造过去的 Git 提交、缺失的抓包或虚构的终端成功输出。
