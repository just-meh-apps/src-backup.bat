@echo off
REM SPDX-License-Identifier: MIT
REM Copyright (c) 2026 [본인 성함 또는 닉네임]
REM AI-Generated: This script was created with AI collaboration.

setlocal enabledelayedexpansion

REM ==========================================
REM 1. 사용자 설정 (이 부분만 수정하세요)
REM ==========================================

REM 원본 소스 경로
set "SRC_BASE=c:\worspace\prj01"

REM 백업 저장 폴더 (없으면 자동 생성)
set "BACKUP_ROOT=d:\backup"

REM 복사할 파일 목록 (SRC_BASE 기준 상대 경로)
REM ** 괄호 안을 비워두거나 REM 처리하면 전체 폴더를 백업합니다. **
set FILE_LIST=(^
REM "src\main\java\aaa\bbb\Cccjava"^
REM "src\main\java\aaa\bbb\Dddjava"^
)

REM ==========================================
REM 2. 자동 처리 구간 (수정 불필요)
REM ==========================================

REM 저장 폴더 체크 및 생성
if not exist "%BACKUP_ROOT%" mkdir "%BACKUP_ROOT%"

REM 폴더명 및 날짜시간 추출
for %%A in ("%SRC_BASE%") do set "FOLDER_NAME=%%~nxA"
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmm'"`) do set "DATETIME=%%i"

REM 최종 경로 및 파일명 조합
set "BACKUP_NAME=%FOLDER_NAME%_%DATETIME%"
set "TEMP_DIR=%BACKUP_ROOT%\%BACKUP_NAME%"
set "DEST_BASE=%TEMP_DIR%\%FOLDER_NAME%"
set "ZIP_FILE=%BACKUP_ROOT%\%BACKUP_NAME%.zip"

echo [%BACKUP_NAME%] 백업을 시작합니다...

REM 기존 중복 데이터 정리 (덮어쓰기 준비)
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
if exist "%ZIP_FILE%" del /f /q "%ZIP_FILE%"

REM FILE_LIST가 비어있는지 체크
set "IS_EMPTY=YES"
for %%F in %FILE_LIST% do ( 
    set "TMP_VAL=%%F"
    if not "!TMP_VAL!"=="REM" set "IS_EMPTY=NO"
)

if "%IS_EMPTY%"=="YES" (
    echo [알림] 목록이 비어있어 전체 백업을 진행합니다...
    robocopy "%SRC_BASE%" "%DEST_BASE%" /E /R:0 /W:0 /NDL /NFL /NJH /NJS >nul
) else (
    REM 리스트에 있는 파일만 선택적 복사
    for %%F in %FILE_LIST% do (
        set "FILE_PATH=%%~F"
        if not "!FILE_PATH!"=="REM" (
            set "FULL_PATH=%SRC_BASE%\!FILE_PATH!"
            if exist "!FULL_PATH!" (
                echo [진행] 복사 중: !FILE_PATH!
                robocopy "%SRC_BASE%\%%~pF." "%DEST_BASE%\%%~pF." "%%~nxF" /R:0 /W:0 /NDL /NFL /NJH /NJS >nul
            ) else (
                echo [무시] 파일을 찾을 수 없음: !FILE_PATH!
            )
        )
    )
)

REM 압축 처리 및 마무리
if exist "%DEST_BASE%" (
    echo.
    echo 압축 진행 중 (%FOLDER_NAME% 폴더 포함)...
    powershell -Command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%ZIP_FILE%' -Force"
    
    REM 임시 폴더 삭제
    rd /s /q "%TEMP_DIR%"
    echo.
    echo [완료] 백업 파일 생성: %ZIP_FILE%
    
    REM 결과 확인용 폴더 열기
    start "" "%BACKUP_ROOT%"
) else (
    echo.
    echo [중단] 복사된 파일이 하나도 없어 압축을 진행하지 않았습니다.
)

pause
