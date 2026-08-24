# Sidor_Character 人设卡 · 功能开发代码提示词

> 用途：当你要为 Sidor_Character 添加人设卡功能时，把本文件作为开发提示词交给
> 编程 Agent（或自己作为开发备忘录）。它描述本插件的架构约束、代码模式与
> 必须遵守的静态形态降级规则，避免重复踩坑。
>
> 当前阶段：**v0.2.0（v1+v2 已落地）**。设置页「人设卡」分区已实现：批量导入
> （`.persona.md` 主格式 + 酒馆 JSON / pack JSON 兼容）、人设卡列表、通道 A
> （会话内即时应用）与通道 B（Agent 预设持久化）。需求补充后在本分区内继续扩展。

## 一、项目定位与形态

- Sidor_Character 是 **DeepSeek Harness Web GUI 的静态持久化插件**（独立附属插件，
  与主皮肤 sidor-ui、工具箱 sidor-box 互相独立、可并存）。
- 源码是**「动态 ↔ 静态」双形态共用的插件函数体**（单一事实源）：
  - **动态形态**：把 `src/sidor-character-client.js` 的内容作为 `cordis_define`
    的 `code.client` 运行（动态 runner 的闭包注入面与本仓库 wrapper 模板一致，
    同一份源码无需改动即可运行）。
  - **静态形态**：`scripts/build-client.ps1` 把源码内联进
    `scripts/client-wrapper.template.js` 生成 `lib/client.js`（ModuleLoader bundle），
    经 `scripts/install.ps1` 装入 profile 后随 DSH 启动自动加载。
- **静态形态 = 无 host RPC 通道**：`host.call(...)` 在静态 wrapper 中**一律
  reject**，因此客户端所有 `try { await host.call(...) } catch (e) { /* 静态降级 */ }`
  分支是唯一且预期的宿主交互方式。
- 构建管线：编辑 `src/sidor-character-client.js` → `powershell -ExecutionPolicy Bypass
  -File .\scripts\build-client.ps1`（生成 `lib/client.js`，含语法门禁）→
  `.\scripts\install.ps1` 重装到 profile → **重启 DSH + Ctrl+Shift+R**。
- 产物必须提交：`lib/client.js` 是分发输出（.gitignore 明确不禁用）。

## 二、源码结构约定（src/sidor-character-client.js）

源码是**插件函数体**，形如：

```js
return {
  inject: ['timer'],          // 依赖声明（build 脚本会提取到 bundle 顶层）
  apply(ctx) {
    const slots = ctx.get('slots')
    if (slots === undefined) return
    // ... 功能实现
  },
}
```

- 形参注入面（由 wrapper / 动态 runner 提供，勿自行声明）：
  `React, console, styles, host, harness`。另有浏览器全局 `window / document /
  fetch / setTimeout / AbortController` 可用（动态闭包会遮蔽裸 `fetch`，统一用
  `window.fetch`）。
- **禁止**：`import/require/TS/JSX`、`new Function/eval`、直接读写
  `process/Buffer`（静态形态不存在）。
- 生命周期：所有定时器 / observer / 事件监听必须用 `ctx.effect(() => { ...; return () => cleanup })`
  包裹，或用 `ctx.interval / ctx.timeout`（其返回值就是 disposer）。`slots.inject` 的注册
  由 Cordis 管理，无需手动清理。

## 三、在人设卡分区新增功能的分步模板

1. **图标**：在文件顶部图标区新增 `ICON_XXX`（16/22 viewBox、stroke=currentColor、
   stroke-width 1.3，风格与官方图标一致）。
2. **store**：新增 `const sidXxx = { enabled, ... }` + `sidXxxListeners/Notify/Subscribe/Toggle`
   （或所需状态四件套）；用户设置写入统一偏好 `sidCharaSave()`（key 见第四节），初始化用
   `sidCharaGet('xxxEnabled', true)` 恢复。
3. **设置页卡片**：在 `CharacterSettingsPage` 中追加 `.sid-chara-card`（小功能）或
   全宽大卡片（`grid-column: 1 / -1`）。行内控件复用 `.sid-chara-card-row / -label /
   -btn / .sid-toggle / .sid-toolbox-input` 一族样式（与 SIDOR 视觉语言一致）。
4. **宿主能力（可选）**：若功能需要读 DSH 文件/环境变量/网络，优先在客户端完成
   （浏览器 `window.fetch` + localStorage）；无法客户端完成的，用
   `sidPromptAgent('【SIDOR 人设卡】...')` 向 agent 发指令（**必须显式触发或加冷却**，
   勿在自动检查里无脑发消息）——参考 Sidor_box 的 `sidPromptAgent` 实现
   （经官方 `/api` session.prompt queue 发送）。
5. **持久化**：任何用户设置都写入 localStorage（键见第四节），重启后恢复。
6. **样式**：新增 CSS 追加到 `styles.insert(\`...\`)` 模板字符串；**禁止在 CSS
   模板里出现反引号或 `${`**（会破坏模板）；颜色只用 `--dsw-alias-*` / `--dsw-specific-*`
   主题变量，不写死色值；亮暗主题都必须可读（按钮文字色注意对比度）。
7. **构建**：改完必须重跑 `build-client.ps1`（inject 变更会体现在构建输出中），
   再 `install.ps1` 重装；`lib/client.js` 与源码同步提交。

## 四、localStorage 键约定（与动态形态共用）

| 键 | 内容 |
|---|---|
| `sidor.character.prefs` | 全部用户设置：`{ personas: {id→人设卡}, currentId, enabled }`。人设卡字段：`id / name / description / tags[] / style / apply / author / source / body / installed` |

新增设置统一并入 `sidor.character.prefs`（统一读写函数 `sidCharaSave / 初始化加载`）。

## 五、静态形态降级规则（重点）

- 所有 `host.call` 必须包在 try/catch；catch 分支写清楚「静态形态：由 agent 代执行」。
- **agent 指令冷却**：显式点击才发；自动检查只更新状态文案，**不向 agent 发消息**。
- **浏览器 fetch 超时**：所有网络请求用超时包装（AbortController + race 双保险），
  禁止裸 `fetch` 无超时。
- **空结果诊断**：host 返回 ok 但数据为空时，状态行要提示可能原因，并给出替代路径
  （agent 代查 / 手动输入）。
- 动态形态与静态形态的 localStorage 键完全一致——动态预览时写入的数据，静态安装后
  重启 DSH 依然保留。

## 六、常见坑

- `ctx.timeout/ctx.interval` 在静态 wrapper 有 polyfill（浏览器 setTimeout/setInterval），
  但**依赖声明必须写 `inject: ['timer']`**（build 脚本从源码提取到 bundle 顶层，
  否则 Cordis 不装配 timer）。
- CSS 模板字符串内嵌反引号或 `${` 会导致构建产物语法破坏（node --check 会拦截）。
- React 组件里忘写 key 会在列表渲染时警告；列表项 key 用稳定唯一值。
- 交互元素需 `cursor: pointer` + 键盘路径（Enter），保持可访问性。
- 状态字段更新后必须 `sidXxxNotify()` 驱动 UI，否则页面不刷新。
- 修改源码后务必重新构建 + 重装 + 重启 DSH，`lib/client.js` 必须与源码同步提交。
- 打包注意点与报错速查见 [Sidor_UI 打包文档](../Sidor_UI/docs/PACKAGING.md)
  （同一条构建管线）。

## 七、当前状态（v0.2.0）

- [x] 项目骨架（package.json / cordis.patch.yml / scripts / lib）
- [x] 设置页「人设卡」分区（`settings.section`，id `sidor-character`，order 27）
- [x] 设置导航 SVG 图标替换（官方齿轮 → 人设卡图标，全局 MutationObserver 即时替换）
- [x] v1：格式解析（`.persona.md` front matter + 正文）+ 批量导入（多选/拖拽/冲突处理）+ 注册表 store + 人设卡列表 + 通道 A（会话内即时应用/换卡/停用）
- [x] v2：通道 B 预设化（动态 host 半 `agentPresets` RPC + 静态 agent 代执行）+ 酒馆 JSON / pack JSON 兼容导入
- [ ] 后续扩展（需求补充后）：PNG 内嵌卡、pack 导出、会话-人设自动绑定等
