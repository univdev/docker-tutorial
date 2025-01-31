FROM node:18

WORKDIR /app

COPY . /app

RUN npm i -g pnpm
RUN pnpm install
RUN pnpm prisma:generate

EXPOSE 3000

CMD ["sh", "-c", "pnpm prisma:migrate:dev && pnpm start:dev"]
