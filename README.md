# Sidor_Character · SIDOR 人设卡（独立附属插件）

![DSH 插件](https://img.shields.io/badge/DeepSeek%20Harness-插件-4f86f7?style=flat-square&logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiIgdmlld0JveD0iMCAwIDE2IDE2Ij48cGF0aCBkPSJNNyAwLjggOC42IDUuNCAxMy4yIDcgOC42IDguNiA3IDEzLjIgNS40IDguNiAwLjggNyA1LjQgNS40IFoiIGZpbGw9IiNmZmZmZmYiLz48L3N2Zz4=)
![sidor-character](https://img.shields.io/badge/package-sidor--character-4f86f7?style=flat-square)
![cordis](https://img.shields.io/badge/cordis-plugin-7c6cf0?style=flat-square)
![静态持久化](https://img.shields.io/badge/形态-静态持久化-7c6cf0?style=flat-square)
![MIT](https://img.shields.io/badge/许可-MIT-2ea44f?style=flat-square)

![版本](https://img.shields.io/badge/版本-v0.2.2-4f86f7?style=flat-square)
![导入](https://img.shields.io/badge/导入-纯客户端解析-22c55e?style=flat-square)
![单预设制](https://img.shields.io/badge/预设-单预设制-8b5cf6?style=flat-square)

![功能①批量导入](https://img.shields.io/badge/①-批量导入人设卡-f59e0b?style=flat-square)
![功能②卡片管理](https://img.shields.io/badge/②-人设卡管理-38bdf8?style=flat-square)
![功能③会话内应用](https://img.shields.io/badge/③-应用到当前会话-34d399?style=flat-square)
![功能④预设持久化](https://img.shields.io/badge/④-安装为%20Agent%20预设-6366f1?style=flat-square)
![功能⑤格式教程](https://img.shields.io/badge/⑤-格式说明与模板-ec4899?style=flat-square)

**关键词**：`deepseek-harness` · `dsh` · `dsh-plugin` · `cordis` · `persona` · `人设卡` · `角色卡` · `agent 预设` · `settings.section` · `sidor`

DeepSeek Harness Web GUI 的 **SIDOR 人设卡**（独立分发仓库，附属插件）。
与主皮肤 [Sidor_UI](../Sidor_UI)、工具箱 [Sidor_box](../Sidor_box) 是**互相独立的插件**
——可单独安装，也可并存，互不干扰（官方插槽 `settings.section` 按 `order` 自动排序共存）。

当前版本：**v0.2.2** —— 批量导入人设卡 + 双通道应用（会话内即时 / Agent 预设持久化，单预设制）；
DSH 0.2.0 适配：网关斜杠端点 + `args` 信封（含旧版回退），**预设安装改为双形态自适应**
（0.2.0+ 声明式 profile 补丁行 / 0.1.5- 目录式）。

## 一键安装（dsh 端）

### 懒人版

把你的 dsh 打开，对它说：

```
安装一下这个人设卡插件：https://github.com/AKI2253/Sidor_Character
```

> 说明：dsh 助手会 `git clone` / 读取该仓库并自动完成安装。

### 本地路径版（仓库尚未发布 / 已在本地）

复制以下整段内容发给 dsh 助手：

```
【任务】请为 DSH（DeepSeek Harness Web GUI）安装 SIDOR 人设卡插件（sidor-character，静态持久化形态）。

【插件来源】
- 本地仓库路径：E:\DeepSeek Harness\Sidor_Character

【执行步骤】
1. 校验仓库完整性：确认 package.json、lib/client.js、lib/index.js、cordis.patch.yml、scripts/install.ps1 都存在；
2. 运行安装脚本（Windows PowerShell）：
   powershell -ExecutionPolicy Bypass -File "E:\DeepSeek Harness\Sidor_Character\scripts\install.ps1"
3. 校验安装结果：
   - %USERPROFILE%\.dsh\profiles\web\node_modules\sidor-character\ 存在，且 lib\client.js 非空；
   - %USERPROFILE%\.dsh\profiles\web\cordis.patch.yml 中已有 sidor-character 的 insert 条目
     （与 sidor-ui / sidor-box 等其他插件的条目并存，不得覆盖或删除其它条目）；
4. 若安装脚本报 Access denied / UnauthorizedAccess：如实向用户说明并请求批准权限后重试；
   或改用命令版：dsh plugin --profile web add "E:\DeepSeek Harness\Sidor_Character"；
5. 汇报结果，并提醒用户：重启 DSH，浏览器 Ctrl+Shift+R 硬刷新后生效。

【约束】
- 只写 %USERPROFILE%\.dsh\profiles\web 下的 package 目录与 cordis.patch.yml，不改其它文件；
- 禁止执行卸载（-Remove），除非用户另行要求；
- 若 cordis.patch.yml 已有 sidor-character 条目，视为已安装，只做覆盖拷贝，不重复追加。
```

### 命令版（需 pnpm）

```sh
cd <harness 目录>
dsh plugin --profile web add <Sidor_Character 仓库路径>
```

安装 = 复制包到 `%USERPROFILE%\.dsh\profiles\web\node_modules\sidor-character`
+ 在 profile 的 `cordis.patch.yml` 追加 `- insert: {id: sidor-character, name: sidor-character}`。
安装后**重启 DSH**，浏览器 `Ctrl+Shift+R` 硬刷新。

> 若此前装过动态形态（sidc-* 会话内插件），安装静态版并重启 DSH 后，动态插件随进程退出
> 自动消失，不会冲突；静态版与动态版的设置（localStorage）共用同一批 key，一次填写即可迁移。

## 功能

| # | 功能 | 说明 |
|---|---|---|
| ① | 批量导入人设卡 | 多选 / 拖拽导入 `.persona.md`（主格式）与酒馆角色卡 JSON / pack JSON；浏览器内解析，冲突支持覆盖/跳过/重命名 |
| ② | 人设卡管理 | 人设卡列表（名称/标签/简介/状态），应用 / 停用 / 删除 |
| ③ | 应用到当前会话 | 经官方 `/api/session/prompt` 向当前会话发送人设指令，立即生效、可随时换卡/停用（动态/静态形态通用） |
| ④ | 安装为 Agent 预设 | 人设 → 用户 agent 预设，新建会话时选用，持久生效。**自适应两代 DSH 预设形态**：0.2.0+ 声明式——以官方 `presets/standard.patch.yml` 的 plugins 列表为基底，把正文追加到 `persona.prefix`，再作为 `preset-<id>` 行写入 profile 补丁（重启 DSH 生效）；0.1.5- 目录式——写 `~/.dsh/.agent-presets/<id>/`。**单预设制**：安装新预设自动替换旧预设 |
| ⑤ | 格式说明与模板 | 分 tab 教程：`.persona.md` / 酒馆角色卡 / 批量打包 / AI 转换提示词，模板与示例一键复制 |

## 人设卡文件格式（`.persona.md`）

```markdown
---
format: sidor-persona
version: 1
id: scholar-senpai
name: 知性学姐
description: 博学温柔的学姐，用浅显的方式讲解知识
tags: [温柔, 教育, 中文]
apply: preset
---
（人设正文：即应用时发送、安装预设时追加到 dsh-persona `prefix` 的人设指令）
```

示例见 [`examples/知性学姐.persona.md`](examples/知性学姐.persona.md) 与
[`examples/Yuki傲娇妹妹.persona.md`](examples/Yuki傲娇妹妹.persona.md)；
格式规范与实现方案见 [`docs/PERSONA_DESIGN.md`](docs/PERSONA_DESIGN.md)。

## 静态形态说明

Sidor_Character 为**静态持久化插件**（install.ps1 安装到 profile，随 DSH 启动自动加载），
**无 host RPC 通道**。依赖宿主的能力（安装/卸载 Agent 预设、读写 `%USERPROFILE%\.dsh`）由
客户端在检测到 `host.call` 不可用后**自动降级为「agent 代执行」**——通过官方 `/api`
（0.1.5+ 为 `POST /api/session/prompt`，参数经 `args.request` 传递且 `requestId` 必填；
0.1.4- 为点号式 `session.prompt` 裸 payload；插件自动探测并回退）向 Agent 发出精确指令，
由 Agent 完成文件操作后汇报。**预设安装同样按 DSH 形态自适应**：0.2.0+ 以官方 `standard.patch.yml`
为基底、把 `preset-<id>` 声明行写入 profile 补丁（重启 DSH 生效）；0.1.5- 写 `.agent-presets\<id>\` 目录。
人设卡数据只存浏览器 localStorage（`sidor.character.prefs`），动态/静态共用。

**已验证的 DSH 版本**：`0.2.0-rc.2`（斜杠式端点 + args 信封 + `requestId`；声明式预设：profile 补丁 `preset-<id>` 行）、
`0.1.5`（同一网关信封；目录式预设 + `prefix` 字段）、`0.1.4` 及更早（点号式端点与 `text` 字段，走回退分支）。

## 开发

| 文件 | 说明 |
|---|---|
| `src/sidor-character-client.js` | Client 半源码（插件函数体，动态/静态双形态共用） |
| `scripts/client-wrapper.template.js` | ModuleLoader bundle 模板（闭包注入 React / styles / host / harness；host.call 一律 reject 触发静态降级） |
| `scripts/build-client.ps1` | 构建：源码内联 → `lib/client.js`（含 `node --check` 语法门禁） |
| `scripts/install.ps1` | 安装 / 卸载（UTF-8 安全读写 patch，可与其他插件并存） |
| `lib/client.js` | 构建产物（提交进仓库作为分发输出） |
| `lib/index.js` | Host 半空壳（静态形态无 host RPC） |
| `cordis.patch.yml` | bundle 补丁声明 |
| `docs/` | 设计方案 / 开发提示词 / 一键安装提示词 |

源码更新流程：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-client.ps1   # 重打 lib/client.js
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1        # 重装到 profile
# 重启 DSH + Ctrl+Shift+R
```

> 打包注意事项见 [Sidor_UI 打包文档](../Sidor_UI/docs/PACKAGING.md)（同一条构建管线）。

## 未来规划

人设卡按「先试后装」设计：会话内即时应用适合快速体验，Agent 预设适合长期固定风格。
后续候选：PNG 内嵌酒馆卡、pack 导出、会话-人设自动绑定、人设模板库。

## 许可

MIT。SIDOR 品牌标识归本项目所有。
