# README 书写规范（SIDOR 附属插件）

> 用途：新建 / 更新 SIDOR 系列插件仓库的 README 时，直接按本规范书写。
> 本文件本身即规范样例——`Sidor_Character/README.md` 即按此规范生成；
> 家族参考：`Sidor_box/README.md`、`Sidor_UI/README.md`。
>
> 一句话原则：**README = 仓库门面（徽章）+ 一键安装入口（dsh 指令）+ 搜索标签载体（关键词/topics）+ 维护文档（功能/开发/许可）**。

---

## 一、整体结构（章节顺序固定）

```
1. 标题
2. 徽章行（身份 → 版本与形态 → 功能①-⑤…）
3. 关键词行
4. 定位简介（段落）
5. 当前版本（一行）
6. 一键安装（dsh 端）
7. 功能表
8.（可选）核心文件格式 / 用法说明
9. 静态形态说明
10. 开发（文件表 + 源码更新流程）
11. 未来规划
12. 许可
```

---

## 二、各章节写法

### 1. 标题

```
# <插件名> · SIDOR <中文名>（独立附属插件）
```

例：`# Sidor_Character · SIDOR 人设卡（独立附属插件）`

### 2. 徽章行

三行徽章，语义分组：

| 行 | 内容 | 用途 |
|---|---|---|
| 行① 身份 | DSH 插件 / package / cordis-plugin / 形态 / 许可 | 一眼识别插件属性 |
| 行② 版本与形态 | 版本 / 关键特性（导入、单预设制等） | 当前状态 |
| 行③ 功能 | 功能①-⑤… 各一个徽章 | 功能清单速览 |

徽章用 shields.io（flat-square），颜色约定与模板见 **§四**。

### 3. 关键词行

紧接徽章后一行，供 GitHub 搜索与快速定位：

```
**关键词**：`deepseek-harness` · `dsh` · `dsh-plugin` · `cordis` · `persona` · `人设卡` · `角色卡` · `agent 预设` · `settings.section` · `sidor`
```

必含：`deepseek-harness`、`dsh`、`dsh-plugin`、`cordis`、`sidor` + 本插件功能关键词。

### 4. 定位简介

固定句式（段落）：

```
DeepSeek Harness Web GUI 的 **SIDOR <中文名>**（独立分发仓库，附属插件）。
与主皮肤 [Sidor_UI](../Sidor_UI)、工具箱 [Sidor_box](../Sidor_box) 是**互相独立的插件**
——可单独安装，也可并存，互不干扰（官方插槽 `settings.section` 按 `order` 自动排序共存）。
```

- 家族仓库一律用**相对链接** `../Sidor_UI`、`../Sidor_box`；
- 介绍本插件一句话能力（一句话说清它解决什么）。

### 5. 当前版本

```
当前版本：**vX.Y.Z** —— <一句话能力摘要> 已落地。
```

版本号必须与 `package.json` 的 `version` 一致。

### 6. 一键安装（dsh 端）— 三小节

#### 6.1 懒人版（仓库已发布 GitHub）

```
把你的 dsh 打开，对它说：

安装一下<描述>插件：https://github.com/<owner>/<repo>
```

#### 6.2 本地路径版（仓库未发布 / 已在本地）

给出一整段可直接复制发给 dsh 助手的提示词，模板见 **§五**。必须包含：
插件来源路径、校验文件清单、install.ps1 命令、安装结果校验（node_modules + cordis.patch.yml 条目）、
权限失败降级命令（`dsh plugin --profile web add …`）、约束（只写 profile、禁止卸载、重复安装跳过）。

#### 6.3 命令版（需 pnpm）

```
cd <harness 目录>
dsh plugin --profile web add <仓库路径>
```

之后固定附：安装 = 复制包 + patch 追加 insert 条目；重启 DSH + Ctrl+Shift+R；动态版消失不冲突说明。

### 7. 功能表

| # | 功能 | 说明 |
|---|---|---|
| ① | … | … |

- 一行一个功能，说明里写清「机制 + 效果 + 形态通用性」；
- 功能徽章（行③）与功能表条目一一对应。

### 8.（可选）核心文件格式 / 用法说明

如插件定义了文件格式（人设卡 `.persona.md`），用代码块给出最小示例 + 指向 `docs/` 的设计文档与 `examples/` 示例。

### 9. 静态形态说明

固定要点（段落）：
- 静态持久化插件（install.ps1 → profile，随 DSH 启动加载）；
- **无 host RPC 通道** → 依赖宿主的能力自动降级为「agent 代执行」（官方 `/api session.prompt`）；
- 数据只存浏览器 localStorage（给出键名），动态/静态共用。

### 10. 开发

文件表：`src/*`、`scripts/build-client.ps1`、`scripts/install.ps1`、`scripts/client-wrapper.template.js`、
`lib/client.js`（构建产物需提交）、`lib/index.js`（Host 空壳）、`cordis.patch.yml`、`docs/`。

源码更新流程（固定代码块）：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-client.ps1   # 重打 lib/client.js
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1        # 重装到 profile
# 重启 DSH + Ctrl+Shift+R
```

附一行：打包注意事项见 [Sidor_UI 打包文档](../Sidor_UI/docs/PACKAGING.md)（同一条构建管线）。

### 11. 未来规划

一两段说明设计取向 + 后续候选功能列表。

### 12. 许可

```
MIT。SIDOR 品牌标识归本项目所有。
```

仓库根目录必须存在 `LICENSE`（MIT）文件。

---

## 三、硬性规则

1. **不要求附图**：默认不设「效果预览」章节。若仓库有 `preview/` 截图资产，可用
   `[![说明](preview/xxx.png)](preview/xxx.png)` 相对链接引用；**禁止外链图片、禁止空挂图片章节**。
2. **标签三层一致**：README 关键词行 ⇄ `package.json` `keywords` ⇄ GitHub topics，保持同一组词。
3. **版本同步**：README「当前版本」= `package.json` `version` = 徽章版本。
4. **家族相对链接**：`../Sidor_UI`、`../Sidor_box`，不写死绝对路径。
5. **中文正文 + 英文命令**：说明文字中文；命令/代码块用英文。
6. **MIT 声明**：README / package.json / LICENSE 三处一致。
7. **一键安装提示词完整**：本地路径版必须含校验、授权降级、约束三要素（见 §五）。

---

## 四、徽章模板库（复制即用）

身份徽章行：

```markdown
![DSH 插件](https://img.shields.io/badge/DeepSeek%20Harness-插件-4f86f7?style=flat-square&logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiIgdmlld0JveD0iMCAwIDE2IDE2Ij48cGF0aCBkPSJNNyAwLjggOC42IDUuNCAxMy4yIDcgOC42IDguNiA3IDEzLjIgNS40IDguNiAwLjggNyA1LjQgNS40IFoiIGZpbGw9IiNmZmZmZmYiLz48L3N2Zz4=)
![<package-name>](https://img.shields.io/badge/package-<package--name>-4f86f7?style=flat-square)
![cordis](https://img.shields.io/badge/cordis-plugin-7c6cf0?style=flat-square)
![静态持久化](https://img.shields.io/badge/形态-静态持久化-7c6cf0?style=flat-square)
![MIT](https://img.shields.io/badge/许可-MIT-2ea44f?style=flat-square)
```

版本与形态徽章行：

```markdown
![版本](https://img.shields.io/badge/版本-v0.2.0-4f86f7?style=flat-square)
![导入](https://img.shields.io/badge/导入-纯客户端解析-22c55e?style=flat-square)
```

功能徽章行（颜色按序）：

```markdown
![功能①](https://img.shields.io/badge/①-<功能名>-f59e0b?style=flat-square)
![功能②](https://img.shields.io/badge/②-<功能名>-38bdf8?style=flat-square)
![功能③](https://img.shields.io/badge/③-<功能名>-34d399?style=flat-square)
![功能④](https://img.shields.io/badge/④-<功能名>-6366f1?style=flat-square)
![功能⑤](https://img.shields.io/badge/⑤-<功能名>-ec4899?style=flat-square)
```

（多于 5 个功能可复用 ①-⑥ 配色：`ef4444` 用于警示类。）

---

## 五、一键安装提示词模板（本地路径版，复制即用）

```
【任务】请为 DSH（DeepSeek Harness Web GUI）安装 <中文名> 插件（<package-name>，静态持久化形态）。

【插件来源】
- 本地仓库路径：<仓库绝对路径>

【执行步骤】
1. 校验仓库完整性：确认以下文件都存在——
   package.json、lib/client.js、lib/index.js、cordis.patch.yml、scripts/install.ps1。
2. 运行安装脚本（Windows PowerShell）：
   powershell -ExecutionPolicy Bypass -File "<仓库绝对路径>\scripts\install.ps1"
3. 校验安装结果：
   - %USERPROFILE%\.dsh\profiles\web\node_modules\<package-name>\ 存在，且 lib\client.js 非空；
   - %USERPROFILE%\.dsh\profiles\web\cordis.patch.yml 中已有 <package-name> 的 insert 条目
     （与 sidor-ui / sidor-box 等其他插件的条目并存，不得覆盖或删除其它条目）。
4. 若安装脚本报 Access denied / UnauthorizedAccess（写 %USERPROFILE% 需权限）：
   如实向用户说明并请求批准权限后重试；或改用命令版：
   dsh plugin --profile web add "<仓库绝对路径>"
5. 汇报结果，并提醒用户：重启 DSH，浏览器 Ctrl+Shift+R 硬刷新后生效。

【约束】
- 只写 %USERPROFILE%\.dsh\profiles\web 下的 package 目录与 cordis.patch.yml，不改其它文件；
- 禁止执行卸载（-Remove），除非用户另行要求；
- 若 cordis.patch.yml 已有 <package-name> 条目，视为已安装，只做覆盖拷贝，不重复追加。
```

同款独立文件可放 `docs/AGENT_INSTALL_PROMPT.md`（与 Sidor_box 家族结构一致）。

---

## 六、标签规范（三层一致）

| 层 | 位置 | 内容要求 |
|---|---|---|
| ① README | 关键词行 | 反引号包裹、`·` 分隔，必含家族词 + 功能词 |
| ② package.json | `keywords` | 英文小写词，含 `deepseek-harness` `dsh` `dsh-plugin` `cordis` `persona` `character-card` `agent-presets` 等 |
| ③ GitHub topics | `gh repo edit <repo> --add-topic <词>` | 与 ①② 同一组词，逐个添加 |

---

## 七、发布前检查清单

- [ ] 标题 / 徽章 / 关键词行齐全，徽章颜色按规范
- [ ] 「当前版本」与 `package.json` 一致
- [ ] 一键安装三小节齐全（懒人版 / 本地路径版含校验与约束 / 命令版）
- [ ] 功能徽章与功能表条目一一对应
- [ ] 无外链图片；无空挂的「效果预览」章节
- [ ] `LICENSE`（MIT）存在且与 README/package.json 声明一致
- [ ] `lib/client.js` 为最新构建产物（`node --check` 通过）
- [ ] GitHub topics 已打；`package.json` keywords 已更新
- [ ] 家族相对链接正确（`../Sidor_UI`、`../Sidor_box`）
