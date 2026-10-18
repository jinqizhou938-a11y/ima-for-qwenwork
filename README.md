# ima 知识库套件 · QwenWork 接入（引导 + 官方 zip 版）

> **本仓库不含腾讯官方 `ima-skill` 的源码。** 出于版权与版本迭代考虑，这里只提供"安装引导 + 凭证配置"；真正的 `ima-skill` 由你在本机**从 ima 官方 zip 现取现装**。既规避再分发风险，又保证你用的永远是最新版。

把腾讯 **ima（ima.copilot）** 的笔记与知识库接入**千问办公**：浏览库内容、库内搜索、读取原文、上传文件、添加网页、创建/追加笔记——直连**你自己的** ima 账号，数据实时来自云端、本机不留副本。

## 为什么"引导装"而不是"打包"

- **版权**：`ima-skill` 归腾讯，静态打包等于再分发他人代码；改为从官方 zip 安装，本仓库只提供引导。
- **新鲜**：官方包会更新（脚本内置每日版本检查），打包副本必然滞后；现取现装保证最新。
- **安全**：仓库里没有任何人的 API Key，也没有需要审计的官方代码副本。

## 前置条件

- 已安装 **千问办公**桌面端。
- **Node.js ≥ 18**（`node -v`），以及能下载解压 zip 的环境（macOS / Linux / Windows 的 Git Bash）。
- 一个 **ima 账号**，且能在 https://ima.qq.com/agent-interface 领取 Agent 接口凭证。

## 三步上手

> 💡 **想最省事**：直接跳到第 3 步说"配置 ima 接入"——`ima-setup` 会在官方包缺失时**自动先执行第 2 步的安装**，再引导你配 key。对外的一个入口就是它。

### 1）装本套件（含两个引导技能）
```bash
git clone https://github.com/jinqizhou938-a11y/ima-for-qwenwork.git
# macOS / Linux
mkdir -p ~/.qwenworkcn/plugins-custom
cp -r ima-for-qwenwork ~/.qwenworkcn/plugins-custom/ima-knowledge-kit
# Windows（PowerShell）
# New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.qwenworkcn\plugins-custom" | Out-Null
# Copy-Item -Recurse .\ima-for-qwenwork "$env:USERPROFILE\.qwenworkcn\plugins-custom\ima-knowledge-kit"
```
在千问办公「插件」页看到 **ima 知识库套件** 即成功（没有就重启一次）。

### 2）拉取并安装官方 ima-skill
对话里说 **“安装 ima 技能”**（`/ima-install`），它会从官方 zip 现取现装到 `~/.qwenworkcn/skills/ima-skill`。想指定最新版，把官方页的当前下载链接一起给它：
```bash
bash skills/ima-install/scripts/install_ima_skill.sh "https://app-dl.ima.qq.com/skills/ima-skills-<最新版本>.zip"
```

### 3）配置你自己的凭证 + 开用
说 **“配置 ima 接入”**（`/ima-setup`），按引导领取并**在本地终端**写入 Client ID / API Key，并自动验证。之后用大白话查你的库即可：
- 「列出我的 ima 知识库」 / 「在『产品文档库』里搜『排期』」
- 「把这个网页加到『行业研究』库：https://…」 / 「新建一篇笔记记录……」

> 🔒 Client ID / API Key 是你账号的钥匙（能读**也能改删**库与笔记）：**不要粘贴进对话、不要发给任何 AI**；泄露立即在 ima 后台作废重生成。`~/.config/ima/` 不要进网盘/同步盘/Git（本仓库 `.gitignore` 已挡）。

## 工作原理（简述）

千问办公读 `ima-skill/SKILL.md` 决定调哪个接口，再跑 `node ima_api.cjs <接口路径> <JSON参数>`；脚本带 `ima-openapi-clientid` / `ima-openapi-apikey` 请求头 POST 到 `https://ima.qq.com/...`。凭证读取优先级：调用参数 → 环境变量 `IMA_CLIENT_ID`/`IMA_OPENAPI_CLIENTID` → 文件 `~/.config/ima/{client_id,api_key}`。

## 目录结构（只有引导，没有官方源码）
```
ima-for-qwenwork/
├── .qwenwork-plugin/plugin.json
├── .gitignore
├── README.md
└── skills/
    ├── ima-install/SKILL.md
    │   └── scripts/install_ima_skill.sh   # 从官方 zip 现取现装
    └── ima-setup/SKILL.md                 # 领 key → 本地配 → 验证
```

## 常见问题

- **提示 `-200 需要更新`**：官方脚本检测到新版——重新跑 `/ima-install`（带上官方页最新链接）即可。
- **鉴权失败（`20004`/`未找到凭证`）**：key 复制不全/多了换行/路径不对；按"无换行 + 单引号"重配（见 `ima-setup` Step 3）。
- **安装脚本报"未找到 ima_api.cjs"**：官方包结构可能变了，把最新链接贴进来重试；仍不行开 Issue。
- **视频 / `file://` 加不进知识库**：这些不支持经接口添加，需回 ima 客户端手动加。

## 来源与许可

- `ima-skill` 及其 `ima_api.cjs`、模块与脚本**版权归腾讯（ima）**，通过 `https://app-dl.ima.qq.com/skills/` 官方分发；**本仓库不复制、不再分发这些代码**，只帮你安装自行从官方获取的副本。
- 本仓库自创内容（`ima-install`、`ima-setup`、README、安装脚本）由仓库作者提供，用于降低接入与配置门槛。
- 使用前请遵守 ima 官方服务条款。

---

如果这个项目帮到了你，欢迎给个 ⭐。Issue / PR 请注明 ima 版本与复现步骤。
