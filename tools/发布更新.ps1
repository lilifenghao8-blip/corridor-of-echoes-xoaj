# 一键把游戏更新到线上（GitHub Pages）
# 用法：在项目目录执行  powershell -ExecutionPolicy Bypass -File tools\发布更新.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$gh   = Join-Path $root '_tmp\gh\bin\gh.exe'
$login = 'lilifenghao8-blip'
$repo  = 'corridor-of-echoes-xoaj'
$site  = "https://$login.github.io/$repo/"

if(-not (Test-Path $gh)){ Write-Host "找不到 gh.exe（$gh），请先重新下载 GitHub CLI" -ForegroundColor Red; exit 1 }

Write-Host "[1/3] 提交本地改动..." -ForegroundColor Cyan
git -C $root add -A
$msgFile = Join-Path $env:TEMP 'coe_commit_msg.txt'
[System.IO.File]::WriteAllText($msgFile, "更新游戏内容 " + (Get-Date -Format 'yyyy-MM-dd HH:mm') + "`n", [System.Text.UTF8Encoding]::new($false))
git -C $root -c i18n.commitEncoding=utf-8 commit -F $msgFile 2>$null
if($LASTEXITCODE -ne 0){ Write-Host "（没有新改动，直接重新推送）" -ForegroundColor DarkGray }

Write-Host "[2/3] 推送到 GitHub..." -ForegroundColor Cyan
$token = (& $gh auth token).Trim()
$b64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("x-access-token:$token"))
git -C $root -c http.extraheader="Authorization: Basic $b64" -c credential.interactive=false push origin master

Write-Host "[3/3] 等待 GitHub Pages 重新构建（约 30~60 秒）..." -ForegroundColor Cyan
for($i=0;$i -lt 30;$i++){
  Start-Sleep -Seconds 10
  $st = (& $gh api "repos/$login/$repo/pages" --jq '.status' 2>$null)
  Write-Host "  状态: $st"
  if($st -eq 'built'){ break }
}
Write-Host ""
Write-Host "完成！在线地址（可以直接转发给别人）：" -ForegroundColor Green
Write-Host "  $site" -ForegroundColor Yellow