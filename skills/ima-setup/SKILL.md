---
name: ima-setup
version: 1.0.0
description: First-time setup for the ima official API — guide the user to obtain their OWN Client ID / API Key, configure them locally (never paste keys into chat), and verify the connection works.
name_en: ima Setup
name_zh: ima 接入配置向导
description_en: Guide obtaining and locally configuring the user's own ima credentials, then verify.
description_zh: 带用户领取并「在本地」配置属于自己的 ima Client ID / API Key（严禁把 key 发到对话里），然后跑一条验证接口确认打通。
user-invocable: true
argument-hint: 首次配置 / 换 key / 配置失败排查
argument-hint-en: first-time setup / rotate key / troubleshooting
argument-hint-zh: 首次配置、更换 key 或排查配置失败
---

# ima 接入配置向导（ima-setup）

这个技能只做一件事：**让当前这台机器上、当前这个用户，把自己账号的 ima 凭证配好并验证。** 别人用本套件时，第一件事就是触发它。

## 🔒 第一原则（必须对用户讲明）

- Client ID / API Key 是**绑定个人 ima 账号**的私密凭证，相当于登录钥匙，拥有读取**和修改/删除**其知识库与笔记的权限。
- **不要让用户把 key 粘贴进对话、发给我或任何模型/机器人。** 写入动作应由用户在**自己的终端**执行。
- 如果用户已经把 key 贴到了聊天里：**提醒该 key 已暴露，建议去 ima 后台作废并重新生成**，再按下方步骤本地重配。
- 本套件绝不内置任何人的 key，也绝不会把 key 发送到 ima 官方（`ima.qq.com`）以外的地址。上传文件用的是 ima 临时下发的 COS 短期凭证，主 key 不出现在那里。

## Step 1 · 检测现状

判断这台机器是否已配好（任一满足即视为已配置）：
- 环境变量 `IMA_OPENAPI_CLIENTID` 与 `IMA_OPENAPI_APIKEY`（或 `IMA_CLIENT_ID`/`IMA_API_KEY`）；
- 或文件 `~/.config/ima/client_id` 与 `~/.config/ima/api_key`（Windows 为 `%USERPROFILE%\.config\ima\...`）。

已配置 → 跳到 Step 4 验证。未配置 → 继续。

## Step 2 · 领取用户自己的 key

引导用户（用他自己的浏览器和账号）：

1. 打开 https://ima.qq.com/agent-interface
2. 用**自己的** ima 账号登录
3. 按页面提示创建/查看 Agent 接口凭证，拿到 **Client ID** 和 **API Key**
4. 把这两个值**留在本地**，不要发给别人、不要发到聊天里

> 能否领取接口凭证以用户账号在官方页面的实际显示为准；页面若提示需要特定权限/未开放，如实转达，不要臆测。

## Step 3 · 在本地写入凭证（用户自己在终端执行）

给用户对应系统的命令，让 TA 替换成自己的值后执行。**关键是本地执行，AI 不经手明文。**

**macOS / Linux（bash）：**
```bash
mkdir -p ~/.config/ima
printf '%s' '把ClientID粘这里' > ~/.config/ima/client_id
printf '%s' '把APIKey粘这里'   > ~/.config/ima/api_key
```

**Windows（PowerShell）：**
```powershell
$d = "$env:USERPROFILE\.config\ima"; New-Item -ItemType Directory -Force -Path $d | Out-Null
Set-Content -NoNewline -Path "$d\client_id" -Value '把ClientID粘这里'
Set-Content -NoNewline -Path "$d\api_key"   -Value '把APIKey粘这里'
```

**Windows（Git Bash）：** 用 macOS/Linux 写法，路径 `~/.config/ima/`。

也可走环境变量（不落文件，需持久化到 shell 配置）：
```bash
export IMA_OPENAPI_CLIENTID="你的ClientID"
export IMA_OPENAPI_APIKEY="你的APIKey"
```

要点：
- 用**无换行**写入（`printf '%s'` / `Set-Content -NoNewline`），尾部换行会导致鉴权失败。
- API Key 常含 `+ / =` 等字符，用**单引号**包裹，别被 shell 展开。
- `~/.config/ima/` 放在**不被网盘/同步盘同步**的位置，文件权限收紧。

若用户坚持让 AI 代写（已把值交给 agent）：可代为写入，但**先给出泄露提醒**，且写完后不在对话回显完整值。

## Step 4 · 验证打通

在 `ima-skill` 目录跑一条只读列表即可证明鉴权与网络都 OK：

先定位 `ima_api.cjs` 的实际安装位置（两种装法路径不同，用存在的那个）：

```bash
# 自动挑一个存在的脚本目录（Git Bash / macOS / Linux）
for D in "$HOME/.qwenworkcn/plugins-custom/ima-knowledge-kit/skills/ima-skill" \
         "$HOME/.qwenworkcn/skills/ima-skill"; do
  [ -f "$D/ima_api.cjs" ] && break
done
node "$D/ima_api.cjs" "openapi/wiki/v1/search_knowledge_base" '{"query":"","cursor":"","limit":20}'
```

Windows PowerShell 则对应 `%USERPROFILE%\.qwenworkcn\plugins-custom\ima-knowledge-kit\skills\ima-skill\ima_api.cjs`（或 `...\skills\ima-skill\ima_api.cjs`）。

- 返回 `"code":0` 且能看到知识库名称 → ✅ 配好了，可正常使用 `ima-skill`。
- 返回 `20004`/`100002` 或 `-100 未找到凭证` → key 写错/复制不全/含多余换行/路径不对 → 回 Step 3 检查。
- 网络类错误 → 检查网络与 `ima.qq.com` 可达后重试。

## 更换 / 删除凭证

- 更换：重新领取，覆盖写入 Step 3 的两个文件（或改环境变量）。
- 删除：请用户自行在本地移除 `~/.config/ima/client_id`、`api_key`（本向导不用 shell 永久删除用户文件）。

## 连接器

不需要 MCP / 外部连接器；本技能只负责在本机配好并验证 ima 官方接口的个人凭证。
