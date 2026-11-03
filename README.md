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

