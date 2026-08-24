# Sidor_Character · 交给 Agent 的一键安装提示词

> 直接把下方代码块复制给你的 dsh 助手（Agent），它就会自动完成安装。
> 仓库尚未发布到 GitHub 时用「本地路径版」；发布后可用「一句话懒人版」。

## 一句话懒人版（仓库发布到 GitHub 后可用）

```
安装一下这个人设卡插件：https://github.com/AKI2253/Sidor_Character
```

> Agent 会 `git clone` / 读取该仓库并自动执行安装步骤（见下），安装后提醒重启 DSH。

## 本地路径版（现在可用，无需 GitHub）

复制以下整段内容发给 Agent：

```
【任务】请为 DSH（DeepSeek Harness Web GUI）安装 SIDOR 人设卡插件（sidor-character，静态持久化形态）。

【插件来源】
- 本地仓库路径：E:\DeepSeek Harness\Sidor_Character

【执行步骤】
1. 校验仓库完整性：确认以下文件都存在——
   package.json、lib/client.js、lib/index.js、cordis.patch.yml、scripts/install.ps1。
2. 运行安装脚本（Windows PowerShell）：
   powershell -ExecutionPolicy Bypass -File "E:\DeepSeek Harness\Sidor_Character\scripts\install.ps1"
3. 校验安装结果：
   - %USERPROFILE%\.dsh\profiles\web\node_modules\sidor-character\ 存在，且 lib\client.js 非空；
   - %USERPROFILE%\.dsh\profiles\web\cordis.patch.yml 中已有 sidor-character 的 insert 条目
     （与 sidor-ui / sidor-box 等其他插件的条目并存，不得覆盖或删除其它条目）。
4. 若安装脚本报 Access denied / UnauthorizedAccess（写 %USERPROFILE% 需权限）：
   如实向用户说明并请求批准权限后重试；或改用命令版：
   dsh plugin --profile web add "E:\DeepSeek Harness\Sidor_Character"
5. 汇报结果，并提醒用户：重启 DSH，浏览器 Ctrl+Shift+R 硬刷新后生效。

【约束】
- 只写 %USERPROFILE%\.dsh\profiles\web 下的 package 目录与 cordis.patch.yml，不改其它文件；
- 禁止执行卸载（-Remove），除非用户另行要求；
- 若 cordis.patch.yml 已有 sidor-character 条目，视为已安装，只做覆盖拷贝，不重复追加。
```

## Agent 执行要点（自检）

- 安装本质 = 复制 `package.json / lib / cordis.patch.yml` 到
  `%USERPROFILE%\.dsh\profiles\web\node_modules\sidor-character\` + patch 追加 insert 条目；
- patch 文件必须 **UTF-8** 读写（Windows PowerShell 5.1 默认 ANSI 会破坏中文注释），
  脚本已内置处理，勿用普通 `Set-Content` 重写；
- 安装后静态插件随 DSH 启动自动加载，无需 Cordis 面板操作；
- 若用户之前装过会话内动态插件（sidc-*），重启 DSH 后动态版自动消失，不冲突；
- 人设卡数据（localStorage `sidor.character.prefs`）动态/静态共用，迁移无感。
