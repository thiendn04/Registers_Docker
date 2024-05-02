# Stage 1: Build the client
FROM node:18.16.0 AS client-build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . ./
EXPOSE 3000
RUN npm run build
CMD [ "npm", "start" ]
