exit
cat README.md

## Docker 실습 결과

### 1. Docker 이미지 빌드
명령어:
docker build -t dev-workplace-web:1.0 .

결과: 이미지 빌드 성공

### 2. 웹 서버 실행
명령어:
docker run -d -p 8081:80 --name dev-web-2 dev-workplace-web:1.0

결과: 브라우저에서 Hello Docker 확인

### 3. Docker 볼륨 생성
명령어:
docker volume create practice-data

결과: 볼륨 생성 성공

### 4. Docker 볼륨 데이터 유지 확인
명령어:
docker run --rm -v practice-data:/data ubuntu bash -c "echo 'Docker volume test successful' > /data/test.txt"

확인 명령어:
docker run --rm -v practice-data:/data ubuntu cat /data/test.txt

결과: Docker volume test successful


## Docker Bind Mount 실습

명령어:
docker run --rm -v "$(pwd):/workspace" ubuntu ls /workspace

결과: Codespaces 프로젝트 파일을 Ubuntu 컨테이너 내부 /workspace에서 확인함.

설명: Bind Mount를 사용하면 호스트의 프로젝트 폴더와 컨테이너 내부 폴더가 연결되어 파일을 공유할 수 있다.


## 실제 실습 실행 증거 (2026-11-03)

아래 파일은 GitHub Codespaces의 Linux 환경에서 실행한 실제 명령어 및 출력 기록입니다.

| 실습 내용 | 실행 증거 |
|---|---|
| Docker 버전 및 실행 상태, hello-world, 이미지·컨테이너 목록 | [docker-basic.txt](logs/docker-basic.txt) |
| Dockerfile 빌드, 웹 서버 실행, 포트 연결, Nginx 로그 | [docker-web.txt](logs/docker-web.txt) |
| 파일 생성·복사·이동·삭제, 권한 변경, Ubuntu, 볼륨·바인드 마운트, Git | [final-practice.txt](logs/final-practice.txt) |
| 8081 포트 웹페이지 접속 화면 | [web-8081.png](screenshots/web-8081.png) |

### 검증 결과

- Ubuntu 컨테이너에서 명령어 실행 결과 확인
- Docker 볼륨에서 컨테이너 삭제 후 데이터 유지 확인
- 바인드 마운트에서 호스트 파일 변경 전후 반영 확인
- 8081 포트에서 Hello Docker 웹페이지 접속 확인



## 추가 보완: 평가 항목 #9, #10, #16, #18

### Git 설정 및 GitHub 연동 (#9)
- [Git 설정 및 원격 저장소 확인 기록](logs/git-final.txt)
- [기존 Git 설정 기록](logs/git-config.txt)
- Git은 로컬 버전 관리 도구이고 GitHub는 원격 저장소 및 협업 플랫폼이다.
- 사용자 이름과 이메일 설정 여부는 개인정보를 노출하지 않고 확인하였다.

### 프로젝트 디렉터리 설계 (#10)
- `Dockerfile`: 웹 서버 컨테이너 이미지 제작
- `index.html`: 웹페이지 콘텐츠
- `compose.yaml`: Docker Compose 실행 설정
- `docker-practice/`: Docker 실습 자료
- `practice/`: 터미널과 파일 권한 실습
- `logs/`: 실제 명령어와 출력 기록
- `screenshots/`: 웹 접속 증거 이미지
- `docs/`: 개념 설명 및 문제 해결 문서
- `scripts/`: 반복 실행을 위한 자동화 스크립트

각 폴더는 역할에 따라 분리해 소스코드, 실습, 실행 증거를 쉽게 찾을 수 있도록 구성하였다.

### 포트 충돌 진단 및 해결 (#16)

8081 포트가 이미 사용 중이라면 다음 순서로 확인한다.

```bash
docker ps
ss -ltnp | grep ':8081'
```

포트를 점유한 컨테이너를 확인한 뒤, 해당 컨테이너를 중지해도 되는 경우에만 다음 명령을 사용한다.

```bash
docker stop <컨테이너_이름>
```

또는 호스트 포트를 8083으로 변경한다.

```bash
docker run -d -p 8083:80 --name alternative-web dev-workplace-web:1.0
```

`-p 8083:80`에서 8083은 호스트 포트, 80은 컨테이너 내부 포트다.

### 실제 트러블슈팅 사례 (#18)

**사례 1: 기관 Windows 환경에서 Docker 실행 불가**

- 문제: Docker Desktop에서 Virtual Machine Platform 비활성화 안내 발생
- 원인 가설: Windows 가상화 기능이 비활성화됨
- 확인: Windows 기능 활성화 명령이 관리자 권한 부족으로 실패
- 해결/대안: GitHub Codespaces 환경으로 이동
- 검증: Codespaces에서 `docker run hello-world` 실행 성공
- 증거: [Docker 실행 로그](logs/docker-basic.txt)

**사례 2: PowerShell에서 Git 명령 오류**

- 문제: `$git add` 입력 시 명령을 인식하지 못함
- 원인 가설: 명령어 앞에 불필요한 `$` 기호를 입력함
- 확인: 터미널 오류 메시지 확인
- 해결: `$` 없이 `git add`를 다시 입력
- 검증: 이후 Git commit 및 GitHub push 수행 성공
- 증거: GitHub 저장소의 commit 기록

### 관련 문서 및 검증
- [개념 설명](docs/concepts.md)
- [트러블슈팅 문서](docs/troubleshooting.md)
- [전체 실습 로그](logs/final-practice.txt)
