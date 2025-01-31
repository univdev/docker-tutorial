# Docker Tutorial

Dockerfile과 Docker Compose를 사용하여 nestjs + prisma + postgres 환경을 구축해봅니다.

## Dockerfile

```Dockerfile
FROM node:18
# Node의 버전입니다.

WORKDIR /app
# Container 내부 디렉토리를 설정합니다.

COPY . /app
# 현재 디렉토리 (호스트의 실제 작업 디렉토리)를 Container 내부 디렉토리로 복사합니다.

RUN npm i -g pnpm
# pnpm을 전역으로 설치합니다.

RUN pnpm install
# 현재 디렉토리의 package.json을 읽어서 필요한 패키지를 설치합니다.

RUN pnpm prisma:generate
# prisma 모델을 기반으로 prisma client를 생성합니다.

EXPOSE 3000
# 3000번 포트를 외부에 노출합니다.

CMD ["sh", "-c", "pnpm prisma:migrate:dev && pnpm start:dev"]
# 컨테이너가 시작될 때 실행할 명령어를 설정합니다.
# 데이터베이스 마이그레이션을 실행하고 개발 서버를 시작합니다.
# CMD에 몰아서 설정한 이유는 컨테이너가 시작 되어야 Postgres가 시작되어 migrate:dev 명령어를 수행할 수 있기 때문입니다.
```

## Docker Compose

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - '3000:3000'
    volumes:
      - .:/app
    environment:
      - NODE_ENV=production
    depends_on:
      - postgres

  postgres:
    image: postgres
    ports:
      - '5432:5432'
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
    volumes:
      - postgres_${NODE_ENV}_data:/var/lib/postgresql/data

volumes:
  postgres_development_data:
  postgres_production_data:
```

Docker Compose는 여러 이미지를 여러 컨테이너로 묶어서 관리할 수 있도록 도와줍니다.

- `app`과 `postgres`는 각각 이미지를 의미합니다.

- `build`는 DockerFile을 의미합니다.
- `build.context`는 현재 디렉토리를 의미합니다.
- `build.dockerfile`은 Dockerfile을 의미합니다.

- `ports`는 호스트와 컨테이너의 포트를 매핑합니다.
- `volumes`는 호스트와 컨테이너의 볼륨을 매핑합니다.
  - `app` 서비스의 문법대로 사용하면 호스트의 파일과 컨테이너 내부 파일이 동기화 됩니다.
- `environment`는 컨테이너의 환경변수를 설정합니다.
- `depends_on`은 컨테이너의 의존성을 설정합니다.

## package.json scripts

```json
    "prisma:migrate:dev": "dotenv -e .env.development -- prisma migrate dev --name init",
    "prisma:generate": "prisma generate",
    "docker-compose:up": "docker compose --env-file .env.development up -d"
```

- `prisma:migrate:dev`는 개발 환경에서 데이터베이스 마이그레이션을 실행합니다.
  - `dotenv`에 의존하고 있는데, 이는 migrate 시 `.env.development`라는 특수한 이름의 파일명을 사용하기 위함입니다.
- `prisma:generate`는 prisma client를 생성합니다.
- `docker-compose:up`은 docker compose를 실행합니다.
  - `.env.development` 파일을 사용하는 이유는, docker compose 내부에서 환경변수에 의존하는 영역이 존재하기 때문입니다.

## .env.development

```.env
NODE_ENV=development
POSTGRES_PASSWORD=randompassword
POSTGRES_USER=johndoe
POSTGRES_DB=mydb
DATABASE_URL="postgresql://johndoe:randompassword@postgres/mydb?schema=public"
```

위 `.env.development` 파일을 현재 프로젝트 폴더에 생성하고 위 내용을 복사하면 정상적으로 동작합니다.

## 실행 방법

```bash
pnpm docker-compose:up
```

위 명령어를 실행하면 Prisma, Postgres, Nestjs가 실행되고, 3000번 포트로 접속이 가능한 상태가 됩니다.
