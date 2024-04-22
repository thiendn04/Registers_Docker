# Sử dụng một image node.js đã có sẵn từ Docker Hub
FROM node:18.16.0

# Thiết lập thư mục làm việc
WORKDIR /app

# Copy package.json và package-lock.json (nếu có) vào thư mục /app
COPY package*.json ./

# Cài đặt các dependencies
RUN npm install

# Copy mã nguồn của ứng dụng vào thư mục /app
COPY . .

# Build ứng dụng
RUN npm run build

# Copy các tệp từ nodejs build vào thư mục /var/www/webdemo/public_html
RUN mkdir -p /var/www/{{ http_host }}/public_html
RUN cp -a build/. /var/www/{{ http_host }}/public_html

# Sử dụng image nginx làm image cơ sở tiếp theo
FROM nginx:latest

# Copy tệp cấu hình Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copy các tệp từ nodejs build vào thư mục Nginx
COPY --from=0 /var/www/webdemo/public_html /usr/share/nginx/html

# Mở cổng 80 để truy cập ứng dụng
EXPOSE 80

# Khởi động Nginx
CMD ["nginx", "-g", "daemon off;"]
