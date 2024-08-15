# Use latest offical ubuntu image
FROM ubuntu:22.04

# Set timezone environment variable
ENV TZ=Europe/Berlin

ENV PHP_MAX_EXECUTION_TIME=240
ENV PHP_MEMORY_LIMIT=4096

# Set geographic area using above variable
# This is necessary, otherwise building the image doesn't work
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Remove annoying messages during package installation
ARG DEBIAN_FRONTEND=noninteractive

# Install packages: web server Apache, PHP and extensions
RUN apt-get update && apt-get install --no-install-recommends -y \
  apache2 \
  apache2-utils \
  ca-certificates \
  git \
  php \
  libapache2-mod-php \
  php-curl \
  php-dom \
  php-gd \
  php-intl \
  php-json \
  php-mbstring \
  php-xml \
  composer \
  php-zip && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy virtual host configuration from current path onto existing 000-default.conf
COPY default.conf /etc/apache2/sites-available/000-default.conf

# Remove default content (existing index.html)
RUN rm /var/www/html/*

# Clone the Kirby Starterkit
# WORKDIR /var/www/html/cms/
WORKDIR /var/www/html/
COPY . .
RUN composer install

# Activate Apache modules headers & rewrite
RUN a2enmod headers rewrite

COPY set_apache_user.sh /usr/local/bin/

ENTRYPOINT ["set_apache_user.sh"]

# Tell container to listen to port 80 at runtime
EXPOSE 80

# Start Apache web server
CMD [ "/usr/sbin/apache2ctl", "-DFOREGROUND" ]