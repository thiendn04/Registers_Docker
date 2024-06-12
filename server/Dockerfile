FROM node:18-alpine

WORKDIR /registers/backend

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8081

# CMD [ "npm", "start" ]

CMD [ "node", "server.js" ]
#docker build --tag node-docker .
#docker run -p 8081:8081 -d node-docker
