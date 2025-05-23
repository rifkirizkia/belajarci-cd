# Gunakan image resmi PHP dengan Apache
FROM php:8.2-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl

# Install ekstensi PHP yang dibutuhkan Laravel
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Aktifkan modul Apache Rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set direktori kerja
WORKDIR /var/www/html

# Mengatasi masalah kepemilikan direktori yang tidak aman
RUN git config --global --add safe.directory /var/www/html

# Salin file aplikasi Laravel ke dalam container
COPY . .

# Copy file .env dari lokal ke image
COPY .env .env

# Berikan izin pada folder storage dan cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Salin file konfigurasi Apache
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Jalankan Composer
RUN composer install --no-dev --optimize-autoloader

# Jalankan perintah Laravel
RUN php artisan key:generate

# Ekspose port 80
EXPOSE 80

# Jalankan Apache
CMD ["apache2-foreground"]
