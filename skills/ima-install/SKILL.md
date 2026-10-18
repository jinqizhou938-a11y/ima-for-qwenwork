---
name: ima-install
version: 1.1.0
description: Install the OFFICIAL Tencent ima-skill from ima's own zip into the local QwenWork skills folder — this repo deliberately does NOT bundle ima's code. Accepts any version URL, defaults to a known release.
name_en: ima Install
name_zh: 安装官方 ima 技能
description_en: Fetch the official ima-skill zip from ima and install it locally; no third-party copy is bundled.
description_zh: 从 ima 官方 zip 下载并安装官方 ima-skill 到本地技能目录。本仓库刻意不打包腾讯代码，避免版权与版本滞后问题。
user-invocable: true
argument-hint: 可选：官方 zip 链接（默认用已知版本）
argument-hint-en: optional: official zip URL (falls back to a known version)
argument-hint-zh: 可选：官方 zip 下载链接；不提供则用内置默认版本
---

# 安装官方 ima 技能（ima-install）

**这个仓库不包含腾讯官方的 `ima-skill` 代码**（版权与"官方包会迭代、静态副本必然滞后"的考虑）。本技能负责**从 ima 官方 zip 现场拉取并安装**到本地技能目录，装好后 `ima-setup` 才能工作。

## 官方 zip 来源

- 凭证页 / 下载入口：`https://ima.qq.com/agent-interface`（用用户自己的账号查看当前提供的下载链接与版本）
- 官方直链形如：`https://app-dl.ima.qq.com/skills/ima-skills-<版本>.zip`
- 内置默认版本（兜底，可能非最新）：`1.1.10`

> ⚠️ 若要绝对最新版本，请让用户从上面 agent-interface 页面复制**当前**下载链接，作为参数传入。

## 执行

跑本技能自带脚本（Bash 环境；Windows 用户在 Git Bash 或 WSL 下执行）：

```bash
bash scripts/install_ima_skill.sh "<官方zip链接，可选>"
```

脚本行为：
1. 下载 zip 到临时目录 → 解压 → 定位其中的 `ima-skill` 目录（含 `SKILL.md` + `ima_api.cjs`）。
2. 清理 macOS 残留（`.DS_Store`、`__MACOSX`、`.history`）。
3. 安装到 `~/.qwenworkcn/skills/ima-skill`；若已存在，先把旧的移动到 `ima-skill.bak.<时间戳>`（**不永久删除**）。
4. 打印安装路径与 `ima-skill` 内 `meta.json` 的版本号。

## 验证安装

```bash
node ~/.qwenworkcn/skills/ima-skill/ima_api.cjs   # 无参数会报"缺少 apiPath"，说明脚本就位
```
看到脚本自身的错误提示（而非"文件不存在"）即表示安装成功。

## 安装后下一步

引导用户运行 **`ima-setup`** 配置**其本人账号**的 Client ID / API Key（本地配置，不要贴进对话）。

## 无脚本环境兜底

如果用户没有 Bash/unzip：直接给出手动步骤——浏览器下载官方 zip → 解压出 `ima-skill` 文件夹 → 放到 `~/.qwenworkcn/skills/ima-skill`（Windows 为 `%USERPROFILE%\.qwenworkcn\skills\ima-skill`）→ 删除其中 `.DS_Store` / `.history`。

## 连接器

不需要 MCP / 外部连接器；只从 ima 官方域名下载公开分发物。
