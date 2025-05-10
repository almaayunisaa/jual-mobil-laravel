# 🚗 Aplikasi Jual-Beli Mobil - Laravel 9

Ini adalah aplikasi web sederhana untuk pengelolaan data jual beli mobil menggunakan **Laravel 9**, **MySQL**, dan **Tailwind CSS**. Fitur utama mencakup manajemen produk mobil, kategori, pelanggan, dan transaksi.

---

## 📦 Fitur Utama

- CRUD Produk Mobil
- CRUD Kategori Mobil
- CRUD Pelanggan
- CRUD Transaksi Penjualan
- Autentikasi Admin (Laravel Breeze)
- Tampilan responsif dengan Tailwind CSS

---

## 🛠️ Instalasi

### 1. Clone Repository
```bash
git clone https://github.com/almaayunisaa/jual-mobil-laravel.git
cd jual-beli-mobil
```

### 2. Install Dependency Laravel
```bash
composer install
```

### 3. Copy File .env
```bash
cp .env.example .env
```

### 4. Generate App Key
```bash
php artisan key:generate
```

### 5. Atur Koneksi Database di .env
```bash
DB_CONNECTION=[database]
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=jualbelimobil
DB_USERNAME=[username]
DB_PASSWORD=[pass]
```

### 6. Jalankan Migrasi & Seeder
```bash
php artisan migrate --seed
```

### 7. Install Dependency Frontend
```bash
npm install
npm run dev
```

### 🚀 Jalankan Aplikasi
```bash
php artisan serve
```
Akses di browser:
http://127.0.0.1:8000/[masukan route]

### 🗂 Struktur Folder Penting
- app/Models — Model: Product, Category, Customer, Transaction

- app/Http/Controllers — Semua controller untuk fitur CRUD

- resources/views — Blade template untuk setiap fitur

- routes/web.php — Rute aplikasi berbasis resource

- database/seeders — Data awal seperti kategori

### 💻 Teknologi
- Laravel 9

- MySQL / MariaDB

- Tailwind CSS

- Laravel Breeze

- Vite





