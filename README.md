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

