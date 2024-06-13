# Use the official MySQL image as a base
FROM mysql:8.0

# Set environment variables
ENV MYSQL_DATABASE=signup
ENV MYSQL_ROOT_PASSWORD=Khoi@8888

# Specify the desired directory for MySQL data
RUN mkdir -p /var/lib/mysql_data
# Optionally, copy any existing MySQL data from host
# COPY /path/on/host /var/lib/mysql_data

# Set MySQL to use the specified data directory
VOLUME /var/lib/mysql_data

# Copy the initial SQL script to the container
COPY setup.sql /docker-entrypoint-initdb.d/

# Expose the MySQL port
EXPOSE 3306
