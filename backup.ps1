# SPDX-License-Identifier: MIT
# Windows Project Auto Backup Script

Param(
    [Parameter(Position=0)] # 0번 위치(첫 번째)에 오면 이름표 생략 가능!
    [string]$config
)

# 1. 인수 체크 및 가이드 출력
if (-not $config -or -not (Test-Path $config)) {
    Write-Host "Usage Guide:" -ForegroundColor Cyan
    Write-Host "  .\backup.ps1 -config <path_to_json_file>"
    Write-Host "`nExample:"
    Write-Host "  .\backup.ps1 -config .\config.json"
    
    Write-Host "`nJSON Configuration Template (config.json):" -ForegroundColor Yellow
    $template = @{
        SRC_BASE = "C:/workspace/my_project"
        BACKUP_ROOT = "D:/backup"
        FILE_LIST = @("src/main/java/App.java", "src/main/resources/config.xml")
    }
    $template | ConvertTo-Json | Write-Host
    exit
}

try {
    # JSON 설정 로드
    $cfgData = Get-Content -Raw -Path $config | ConvertFrom-Json
    
    # 2. 경로 정규화 (Normalization)
    $srcBase = [System.IO.Path]::GetFullPath($cfgData.SRC_BASE).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    $backupRoot = [System.IO.Path]::GetFullPath($cfgData.BACKUP_ROOT)
    $srcFolderName = Split-Path $srcBase -Leaf
    
    # 3. 자동 이름 생성 (폴더명_yyyyMMdd_HHmm)
    $timestamp = Get-Date -Format "yyyyMMdd_HHmm"
    $zipFileName = "${srcFolderName}_${timestamp}.zip"
    $zipPath = Join-Path $backupRoot $zipFileName
    $tempWorkDir = Join-Path $env:TEMP "ps_backup_$timestamp"

    Write-Host "Starting backup for: $srcFolderName" -ForegroundColor Green

    # 4. 초기화 (기존 파일/폴더 삭제)
    if (Test-Path $tempWorkDir) { Remove-Item $tempWorkDir -Recurse -Force }
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    New-Item -ItemType Directory -Path $tempWorkDir -Force | Out-Null

    # 복사 대상 루트 설정 (ZIP 내부 최상위 폴더 구조 유지)
    $destRoot = Join-Path $tempWorkDir $srcFolderName

    # 5. 복사 로직 처리
    if ($cfgData.FILE_LIST -and $cfgData.FILE_LIST.Count -gt 0) {
        # 특정 파일 리스트만 백업
        foreach ($relPath in $cfgData.FILE_LIST) {
            $fullSrcPath = Join-Path $srcBase $relPath
            if (Test-Path $fullSrcPath) {
                $fullDestPath = Join-Path $destRoot $relPath
                $destFolder = Split-Path $fullDestPath -Parent
                if (-not (Test-Path $destFolder)) { New-Item -ItemType Directory -Path $destFolder -Force | Out-Null }
                Copy-Item -Path $fullSrcPath -Destination $fullDestPath -Force
            }
        }
    } else {
        # FILE_LIST가 비어있으면 전체 백업
        Copy-Item -Path $srcBase -Destination $destRoot -Recurse -Force
    }

    # 6. 압축 및 정리
    if (-not (Test-Path $backupRoot)) { New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null }
    Compress-Archive -Path "$destRoot" -DestinationPath $zipPath -Force
    
    # 임시 폴더 삭제
    Remove-Item $tempWorkDir -Recurse -Force

    Write-Host "Backup completed: $zipPath" -ForegroundColor Cyan

    # 7. 탐색기 열기
    Invoke-Item $backupRoot

} catch {
    Write-Error "An error occurred: $_"
}
