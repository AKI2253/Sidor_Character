# Sidor_Character Client 构建脚本
# 将 src/sidor-character-client.js 内联进 scripts/client-wrapper.template.js，
# 生成 lib/client.js（ModuleLoader bundle）。包内运行时无需构建，此脚本仅在源码更新后重打一次。
param(
  [string]$Root = (Split-Path -Parent $PSScriptRoot),
  [string]$PluginId = 'sidor-character',
  [string]$Src = 'src\sidor-character-client.js',
  [string]$Tpl = 'scripts\client-wrapper.template.js',
  [string]$Out = 'lib\client.js'
)

$srcPath = Join-Path $Root $Src
$tplPath = Join-Path $Root $Tpl
$outPath = Join-Path $Root $Out

if (-not (Test-Path $srcPath)) { throw "src not found: $srcPath" }
if (-not (Test-Path $tplPath)) { throw "template not found: $tplPath" }

$src = Get-Content $srcPath -Raw -Encoding UTF8
$tpl = Get-Content $tplPath -Raw -Encoding UTF8

# 源码是插件函数体（以 "return { ... }" 开头），模板将其作为 async 函数体内联。
# 占位符必须精确替换；源码中不应出现该占位符。
if (-not $tpl.Contains('__SIDOR_PLUGIN_ID__')) { throw 'template missing __SIDOR_PLUGIN_ID__ placeholder' }
if (-not $tpl.Contains('__SIDOR_CLIENT_SRC__')) { throw 'template missing __SIDOR_CLIENT_SRC__ placeholder' }
if (-not $tpl.Contains('__SIDOR_CLIENT_INJECT__')) { throw 'template missing __SIDOR_CLIENT_INJECT__ placeholder' }

# Cordis 只认「顶层插件对象」上的 inject。源码的 inject 必须提升进 bundle 的
# exports.inject，否则 ctx 上不会装配这些服务（如 timer），内层访问即抛。
$injectMatch = [regex]::Match($src, '(?m)^\s*inject\s*:\s*(\[[^\]]*\])')
if (-not $injectMatch.Success) {
  throw ('could not extract `inject: [...]` from ' + $Src + ' — 若插件确实无依赖，请在源码中显式写 `inject: [],`')
}
$inject = $injectMatch.Groups[1].Value
Write-Output "plugin : $PluginId"
Write-Output "inject : $inject"

$out = $tpl.Replace('__SIDOR_PLUGIN_ID__', $PluginId).Replace('__SIDOR_CLIENT_INJECT__', $inject).Replace('__SIDOR_CLIENT_SRC__', $src)

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outPath) | Out-Null
[System.IO.File]::WriteAllText($outPath, $out, (New-Object System.Text.UTF8Encoding($false)))

# 语法校验：产物一旦有语法错误，浏览器仍会触发 script 的 load 事件，
# ModuleLoader 只会报 "loaded without registering" 而不指出真正原因。必须在此拦截。
$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) {
  $check = & node --check $outPath 2>&1
  if ($LASTEXITCODE -ne 0) {
    Remove-Item $outPath -Force
    throw "syntax check failed, output removed:`n$check"
  }
  Write-Output "syntax check: ok"
} else {
  Write-Warning 'node not found — skipped syntax check'
}

Write-Output "built: $outPath ($((Get-Item $outPath).Length) bytes)"
