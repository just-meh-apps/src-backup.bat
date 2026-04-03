@echo off
setlocal

if "%~1"=="" (
    echo [Usage] backup.bat config.json
    pause
    exit /b 1
)

set "CONFIG_FILE=%~1"

:: 모든 명령어를 한 줄로 이어 붙여서 오류 가능성을 차단했습니다.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$cfg = Get-Content -Raw -Path '%CONFIG_FILE%' | ConvertFrom-Json; $src = $cfg.SRC_BASE.TrimEnd('\'); $dest = $cfg.BACKUP_ROOT; $files = $cfg.FILE_LIST; $name = Split-Path $src -Leaf; $time = Get-Date -Format 'yyyyMMdd_HHmm'; $zip = Join-Path $dest \"$name`_$time.zip\"; $temp = Join-Path $env:TEMP \"bak_$time\"; Write-Host '--- Backup Starting ---' -ForegroundColor Green; if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }; $work = New-Item -ItemType Directory -Path (Join-Path $temp $name) -Force; if ($files.Count -gt 0) { foreach ($f in $files) { $fSrc = Join-Path $src $f; if (Test-Path $fSrc) { $fDest = Join-Path $work.FullName $f; $null = New-Item -ItemType Directory -Path (Split-Path $fDest) -Force; Copy-Item $fSrc $fDest -Force } } } else { Copy-Item $src $work.FullName -Recurse -Force }; Compress-Archive -Path $work.FullName -DestinationPath $zip -Force; Remove-Item $temp -Recurse -Force; Write-Host '--- Backup Finished ---' -ForegroundColor Cyan; explorer $dest"

pause
