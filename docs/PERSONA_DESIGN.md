# Sidor_Character 人设卡 · 设计方案 v0.1

> 目标功能：批量导入人设卡文件，自由选择加载/更换人设，应用于 DeepSeek Harness
> (dsh) 的 agent 与用户交流风格。本文是需求落地前的设计文档（占位栏 → v1 的依据），
> 实现时按 [DEVELOPER_PROMPT.md](./DEVELOPER_PROMPT.md) 的分步模板执行。

---

## 1. 目标与范围

| 需求 | 方案要点 |
|---|---|
| 批量导入人设卡文件 | 浏览器多选/拖拽文件（`.persona.md` / 酒馆 JSON / pack JSON），零宿主依赖解析 |
| 自由选择加载/更换人设 | 人设卡列表一键「应用」；可随时换卡/停用 |
| 应用于 agent 与用户交流风格 | 双通道：**预设化（系统提示级，持久）** + **会话内即时指令（消息级，即时）** |

---

## 2. 关键机制调研（DSH 侧事实，设计依据）

### 2.1 DSH 原生人设机制：`@deepseek-ai/dsh-persona`

每个 agent 预设的 `agent.cordis.yml` 里都有一行人设。**DSH 0.1.5 起字段名为 `prefix`（必填），0.1.4 及更早为 `text`**——旧写法会导致预设挂载失败
（`invalid config: $.prefix`）。standard 预设原文（0.1.5）：

```yaml
- id: persona
  name: '@deepseek-ai/dsh-persona'
  config:
    suffix: Your working directory is {{cwd}}.
    prefix: >-
      You are a coding agent powered by the {{model}} model.
```

- `config.prefix` 即**系统提示级的人设文本**（渲染为 `deployment:persona-prefix` 段），直接决定 agent 与用户交流的风格；**必填**，缺失即整行挂载失败；
- `config.suffix`（可选，默认 `''`）渲染在第一方指引之后；**省略或留空会遮蔽部署级后缀**；
- `config.complete`（可选，默认 `false`）：`true` 时 `prefix` 直接作为完整系统提示词，抑制后缀与其余所有段；
- `config.includeRuntimeContext`（可选，默认 `true`）：`false` 时该人设作用域不注入动态 runtime-context；
- `{{model}}` / `{{cwd}}` 由 agent 自身路由/工作区解析，`{{…}}` 按注册表**严格插值**（未知变量报错，勿写自定义占位符）；
- 预设自带的人设会**遮蔽部署默认人设**。

→ **结论**：把人设卡正文追加到某预设的 `persona.prefix`，即从系统提示层面改变交流风格。
这是 DSH 的正统机制，能被官方界面（设置 → Agent 预设、新建会话选择器）管理与选择。

### 2.2 预设注册表服务：`ctx.agentPresets`

**0.1.5-（目录式）**：`list()` / `resolve(id)` 热发现；`copy(from, id, name)` 把现有预设整体复制为用户预设
（`~/.dsh/.agent-presets/<id>/`）；`read` / `remove`；`recompose(agentCtx, id)` 可把未产出内容的 agent 重链到另一预设。

**0.2.0+（声明式，破坏性变更）**：注册表远端只暴露 `list()` / `read(id)` / `select(agentId, id)`——**没有写入接口**。
预设由组合里的一行声明：

```yaml
- id: preset-<preset-id>
  name: '@deepseek-ai/dsh-agent-preset'
  config:
    id: <preset-id>        # 必填
    name / description / order   # 可选
    plugins: [ … ]         # 必填：该预设的完整插件行列表（不继承）
```

- 用户预设与 Web 编辑器改动都落在 **profile 补丁** `%USERPROFILE%\.dsh\profiles\<profile>\cordis.patch.yml`；
- 旧的 `~/.dsh/.agent-presets/` 目录**不再被扫描**；
- 官方发行预设 = `<DSH 安装目录>\packages\bundle\web-app\presets\{standard,cordis,minimal,ptc}.patch.yml`。
  详见 Sidor_UI [`docs/PLAN-DSH-0.1.5-COMPAT.md`](../../Sidor_UI/docs/PLAN-DSH-0.1.5-COMPAT.md) §6。

### 2.3 会话内指令通道：官方 `/api session.prompt`

与 Sidor_UI（插件管理）/ Sidor_box（agent 代执行）同一信封，**动态/静态形态通用**：

```js
sidorHostRpc('session.prompt', {
  sessionId: <当前会话 id>,
  mode: 'queue',
  content: [{ type: 'text', text: <指令文本> }],
})
```

### 2.4 双形态约束

- 静态形态**无 host RPC**：浏览器侧唯一宿主通道是 `/api` 白名单（`session.prompt` 等）；
  宿主级能力（写预设目录、调 `agentPresets`）只能走「agent 代执行」；
- 动态形态有 `harness.handle` + `host.call`：host 半可直接注入 `agentPresets` 完成
  预设安装/重链（增强路径，静态降级为 agent 代执行）。

---

## 3. 人设卡文件格式方案 v1

### 3.1 原生格式：`.persona.md`（推荐，主格式）

**Markdown + YAML front matter**，扩展名 `.persona.md`。front matter 只承载 UI 元数据，
**正文即人设指令**（应用时直接发送；安装预设时追加到 `persona.prefix`），不引入额外 DSL。

```markdown
---
format: sidor-persona      # 必填：格式标识
version: 1                 # 必填：格式版本
id: scholar-senpai         # 必填：全局唯一（^[a-z0-9-]+$），注册表键 + 预设目录名
name: 知性学姐             # 必填：显示名称
description: 博学温柔的学姐，用浅显的方式讲解知识   # 建议：列表页简介
tags: [温柔, 教育, 中文]   # 可选：筛选标签
author: AKI                # 可选：作者
cardVersion: 1.0.0         # 可选：人设自身版本
apply: preset              # 可选：默认应用方式 —— session(仅当前会话即时) | preset(安装为可复用预设,默认)
style: friendly            # 可选：formal / friendly / playful / terse / custom —— UI 徽标与生成应用指令
temperature: 0.7           # 可选：建议采样温度（仅展示提示，不强加）
---
<!-- 人设正文（Markdown）：发给 agent 的人设指令；安装预设时追加到 dsh-persona 的 prefix -->
你是「知性学姐」。与用户交流时：
- 语气温和、耐心，常用「我们一起来看」开头讲解；
- 讲知识先给结论，再用生活化的例子展开；
- 不主动结束话题，鼓励用户追问。
```

**front matter 语法子集**（自写极简解析器，约 30 行，不引第三方依赖）：
- 顶层标量：字符串 / 数字 / 布尔；
- 字符串数组（`tags`）；
- `#` 行注释；
- 不做嵌套对象/多行折叠（`>-` 不支持，正文一律放 front matter 之后）。

### 3.2 兼容导入（增强）

| 来源 | 处理 |
|---|---|
| SillyTavern/酒馆 Character Card（JSON） | 读 `{name, description, personality, scenario, first_mes, mes_example}`，拼装为人设正文模板，导入时标记 `source: tavern` |
| 酒馆 PNG 内嵌卡 | 解析 PNG `tEXt` 块 `chara` → `DecompressionStream('deflate')` → JSON（二期） |
| `.sidor-persona-pack.json` | 批量打包清单，见 3.3 |

### 3.3 批量载体

- **多文件选择**：`<input type="file" multiple accept=".persona.md,.md,.json">` —— 零宿主；
- **拖拽导入**：文件/文件夹（`webkitdirectory` 可选）拖入导入区；
- **打包清单** `.sidor-persona-pack.json`（分发/备份，单文件批量导入）：

```json
{
  "format": "sidor-persona-pack",
  "version": 1,
  "personas": [
    { "frontmatter": { "id": "a", "name": "A", "description": "..." }, "body": "人设正文…" }
  ]
}
```

### 3.4 校验规则

- `format`/`id`/`name` 必填；`id` 合法字符；正文非空；
- id 冲突时导入预览提供：**覆盖 / 跳过 / 重命名为新 id** 三种处理。

---

## 4. 实现方法

### 4.1 模块划分（全部客户端优先，静态形态可用）

| 模块 | 职责 |
|---|---|
| `sidCharaStore` | 注册表：`{ personas: {id→卡}, currentId }`；持久化 `localStorage('sidor.character.prefs')`；`Listeners/Notify/Subscribe` 四件套（与 Sidor_box 同模式） |
| `sidCharaParse(file)` | 按扩展名/内容识别格式（`.persona.md` / 酒馆 JSON / pack JSON）→ 解析 + 校验 → `{ok, card} | {ok:false, errors[]}` |
| `sidCharaApply(id, {mode})` | 应用通道 A / B（见 4.2 / 4.3）；带冷却与结果反馈 |
| `CharacterSettingsPage` | 人设卡列表 + 导入区 + 导入预览（冲突处理）+ 应用/停用/删除 |

### 4.2 应用通道 A：会话内即时（消息级，即时预览/快速切换）

```js
sidPromptAgent(
  '【SIDOR 人设卡】从现在起你以以下人设与用户交流，直至被要求更换：\n' + <人设正文>
)
```

- 经官方 `/api session.prompt`（queue），双形态通用；
- **换卡** = 再发一条新指令；**停用** = 发「恢复默认交流风格」指令；
- 适合「先试后装」；新会话需重新应用。

### 4.3 应用通道 B：预设化持久（系统提示级，推荐主通道）

把当前人设安装为**用户 agent 预设**。DSH 有过两代形态，插件按特征**自适应（A 优先、B 回退）**：

**A. 0.2.0+ 声明式**（特征：存在 `<DSH 安装目录>\packages\bundle\web-app\presets\standard.patch.yml`）

```yaml
# 追加到 %USERPROFILE%\.dsh\profiles\<profile>\cordis.patch.yml
- insert:
    - id: preset-<card.id>
      name: '@deepseek-ai/dsh-agent-preset'
      config:
        id: <card.id>
        name: SIDOR 人设 · <card.name>
        description: <card.description>
        order: 50
        plugins: [ …standard 的完整 plugins 列表（persona 行已换成本人设）… ]
```

- 预设**不继承**：必须整份复制 `standard.patch.yml` 的 `config.plugins`；
- `persona.prefix` 合成规则：`<standard 基底 prefix> + "\n\n【人设卡】" + <人设正文>`（`suffix` 保持不变）；
- 改动 profile 补丁前先备份，且**不得改动/删除其他插件的条目**；**重启 DSH** 后出现在「设置 → Agent 预设」。

**B. 0.1.5- 目录式**

```
~/.dsh/.agent-presets/<card.id>/
├── agent.cordis.yml   # 复制 standard 基底 + 把正文追加到 persona 行的 prefix
└── preset.yml         # name: SIDOR 人设 · <card.name>；description: <card.description>
```

- 字段名 `prefix`（0.1.5+；0.1.4- 为 `text`），`suffix` 保持不变。

**执行者**：

- **静态形态（主路径）**：客户端经官方 `/api/session/prompt` 委托当前 agent 执行（越界写文件弹授权）——
  下发的指令**同时给出 A/B 两套步骤与落点**，由 agent 按实际环境择一执行并回报采用的形态；
- **动态形态（增强，当前未使用）**：host 半可 `inject: ['agentPresets']` 并用 `harness.handle` 暴露
  `sidor-chara/preset-*`，但 0.2.0 起注册表无写入接口，该路径只在 0.1.5- 环境有效。

**卸载**：A 形态删除 profile 补丁中 `preset-<id>` 的 insert 块；B 形态删除对应目录。
同一时间只保留一个人设预设（安装时自动移除其他已装预设）。

### 4.4 设置页 UI 布局（占位栏 → v1）

```
人设卡（id sidor-character, order 27, 图标 ICON_CHARA）
├── 头部：标题 + 「批量导入」按钮 + 拖拽导入区
├── 导入预览：解析结果列表（名称/标签/简介/格式来源/冲突处理选择）
├── 人设卡列表：
│   每张卡 = 图标 + 名称 + 标签 + 简介 + 状态(当前启用/未启用)
│           + [应用到当前会话] [安装为预设] [停用] [删除]
└── 状态行：当前生效人设 + 应用通道说明
```

### 4.5 双形态一致性

- 数据只存 `localStorage('sidor.character.prefs')`——动态预览与静态安装共用，重启不丢；
- 所有 `host.call` try/catch，静态自动降级 agent 代执行；
- 文件解析全部浏览器完成，导入不依赖宿主。

---

## 5. 边界与风险（如实说明）

| 项 | 说明 |
|---|---|
| 通道 A 强度 | 消息级指令，模型遵循度非 100%；新会话需重新应用（二期可加「会话打开自动应用」绑定） |
| 通道 B 体积 | 每张卡 = 一份完整预设（A 形态为 profile 补丁里的一条 `preset-<id>` 行，内含整份 plugins 列表；B 形态为整份预设目录），体积较大；换卡需新会话（0.1.5 的 `recompose` 仅限未产出内容的会话） |
| 写 `~/.dsh` 授权 | 安装预设会写入 `%USERPROFILE%\.dsh`——A 形态改 `profiles\<profile>\cordis.patch.yml`（须先备份、不得动其他插件条目），B 形态写 `.agent-presets\<id>\`；DSH 会弹授权（与安装脚本同性质），须如实提示用户 |
| 0.2.0 重启要求 | A 形态的预设行在 DSH 启动时载入，安装后**必须重启 DSH** 才会出现在「设置 → Agent 预设」 |
| token 成本 | 通道 A 的指令与安装指令进入会话历史，占用 token（与 Sidor_box agent 代执行同性质） |

---

## 6. 分期实施建议

| 阶段 | 内容 | 状态 |
|---|---|---|
| v0.1 | 占位栏：分区 + 图标 + 占位卡片 | ✅ 已实现 |
| v1 | 格式解析（`.persona.md`）+ 批量导入（多选/拖拽）+ 注册表 store + 人设卡列表 + 通道 A（会话内即时应用/换卡/停用） | ✅ 已实现 |
| v2 | 通道 B（预设化：动态 host 半 RPC + 静态 agent 代执行）+ 酒馆 JSON 兼容导入 | ✅ 已实现 |
| v3（可选） | PNG 内嵌卡、pack 打包导出、会话-人设自动绑定 | 待定 |

当前版本：**v0.2.0**（v1 + v2 落地）。实现与文档如有出入，以
`src/sidor-character-client.js` 为准并同步更新本文档。
