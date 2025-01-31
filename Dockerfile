FROM node:18

WORKDIR /app

COPY . /app

RUN npm i -g pnpm
RUN pnpm install

EXPOSE 3000:3000

CMD ["pnpm", "start:dev"]