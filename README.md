# Prime Care Hospital

Aplikasi Antrean Online Rumah Sakit berbasis Flutter dan SQLite.

## Deskripsi

Prime Care Hospital membantu pasien melakukan pendaftaran dan pengambilan nomor antrean poli spesialis secara online tanpa harus datang ke rumah sakit terlebih dahulu.

## Fitur Utama

- **Authentication** - Login dengan username dan password
- **Patient Registration** - Pendaftaran data pasien
- **Specialist Selection** - Pemilihan poli spesialis
- **Doctor Selection** - Pemilihan dokter
- **Schedule Selection** - Pemilihan jadwal praktik
- **Queue Generation** - Generate nomor antrean otomatis
- **Queue Status** - Status antrean (Menunggu, Dipanggil, Selesai)
- **Doctor Management** - CRUD data dokter
- **Specialist Management** - CRUD data poli

## Tech Stack

- **Framework:** Flutter
- **Database:** SQLite (lokal)
- **Platform:** Android, iOS, Windows

## Halaman

- Splash Screen
- Login Page
- Home Page
- Queue Registration Page
- Queue List Page
- Queue Detail Page
- Profile Page
- About Page

## Cara Menjalankan

```bash
flutter pub get
flutter run
```

## Struktur Database

- **Patients** - Data pasien
- **Specialists** - Data poli spesialis
- **Doctors** - Data dokter dengan jadwal
- **Queues** - Data antrean

## License

Project ini dikembangkan untuk tujuan akademis.
