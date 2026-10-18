# ima 知识库 · 千问办公接入包

**一句话：让你在千问办公里用大白话，操作自己 ima 账号里的知识库和笔记。**

装好之后你直接说人话：

| 你说 | 它做 |
|---|---|
| 「我有哪些知识库？」 | 列出你 ima 里全部知识库 |
| 「在『产品文档库』里搜『排期』」 | 库内搜索，给原文位置 |
| 「把这个网页加到『行业研究』库：https://…」 | 网页存进知识库 |
| 「把这份 PDF 传进『产品库』」 | 上传文件并入知识库 |
| 「新建一篇笔记，记下：……」 | 创建笔记 |
| 「打开《XX》看全文」 | 取原文再分析 |

数据实时连 ima 官方接口，**本机不留副本**；只动你自己账号里的东西。

---

## 三步装好（约 5 分钟）

### 第 1 步 · 把技能文件夹放对位置

下载或克隆本仓库后，把 `skills/ima-skill` **整个文件夹**复制到：

- **Windows**：`C:\Users\你的用户名\.qwenworkcn\skills\ima-skill`
- **macOS / Linux**：`~/.qwenworkcn/skills/ima-skill`

放完检查一下层级——应该能直接看到文件：
`…\.qwenworkcn\skills\ima-skill\SKILL.md` ✅
`…\.qwenworkcn\skills\ima-skill\ima-skill\SKILL.md` ❌ 多套了一层

顺手删掉文件夹里 Mac 打包残留的 `.DS_Store`（Windows 用不上它）。
然后重启千问办公，技能列表里出现 `ima-skill` 就是生效了。

### 第 2 步 · 领一把**你自己的**钥匙

1. 打开 https://ima.qq.com/agent-interface ，用你自己的 ima 账号登录
2. 创建 / 查看 Agent 接口凭证，拿到 **Client ID** 和 **API Key**
3. 存到本地（两种方式选一种）：
   - **存文件**：`~/.config/ima/client_id` 和 `~/.config/ima/api_key`
     Windows 对应 `C:\Users\你的用户名\.config\ima\`，没有这两个文件就新建
   - **存环境变量**：`IMA_OPENAPI_CLIENTID`、`IMA_OPENAPI_APIKEY`
4. 粘贴时**不要带换行、不要包引号**，存完打开看一眼，末尾不能有空行

### 第 3 步 · 验证通没通

终端跑一条只读命令（Windows 用 PowerShell 的路径写法把 `~` 换成 `$env:USERPROFILE`）：

```bash
node ~/.qwenworkcn/skills/ima-skill/ima_api.cjs "openapi/wiki/v1/search_knowledge_base" '{"query":"","cursor":"","limit":20}'
```

看到这样的开头就算通了 —— 后面跟着你自己的知识库名字和篇数：

```json
{"code":0,"msg":"success","data":{"info_list":[{"kb_name":"…","content_count":"7"}]}}
```

> 前提：Node.js ≥ 18（终端里 `node -v` 看一眼，太旧去 nodejs.org 装新版）。

---

## 🔒 一条红线

这对 Client ID / API Key 就是你 ima 账号的钥匙，**能读、也能改和删**你所有知识库和笔记。

- 只发给 `ima.qq.com`，**不要**发给任何 AI、群聊、同学、截图；
- **不要**把 key 粘进对话框让 AI 帮你填 —— 自己在本机终端或记事本里写；
- 万一已经发出去：立刻去 ima 后台把该 Key 作废，重新生成一个，再按第 2 步重配；
- `~/.config/ima/` 不要放在网盘 / 同步盘 / Git 里。

---

## 装不上？对照这张表

| 现象 | 多半是 | 怎么办 |
|---|---|---|
| 技能列表里没有 `ima-skill` | 多套了一层目录，或没重启 | 确认 `…\skills\ima-skill\SKILL.md` 在，再重启一次 |
| `未找到凭证` / `code:20004` | 没配、路径不对、粘连了换行 | 回第 2 步，文件里只能有那一串字符 |
| `code:-200 需要更新` | 官方包升级了 | 换新版 `ima-skill` 覆盖旧目录 |
| 视频 / 本地网页加不进库 | 接口本身不支持 | 回 ima 客户端手动加 |
| 命令报 `node: command not found` | 没装 Node | 装 Node 18+ 后重开终端 |

---

## 进阶（看不懂可以跳过）

- **让它带你配**：把整个仓库放到 `~/.qwenworkcn/plugins-custom/ima-knowledge-kit`，插件页出现「ima 知识库套件」。之后在对话里说"配置 ima 接入"，它会检查官方包在不在（缺了就自动下载），再引导你走第 2、3 步。
- **升级官方包**：`bash skills/ima-install/scripts/install_ima_skill.sh`，从 ima 官方 zip 现取现装，旧版自动备份成 `ima-skill.bak.<时间戳>`，不删原文件。
- **想要离线可检索的副本**：另装 `ima-knowledge-bridge`，把知识库同步成本地 Markdown，提问时逐条标注来源、库里没有就直说。

## 它是怎么跑起来的

千问办公读 `ima-skill/SKILL.md` 的**意图决策表**，判断该走 `notes`（笔记读写）还是 `knowledge-base`（浏览 / 搜索 / 上传 / 取原文）；再执行 `node ima_api.cjs <接口路径> <JSON参数>`，脚本注入 `ima-openapi-clientid` / `ima-openapi-apikey` 请求头，POST 到 `https://ima.qq.com`，返回 `{code,msg,data}` —— `code:0` 取数，非 0 就把 `msg` 报给你。

查询类操作没有额外门槛；**只有上传文件**要多过一道门：预检文件 → 查重名 → `create_media` 换一张短期 COS 凭证 → 直传对象存储 → `add_knowledge` 挂进库。主 Key 全程不碰对象存储。

## 来源与许可

`ima-skill` 及其 `ima_api.cjs`、模块脚本版权归腾讯（ima），随官方版本更新（当前 1.1.10），官方下载入口 https://app-dl.ima.qq.com/skills/ 。
本仓库的 `ima-install`、`ima-setup` 与本文档是配套引导内容。使用前请遵守 ima 官方服务条款。
