# Use the official MySQL image as a base
FROM mysql:8.0-alpine

# Set environment variables
ENV MYSQL_DATABASE=signup
ENV MYSQL_ROOT_PASSWORD=Khoi@8888

# Copy the initial SQL script to the container
COPY setup.sql /docker-entrypoint-initdb.d/

# Expose the MySQL port
EXPOSE 3306
