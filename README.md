# ima for QwenWork（ima 知识库套件）

把腾讯 **ima（ima.copilot）** 的笔记与知识库接入**千问办公 / QwenWork**，直接在你的千问办公里浏览库内容、库内搜索、读取原文、上传文件、添加网页、创建/追加笔记——通过 **ima 官方 OpenAPI 实时直连你自己的账号**。

> 本项目是**社区接入封装**，不是腾讯官方仓库。内含腾讯官方分发的 `ima-skill`（版权归腾讯），外加一份首次凭证配置向导 `ima-setup`。**每位用户使用自己账号领取的 Client ID / API Key，本仓库不内置、不共享任何凭证。**

## ✨ 能做什么

- 「列出我的 ima 知识库」
- 「在『产品文档库』里搜『排期』」 / 「打开《XX》看原文」
- 「把这个网页加到『行业研究』库：https://…」
- 「帮我把这份 PDF 上传到知识库」
- 「新建一篇笔记，记录：……」 / 「把这段追加到《XX》笔记」

数据实时来自 ima 云端，本机不存副本；写操作（上传/新建/追加）需要你明确指定目标后才会执行。

## 前置条件

- 已安装并运行**千问办公**桌面端。
- **Node.js ≥ 18**（`node -v` 查看；脚本用内置 fetch）。
- 一个 **ima 账号**，且能在 https://ima.qq.com/agent-interface 领取 Agent 接口凭证（以该页面实际显示为准）。

## 快速开始

### 1）安装（二选一）

**A. 作为插件（推荐）** — clone 本仓库，把整个目录放进千问办公自定义插件目录：
```bash
git clone https://github.com/jinqizhou938-a11y/ima-for-qwenwork.git
# macOS / Linux：
mkdir -p ~/.qwenworkcn/plugins-custom
cp -r ima-for-qwenwork ~/.qwenworkcn/plugins-custom/ima-knowledge-kit
# Windows（PowerShell）：
# New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.qwenworkcn\plugins-custom" | Out-Null
# Copy-Item -Recurse .\ima-for-qwenwork "$env:USERPROFILE\.qwenworkcn\plugins-custom\ima-knowledge-kit"
```
打开千问办公「插件」页应能看到 **ima 知识库套件**（没有就重启一次）。

**B. 只装技能** — 把 `skills/ima-skill/` 和 `skills/ima-setup/` 复制进 `~/.qwenworkcn/skills/` 对应目录。

### 2）配置你自己的凭证

在千问办公里说一句 **“配置 ima 接入”**，`ima-setup` 会带你：去 agent-interface 领 key → **在本地终端**写入 `~/.config/ima/` → 跑一条只读接口验证。

手动配（等价，注意**无换行**、值用单引号）：
```bash
mkdir -p ~/.config/ima
printf '%s' '你的ClientID' > ~/.config/ima/client_id
printf '%s' '你的APIKey'   > ~/.config/ima/api_key
```
Windows PowerShell：
```powershell
$d="$env:USERPROFILE\.config\ima"; New-Item -ItemType Directory -Force -Path $d|Out-Null
Set-Content -NoNewline -Path "$d\client_id" -Value '你的ClientID'
Set-Content -NoNewline -Path "$d\api_key"   -Value '你的APIKey'
```

### 3）开用

回到千问办公，用上面的例句直接说需求即可。

## 目录结构

```
ima-for-qwenwork/
├── .qwenwork-plugin/plugin.json     # 插件元数据
├── README.md
└── skills/
    ├── ima-setup/SKILL.md           # 首次凭证配置向导（本仓库新增）
    └── ima-skill/                    # 腾讯官方 skill
        ├── SKILL.md
        ├── ima_api.cjs               # 统一 HTTP 客户端（node≥18）
        ├── meta.json
        ├── knowledge-base/           # 知识库模块 + references + scripts
        └── notes/                    # 笔记模块 + references + scripts
```

## 工作原理（简述）

千问办公读 `ima-skill/SKILL.md` 判断该调哪个接口，然后用 Bash 跑 `node ima_api.cjs <接口路径> <JSON参数>`，脚本带上 `ima-openapi-clientid` / `ima-openapi-apikey` 两个请求头，POST 到 `https://ima.qq.com/...` 并返回 JSON。凭证读取优先级：调用参数 → 环境变量 `IMA_CLIENT_ID`/`IMA_OPENAPI_CLIENTID` → 文件 `~/.config/ima/{client_id,api_key}`。

## 常见问题

- **提示 `-200 需要更新`**：官方脚本内置每日版本检查，说明 ima-skill 有新版。请从官方获取最新包替换 `skills/ima-skill/`：下载 `https://app-dl.ima.qq.com/skills/ima-skills-<版本>.zip`。
- **鉴权失败（`20004`/`100002`/未找到凭证）**：多半是 key 复制不全、带了换行/空格，或路径不对；重新按"无换行 + 单引号"写入。
- **中文笔记乱码**：用新版 Node 环境、走脚本发请求即可规避 PowerShell 5.1 的编码坑。
- **视频链接 / `file://` 加不进**：这些不支持经接口添加，需回 ima 客户端手动加。

## 安全与隐私

- Client ID / API Key 是**个人账号钥匙**，能读**也能改/删**你的知识库与笔记。**不要粘贴进聊天、不要发给任何 AI/机器人**；一旦泄露立即在 ima 后台作废重生成。
- `~/.config/ima/` 不要放进网盘/同步盘；本仓库不会、也绝不接收任何人的 key。
- 群聊等共享场景遵循官方隐私规则：只展示笔记标题/摘要，不外泄正文。

## 来源与许可

- `skills/ima-skill/`（含 `ima_api.cjs`、各模块与脚本）**版权归腾讯（ima）**，由 ima 官方通过 `app-dl.ima.qq.com` 分发；本仓库仅做接入封装与使用引导。
- 公开再分发前，请自行确认 ima 官方对该 skill 的分发许可，并保留本来源声明。
- `ima-setup`、README 等本仓库原创内容按你在仓库设置的选择性许可使用；如未附 LICENSE 文件，默认仅作个人学习与注明来源分享。

---

如果这个项目帮到了你，欢迎给个 ⭐。Issue / PR 请说明 ima 版本与复现步骤。
