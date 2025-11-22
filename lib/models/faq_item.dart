class FAQItem {
  final String question;
  final String answer;
  final String category;

  const FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class FAQData {
  static const List<FAQItem> items = [
    // General Questions
    FAQItem(
      category: 'Umum',
      question: 'Apa itu Joytify?',
      answer: 'Joytify adalah aplikasi pemutar musik web yang memberikan pengalaman mendengarkan musik yang luar biasa. Dengan antarmuka yang modern dan fitur-fitur canggih, Joytify memungkinkan Anda menikmati musik favorit dengan kualitas tinggi langsung dari browser.',
    ),
    FAQItem(
      category: 'Umum',
      question: 'Apakah Joytify gratis?',
      answer: 'Ya, Joytify dapat digunakan secara gratis. Namun, beberapa fitur premium mungkin memerlukan berlangganan untuk pengalaman yang lebih lengkap.',
    ),
    FAQItem(
      category: 'Umum',
      question: 'Platform apa saja yang didukung?',
      answer: 'Joytify adalah aplikasi web yang dapat diakses melalui browser di berbagai platform termasuk Windows, macOS, Linux, Android, dan iOS. Pastikan browser Anda mendukung teknologi web modern.',
    ),

    // Account & Login
    FAQItem(
      category: 'Akun',
      question: 'Bagaimana cara membuat akun?',
      answer: 'Klik tombol "Daftar" di halaman login, isi informasi yang diperlukan seperti nama, email, dan password. Setelah itu, Anda dapat langsung masuk dan mulai menggunakan Joytify.',
    ),
    FAQItem(
      category: 'Akun',
      question: 'Lupa password, bagaimana?',
      answer: 'Saat ini fitur reset password sedang dalam pengembangan. Untuk sementara, Anda dapat membuat akun baru atau menghubungi tim support kami.',
    ),
    FAQItem(
      category: 'Akun',
      question: 'Bisakah mengganti email akun?',
      answer: 'Ya, Anda dapat mengganti email melalui halaman Profile. Buka menu hamburger, pilih "Profile", lalu edit field email dan simpan perubahan.',
    ),

    // Music & Playback
    FAQItem(
      category: 'Musik',
      question: 'Format audio apa yang didukung?',
      answer: 'Joytify mendukung berbagai format audio populer termasuk MP3, AAC, FLAC, dan format lainnya yang kompatibel dengan browser modern.',
    ),
    FAQItem(
      category: 'Musik',
      question: 'Bagaimana cara membuat playlist?',
      answer: 'Fitur playlist sedang dalam pengembangan. Untuk sementara, Anda dapat menggunakan fitur "Liked Songs" untuk menyimpan lagu favorit.',
    ),
    FAQItem(
      category: 'Musik',
      question: 'Bisakah mendengarkan musik offline?',
      answer: 'Fitur offline sedang dalam pengembangan. Saat ini Joytify memerlukan koneksi internet untuk streaming musik.',
    ),
    FAQItem(
      category: 'Musik',
      question: 'Kualitas audio seperti apa yang tersedia?',
      answer: 'Joytify menyediakan berbagai pilihan kualitas audio dari 96 kbps hingga lossless FLAC. Anda dapat mengatur kualitas di menu Settings > Audio > Kualitas Audio.',
    ),

    // Technical Issues
    FAQItem(
      category: 'Teknis',
      question: 'Musik tidak bisa diputar, kenapa?',
      answer: 'Pastikan koneksi internet stabil, browser mendukung HTML5 audio, dan tidak ada pemblokiran JavaScript. Coba refresh halaman atau restart browser.',
    ),
    FAQItem(
      category: 'Teknis',
      question: 'Aplikasi lambat atau tidak responsif?',
      answer: 'Coba bersihkan cache browser, tutup tab lain yang tidak perlu, atau gunakan browser yang lebih ringan. Anda juga bisa mengurangi kualitas audio di Settings.',
    ),
    FAQItem(
      category: 'Teknis',
      question: 'Bagaimana cara menghapus cache?',
      answer: 'Buka Settings > Penyimpanan > Cache Saat Ini, lalu klik tombol "Hapus". Ini akan membersihkan cache aplikasi dan mungkin memperbaiki masalah performa.',
    ),

    // Privacy & Security
    FAQItem(
      category: 'Privasi',
      question: 'Data saya aman tidak?',
      answer: 'Ya, Joytify menggunakan enkripsi untuk melindungi data Anda. Kami tidak membagikan informasi pribadi kepada pihak ketiga tanpa persetujuan Anda.',
    ),
    FAQItem(
      category: 'Privasi',
      question: 'Apa saja data yang dikumpulkan?',
      answer: 'Kami hanya mengumpulkan data yang diperlukan untuk memberikan layanan, seperti preferensi musik, riwayat pemutaran, dan informasi akun dasar. Detail lengkap ada di Kebijakan Privasi.',
    ),

    // Features
    FAQItem(
      category: 'Fitur',
      question: 'Apa itu Sleep Timer?',
      answer: 'Sleep Timer adalah fitur yang memungkinkan musik berhenti otomatis setelah waktu tertentu. Berguna saat Anda ingin tertidur sambil mendengarkan musik.',
    ),
    FAQItem(
      category: 'Fitur',
      question: 'Bagaimana cara menggunakan crossfade?',
      answer: 'Crossfade membuat transisi halus antar lagu. Atur durasi crossfade di Settings > Audio > Crossfade. Semakin tinggi nilai, semakin halus transisinya.',
    ),
  ];

  static List<String> get categories {
    final cats = items.map((item) => item.category).toSet().toList();
    cats.sort();
    return cats;
  }

  static List<FAQItem> getByCategory(String category) {
    return items.where((item) => item.category == category).toList();
  }
}
