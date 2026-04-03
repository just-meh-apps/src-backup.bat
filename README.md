# Windows 프로젝트 자동 백업 스크립트 (PS1 & BAT)

이 프로젝트는 Windows 10 및 11 환경에서 특정 프로젝트의 주요 파일들을 선별하여 복사하고 날짜별 ZIP 압축 백업을 수행하는 스크립트 세트입니다. PowerShell의 기능과 배치 파일(BAT)의 실행 편의성을 결합하였습니다.

## 주요 기능
- 유연한 백업 모드: FILE_LIST에 지정된 특정 파일만 추출하거나, 목록이 비어 있을 경우 폴더 전체를 백업합니다.
- 동적 파일명 생성: [원본폴더명]_[yyyyMMdd_HHmm].zip 형식으로 저장되어 버전 관리가 용이합니다.
- 경로 구조 유지: 압축 파일 내부에 원본의 상대 경로 구조를 그대로 유지하여 복구 시 혼선을 방지합니다.
- 보안 정책 우회 실행: 배치 파일(backup.bat)을 통해 실행 시 PowerShell 실행 정책 오류 없이 즉시 실행됩니다.
- 자동 환경 정리: 백업 완료 후 임시 작업 폴더를 삭제합니다.

## 시스템 요구 사항
- OS: Windows 10 또는 Windows 11 (PowerShell 5.1 이상 내장)
- 별도의 외부 프로그램 설치 없이 윈도우 기본 기능만으로 동작합니다.

## 파일 구성
- backup.ps1: 메인 백업 로직이 담긴 PowerShell 스크립트
- backup.bat: 보안 오류를 방지하고 간편 실행을 돕는 래퍼(Wrapper) 파일
- config.json: 백업 대상 및 경로 설정을 관리하는 설정 파일

## 설정 방법 (config.json)
백업 실행 전, 동일 폴더에 config.json 파일을 작성합니다.

{
  "SRC_BASE": "C:/workspace/project_alpha",
  "BACKUP_ROOT": "D:/backups/projects",
  "FILE_LIST": [
    "src/main.py",
    "config/settings.json",
    "README.md"
  ]
}

- SRC_BASE: 백업할 원본 프로젝트의 루트 경로
- BACKUP_ROOT: ZIP 백업 파일이 저장될 대상 경로
- FILE_LIST: 백업할 파일들의 상대 경로 리스트 (전체 백업 시 []로 비워둠)

## 실행 방법

### 방법 1: 배치 파일 사용 (권장)
가장 간단한 방법입니다. config.json을 backup.bat 위로 드래그 앤 드롭하거나 CMD에서 아래와 같이 입력합니다.
> backup.bat config.json

### 방법 2: PowerShell 직접 실행
PowerShell 터미널에서 스크립트를 직접 호출합니다. (첫 번째 인자로 설정파일 경로 전달)
> .\backup.ps1 .\config.json

※ 보안 오류(PSSecurityException) 발생 시:
PowerShell 정책으로 인해 .ps1 파일 실행이 차단될 경우, 시스템 설정을 변경하지 않고 실행 시에만 일시적으로 정책을 우회하는 아래 명령어를 사용하십시오.
> powershell -NoProfile -ExecutionPolicy Bypass -File .\backup.ps1 .\config.json
(참고: 제공된 backup.bat 파일을 사용하면 이 과정이 자동으로 처리되어 오류가 발생하지 않습니다.)

## 기술적 주의 사항
- 경로 구분자: JSON 설정 시 경로 구분자로 / 또는 \\를 사용할 수 있습니다.
- 인코딩: 한글 경로가 포함된 경우 config.json 파일을 반드시 UTF-8 형식으로 저장하십시오.
- 실행 권한: 시스템 보호 폴더나 네트워크 드라이브 접근 시 관리자 권한이 필요할 수 있습니다.

## 라이선스 및 AI 정보
- AI-Generated: 이 프로젝트는 AI와의 협업을 통해 초안 작성 및 최적화 과정을 거쳤습니다.
- License: MIT License 하에 자유롭게 수정 및 배포가 가능합니다.
