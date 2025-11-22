# 🎵 Joytify - Aplikasi Pemutar Musik

Joytify adalah aplikasi pemutar musik modern yang mirip dengan Spotify, dibangun menggunakan Flutter. Aplikasi ini memungkinkan Anda untuk memutar musik lokal, membuat playlist, dan menikmati pengalaman mendengarkan musik yang elegan di aplikasi dan browser.

## ✨ Fitur Utama

### 🔐 Authentication
- **Login & Signup**: Sistem autentikasi sederhana tanpa backend
- **Data Lokal**: Semua data pengguna disimpan di browser menggunakan Hive (IndexedDB)
- **Validasi**: Email unik dan password minimal 6 karakter

### 🏠 Home Page
- **Kategori Musik**: Pop, Rock, Jazz, Lo-Fi, Indie
- **Grid Responsif**: Layout yang menyesuaikan ukuran layar
- **Animasi Modern**: Transisi smooth dan desain elegan

### 🎵 Music Player
- **Audio Engine**: Menggunakan just_audio yang kompatibel dengan web
- **Kontrol Lengkap**: Play/pause, next/previous, shuffle, repeat
- **Progress Bar**: Dengan waktu berjalan dan seek functionality
- **Mini Player**: Sticky player di bawah layar

### 📋 Playlist Management
- **Buat Playlist**: Playlist personal dengan nama dan deskripsi
- **Liked Songs**: Tab khusus untuk lagu favorit
- **Manage**: Rename, hapus, dan kelola playlist

### 🔍 Search
- **Pencarian Lokal**: Cari berdasarkan judul, artis, atau genre
- **Real-time**: Hasil pencarian langsung tanpa loading

### ⏰ Sleep Timer
- **Auto Stop**: Musik berhenti otomatis setelah waktu tertentu
- **Web Compatible**: Menggunakan Timer bawaan Dart

### 🎨 UI/UX
- **Modern Design**: Mirip Spotify dengan warna utama #FF6B6B
- **Dark Mode**: Tema gelap yang elegan sebagai default
- **Responsive**: Bekerja di semua ukuran layar browser
- **Animasi**: FadeIn, Hero animation, dan transisi smooth
- **Typography**: Font Poppins dan Inter

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK (versi terbaru)
- Dart SDK
- Browser modern (Chrome, Firefox, Safari, Edge)

### Langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone [repository-url]
   cd joytify
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run Web App**
   ```bash
   flutter run -d web-server --web-port 8080
   ```

5. **Buka Browser**
   Akses aplikasi di: `http://localhost:8080`

## 🎵 Menambahkan Musik

### Format Audio yang Didukung
- **MP3** (Recommended)
- **OGG** (Web compatible)
- **WAV** (File size besar)

### Langkah Menambahkan Lagu

1. **Tambah File Audio**
   - Letakkan file audio di folder `assets/audio/`
   - Nama file sebaiknya: `nama_lagu.mp3`

2. **Tambah Cover Album**
   - Letakkan gambar cover di folder `assets/covers/`
   - Nama file: `nama_lagu.jpg` (sesuai nama audio)
   - Ukuran recommended: 300x300px

3. **Update songs.json**
   - Buka file `assets/data/songs.json`
   - Tambahkan entry baru dengan format:
   ```json
   {
     "id": "unique_id",
     "title": "Judul Lagu",
     "artist": "Nama Artis",
     "genre": "Pop", // Pop, Rock, Jazz, Lo-Fi, Indie
     "duration": "3:45",
     "durationSeconds": 225,
     "audioPath": "assets/audio/nama_file.mp3",
     "coverPath": "assets/covers/nama_cover.jpg",
     "album": "Nama Album",
     "year": 2024
   }
   ```

4. **Update pubspec.yaml** (jika perlu)
   - Pastikan folder assets sudah terdaftar di pubspec.yaml
   ```yaml
   flutter:
     assets:
       - assets/audio/
       - assets/covers/
       - assets/data/songs.json
   ```

## 🛠️ Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models (Song, User, Playlist)
├── services/                 # Business logic & API services
│   ├── auth_service.dart     # Authentication
│   ├── storage_service.dart  # Local storage (Hive)
│   ├── music_service.dart    # Audio player
│   └── song_service.dart     # Song management
├── screens/                  # UI Screens
│   ├── auth_screen.dart      # Login/Signup
│   └── home_screen.dart      # Main app screen
├── widgets/                  # Reusable widgets
└── utils/                    # Themes & constants
    ├── theme.dart            # App theme
    └── constants.dart        # App constants

assets/
├── audio/                    # File audio musik
├── covers/                   # Cover album
├── images/                   # Assets gambar lainnya
└── data/
    └── songs.json           # Database lagu lokal
```

## 🎨 Kustomisasi

### Warna Tema
Edit `lib/utils/theme.dart` untuk mengubah warna:
```dart
static const Color primaryColor = Color(0xFFFF6B6B); // Pink coral
static const Color secondaryColor = Color(0xFF4ECDC4); // Teal
static const Color accentColor = Color(0xFF45B7D1); // Blue
```

### Font
Font yang digunakan:
- **Poppins**: Untuk headings dan titles
- **Inter**: Untuk body text

### Genre & Warna
Tambah genre baru di `lib/utils/theme.dart`:
```dart
static const Map<String, Color> genreColors = {
  'Pop': Color(0xFFFF6B6B),
  'Rock': Color(0xFF4ECDC4),
  // Tambah genre baru di sini
};
```

## 📱 Responsive Design

Aplikasi mendukung 3 breakpoint:
- **Mobile**: < 600px (Bottom navigation)
- **Tablet**: 600px - 1200px (Bottom navigation + larger cards)
- **Desktop**: > 1200px (Sidebar navigation)

## 🔧 Development

### Hot Reload
```bash
flutter run -d web-server --web-port 8080 --hot
```

### Build Production
```bash
flutter build web --release
```

### Debug Mode
```bash
flutter run -d web-server --web-port 8080 --debug
```

## 🐛 Troubleshooting

### Audio Tidak Bisa Diputar
- Pastikan format file MP3 atau OGG
- Check path file di songs.json sudah benar
- Pastikan file audio ada di folder assets/audio/

### UI Tidak Responsive
- Clear browser cache
- Restart Flutter app
- Check console browser untuk error

### Data Tidak Tersimpan
- Check browser support untuk IndexedDB
- Pastikan tidak dalam mode incognito/private
- Clear browser data dan restart

## 📄 Lisensi

Proyek ini dibuat untuk tujuan pembelajaran dan demonstrasi. Gunakan dengan bijak dan patuhi hak cipta musik yang Anda gunakan.

## 🤝 Kontribusi

Kontribusi selalu diterima! Silakan buat pull request atau laporkan bug melalui issues.

---

**Dibuat dengan ❤️ menggunakan Flutter Web**

*Joytify - Nikmati musik favorit Anda dengan pengalaman web yang modern dan elegan!*
