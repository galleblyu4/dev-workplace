# 트러블슈팅 — 실제 발생 사례

## 사례 1 — Windows PowerShell에서 Docker 명령을 찾지 못함
- **문제:** `docker --version` 명령에서 `'docker' 용어가 ... 인식되지 않습니다`, `CommandNotFoundException` 발생(2026-11-03).
- **원인 가설:** Docker Desktop이 설치되지 않았거나 Docker 실행 파일이 PATH에 없음.
- **확인:** `docker --version` 실패를 확인함. 설치 여부는 아직 확인하지 못했음.
- **조치:** Docker Desktop(Windows) 설치 및 WSL 2 환경 확인 예정.
- **해결 검증:** **미완료**. 설치 후 [01-environment.txt](../logs/01-environment.txt)에서 `docker --version`, `docker info` 실제 출력을 확인하고 성공 시 수정할 것.

## 사례 2 — PowerShell 프롬프트를 명령으로 오인
- **문제:** 터미널 표시 문자열 `PS C:\Users\...\dev-workplace>` 전체를 입력해 `Get-Process`의 `NoProcessFoundForGivenName` 오류 발생(2026-11-03).
- **원인 가설:** `PS ...>`는 프롬프트인데 명령어로 입력함.
- **확인:** 오류 메시지에 `PS C:\...>`가 실행 명령으로 표시되었음.
- **조치:** 프롬프트는 입력하지 않고 `git remote -v`, `git config --list` 등 명령만 입력함.
- **검증:** `git remote -v`에 `origin https://github.com/galleblyu4/dev-workplace.git (fetch/push)`가 출력되고 `git-config.txt`, `git-remote.txt` 파일 생성됨. [Git 검증 로그](../logs/02-git.txt)는 수집 스크립트 실행 후 생성.

## 추가 문제 기록 템플릿
- 날짜/환경:
- 문제 및 오류 원문:
- 원인 가설:
- 확인 명령과 출력 링크:
- 조치:
- 재검증 명령과 결과 링크:
