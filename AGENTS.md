# AGENTS.md

## Project Identity

Nama Aplikasi: MediQueue

Jenis Aplikasi:
Aplikasi Antrean Online Rumah Sakit Berbasis Flutter dan SQLite.

Tujuan:
Membantu pasien melakukan pendaftaran dan pengambilan nomor antrean poli spesialis secara online tanpa harus datang ke rumah sakit terlebih dahulu.

Target Pengguna:

1. Pasien Rumah Sakit
2. Petugas Administrasi Rumah Sakit

## Business Problem

Proses pendaftaran pasien di rumah sakit sering menyebabkan antrean panjang karena pasien harus datang lebih awal hanya untuk mengambil nomor antrean.

Aplikasi ini bertujuan untuk:

* Mengurangi antrean fisik.
* Mempermudah proses pendaftaran pasien.
* Memberikan nomor antrean secara otomatis.
* Memungkinkan pasien memilih poli dan dokter secara langsung.
* Menampilkan informasi antrean dengan cepat dan mudah.

## Scope Project

Project ini merupakan aplikasi mobile Flutter yang menggunakan SQLite sebagai database lokal.

Project ini tidak menggunakan:

* REST API
* Firebase
* Server Backend
* Integrasi Dukcapil
* Integrasi BPJS

Semua data disimpan secara lokal menggunakan SQLite.

## Main Features

### Authentication

Login menggunakan:

Username = Nama Mahasiswa

Password = NIM

Fitur:

* Validasi username
* Validasi password
* Login berhasil
* Login gagal
* Logout

### Patient Registration

Pasien dapat mengisi:

* Nama Pasien
* NIK
* Nomor HP
* Jenis Kelamin
* Tanggal Lahir

### Specialist Selection

Pasien dapat memilih poli:

* Poli Anak
* Poli Mata
* Poli Jantung
* Poli Gigi
* Poli THT
* Poli Kandungan

### Doctor Selection

Setiap poli memiliki daftar dokter.

Contoh:

Poli Mata:

* Dr. Andi Saputra
* Dr. Siti Rahma

Poli Jantung:

* Dr. Budi Hartono
* Dr. Dewa Pratama

### Schedule Selection

Pasien dapat memilih jadwal praktik dokter.

Contoh:

* Senin 08.00-12.00
* Selasa 13.00-16.00
* Rabu 08.00-12.00

### Queue Generation

Setelah data disimpan sistem akan menghasilkan:

* Nomor Antrean
* Tanggal Kunjungan
* Estimasi Waktu
* Status Antrean

Contoh:

M001
M002
M003

Huruf depan mengikuti kode poli.

### Doctor Management (New)

Admin dapat melakukan CRUD data dokter:

- Tambah dokter dengan nama, spesialis, dan jadwal praktik
- Edit data dokter
- Hapus dokter
- Lihat daftar semua dokter

### Specialist/Poli Management (New)

Admin dapat melakukan CRUD data poli:

- Tambah poli dengan nama dan kode (1 huruf)
- Edit data poli
- Hapus poli
- Lihat daftar semua poli

Data poli digunakan untuk dropdown pada form pendaftaran antrean dan form dokter.

### Queue Status

Status yang tersedia:

* Menunggu
* Dipanggil
* Selesai

## CRUD Requirements

Aplikasi wajib memiliki:

Create
Menambahkan antrean baru.

Read
Melihat daftar antrean.

Update
Mengubah data antrean.

Delete
Menghapus antrean.

## Required Pages

### Splash Screen

Menampilkan:

* Logo Aplikasi
* Logo UNPAM
* Logo Sistem Informasi
* Nama Aplikasi

### Login Page

Menampilkan:

* Username
* Password
* Tombol Login

### Home Page

Menampilkan:

* Ringkasan aplikasi
* Jumlah antrean
* Menu utama

### Queue Registration Page

Menampilkan form pendaftaran antrean.

### Queue List Page

Menampilkan seluruh data antrean.

### Queue Detail Page

Menampilkan detail antrean.

### Profile Page

Menampilkan:

* Foto KTM
* Nama Mahasiswa
* NIM
* Program Studi

### About Page

Menampilkan informasi aplikasi.

## Navigation Structure

Splash Screen

↓

Login

↓

Home

├── Daftar Antrean
├── Data Antrean
├── Data Dokter
├── Data Poli
├── Profil
└── Tentang

## Database Structure

### Table Patients

id

nama

nik

nomor_hp

jenis_kelamin

tanggal_lahir

### Table Specialists

id

nama

kode (1 huruf, contoh: A, M, J, G, T, K)

### Table Doctors

id

nama_dokter

spesialis

jadwal (JSON array of {hari, jam})

### Table Queues

id

patient_id

doctor_id

nomor_antrean

tanggal_kunjungan

estimasi_waktu

status

## UI Requirements

Wajib menggunakan:

* Scaffold
* AppBar
* Drawer
* BottomNavigationBar
* Container
* Row
* Column
* Card
* ListView
* TextField
* DropdownButton
* DatePicker
* RadioButton
* AlertDialog
* SnackBar
* CircleAvatar

## Assets

Minimal menggunakan:

* Logo UNPAM
* Logo Sistem Informasi
* Foto KTM

Tambahan:

* Logo Aplikasi
* Ilustrasi Dokter
* Ilustrasi Pasien

## Design Guidelines

Tema:

Modern Healthcare

Warna Utama:

Biru

Putih

Hijau

Tampilan harus:

* Bersih
* Responsif
* Mudah digunakan
* Konsisten pada seluruh halaman

## Known Issues & Resolutions

### SQLite native library not found on Windows ("sqlite3_initialize" error)

Symptom: `Couldn't resolve native function 'sqlite3_initialize'`

Root cause: `native_assets.json` in `build/windows/x64/runner/Debug/` is missing the mapping for `package:sqlite3/src/ffi/libsqlite3.g.dart` → `sqlite3.dll`.

Fix:
1. Remove EOL `sqlite3_flutter_libs` from pubspec (the `sqlite3` package handles native assets natively)
2. `flutter pub get` → `flutter build windows`
3. Or run tool backend directly:
   ```
   $env:PROJECT_DIR = "D:\DUIT\antrian"; $env:FLUTTER_ROOT = "C:\Users\hp\flutter"; & "$env:FLUTTER_ROOT\packages\flutter_tools\bin\tool_backend.bat" windows-x64 Debug
   ```
4. Verify `build\windows\x64\runner\Debug\native_assets.json` contains the sqlite3 DLL mapping.

## Development Rules

AI Agent harus:

1. Mengikuti definisi project ini sebagai sumber utama.
2. Tidak membuat fitur di luar scope tanpa instruksi.
3. Menjaga struktur folder tetap rapi.
4. Menggunakan Flutter best practice.
5. Mengutamakan maintainability dan readability.
6. Membuat kode modular dan reusable.
7. Menyelesaikan implementasi secara bertahap.
8. Selalu memahami konteks project sebelum membuat perubahan.

Dokumen ini merupakan sumber kebenaran utama project dan harus dijadikan referensi sebelum melakukan implementasi apa pun.
