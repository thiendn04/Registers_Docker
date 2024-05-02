FROM nginx:1.23.3

RUN unlink /etc/nginx/sites-enabled/default

RUN ln -s /etc/nginx/sites-available/{{ http_conf }} /etc/nginx/sites-enabled/

FROM node:18-alpine

WORKDIR /registers/frontend

COPY ../../client/package*.json ./

RUN npm install

COPY . .

RUN npm run build

CMD [ "npm","run", "build" ]