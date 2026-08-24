# Sidor_Character 安装/卸载脚本（无 pnpm 环境的手工安装通道）
# 安装：把本包复制进 DSH profile 的 node_modules，并把插件行写入该 profile 的 cordis.patch.yml，
#       使 Sidor_Character 随 DSH 启动自动加载（持久化插件，重启无需手动）。
# Sidor_Character 与 Sidor_UI / Sidor_box 是互相独立的插件：可单独安装，也可并存（patch 逐条追加）。
# 用法：
#   powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProfileName web -Remove
param(
  [string]$Root = (Split-Path -Parent $PSScriptRoot),
  [string]$DshHome = $env:DSH_HOME,
  [string]$ProfileName = 'web',
  [switch]$Remove
)

if (-not $DshHome) { $DshHome = Join-Path $env:USERPROFILE '.dsh' }
$profileDir = Join-Path $DshHome "profiles\$ProfileName"
$pkgName = 'sidor-character'
$target = Join-Path $profileDir "node_modules\$pkgName"
$patchFile = Join-Path $profileDir 'cordis.patch.yml'

$mode = 'install'; if ($Remove) { $mode = 'uninstall' }
Write-Host "== Sidor_Character $mode =="
Write-Host "  profile : $profileDir"
Write-Host "  package : $target"

if (-not (Test-Path $profileDir)) { throw "profile not found: $profileDir" }

if ($Remove) {
  if (Test-Path $target) { Remove-Item $target -Recurse -Force; Write-Host "  removed package: $target" }
  if (Test-Path $patchFile) {
    # 必须以 UTF-8 读取，否则 Windows PowerShell 5.1 会用 ANSI(GBK) 解码，
    # 把文件中已有的中文注释读成乱码并回写（会破坏其他插件的补丁行）。
    $c = Get-Content $patchFile -Raw -Encoding UTF8
    $rxBlock = '(?ms)^\s*-\s*insert:\s*\n\s*-\s*id:\s*' + [regex]::Escape($pkgName) + '\s*\n\s*name:\s*' + [regex]::Escape($pkgName) + '\s*\n?'
    if ($c -match $rxBlock) {
      $c = $c -replace $rxBlock, ''
      [System.IO.File]::WriteAllText($patchFile, $c, (New-Object System.Text.UTF8Encoding($true)))
      Write-Host '  removed patch entry (cordis.patch.yml)'
    }
  }
  Write-Host '  完成。重启 dsh 生效。'
  exit 0
}

# 1) 复制包进 profile node_modules（只装运行时需要的文件）
New-Item -ItemType Directory -Force -Path (Join-Path $profileDir 'node_modules') | Out-Null
if (Test-Path $target) { Remove-Item $target -Recurse -Force }
New-Item -ItemType Directory -Force -Path $target | Out-Null
foreach ($rel in @('package.json', 'lib', 'cordis.patch.yml')) {
  $src = Join-Path $Root $rel
  if (Test-Path $src) { Copy-Item $src $target -Recurse -Force }
}
Write-Host "  copied package -> $target"

# 2) patch：把插件行并入 profile 的 cordis.patch.yml（可与其他插件并存，逐个追加）
if (-not (Test-Path $patchFile)) {
  [System.IO.File]::WriteAllText($patchFile, '[]', (New-Object System.Text.UTF8Encoding($true)))
}
$c = Get-Content $patchFile -Raw -Encoding UTF8
$trimmed = $c.Trim()
$entryBlock = @"
# Sidor_Character 持久化插件（由 scripts/install.ps1 写入；卸载请重跑 -Remove）
- insert:
    - id: $pkgName
      name: $pkgName
"@
if ($c -match [regex]::Escape($pkgName)) {
  Write-Host "  patch already contains $pkgName; skipped."
} elseif ($trimmed -eq '[]' -or $trimmed.EndsWith('[]')) {
  $new = @"
# Your patch layer for this dsh profile, applied after every bundle layer:
# a top-level YAML array of loader patch entries (id-targeted config
# overrides, disables, and insert lists; `!!js` expressions allowed).

$entryBlock
"@
  [System.IO.File]::WriteAllText($patchFile, $new, (New-Object System.Text.UTF8Encoding($true)))
  Write-Host "  wrote patch entry -> cordis.patch.yml"
} else {
  # 已有其他内容（可能是 Sidor_UI / Sidor_box 等别的插件行）：在列表末尾追加一个新 insert 块
  $appended = $c.TrimEnd() + "`n`n" + $entryBlock + "`n"
  [System.IO.File]::WriteAllText($patchFile, $appended, (New-Object System.Text.UTF8Encoding($true)))
  Write-Host "  appended patch entry -> cordis.patch.yml"
}

Write-Host ''
Write-Host "  安装完成。重启 DSH（或热重载 profile）后 $pkgName 将随宿主自动加载。"
Write-Host '  若浏览器未出现特效，请硬刷新（Ctrl+Shift+R）。'
