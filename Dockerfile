# Stage 1: Build the client
FROM node:18.16.0 AS client-build
WORKDIR /app/client
COPY client/package*.json ./
RUN npm install
COPY client/ .
RUN npm run build

# Stage 2: Build the server
FROM node:18.16.0 AS server-build
WORKDIR /app/server
COPY server/package*.json ./
RUN npm install
COPY server/ .

# Stage 3: Combine client and server into final image
FROM node:18.16.0
WORKDIR /app
COPY --from=client-build /app/client/build ./client/build
COPY --from=server-build /app/server ./server
WORKDIR /app/server
EXPOSE 3000
CMD ["npm", "start"]
