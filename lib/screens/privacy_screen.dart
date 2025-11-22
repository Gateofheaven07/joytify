import 'package:flutter/material.dart';
import '../utils/utils.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Kebijakan Privasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.darkCard,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              color: AppTheme.darkCard,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Kebijakan Privasi Joytify',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terakhir diperbarui: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kami menghormati privasi Anda dan berkomitmen untuk melindungi data pribadi Anda.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Privacy Content
            _buildSection(
              '1. Informasi yang Kami Kumpulkan',
              'Kami mengumpulkan informasi dalam beberapa kategori:\n\n'
              '**Informasi Akun:**\n'
              '• Nama lengkap dan alamat email\n'
              '• Password (disimpan dalam bentuk terenkripsi)\n'
              '• Tanggal pembuatan akun\n'
              '• Preferensi pengguna\n\n'
              '**Data Penggunaan:**\n'
              '• Riwayat pemutaran musik\n'
              '• Playlist dan lagu favorit\n'
              '• Pengaturan aplikasi\n'
              '• Interaksi dengan fitur aplikasi\n\n'
              '**Data Teknis:**\n'
              '• Alamat IP dan informasi browser\n'
              '• Data analytics penggunaan\n'
              '• Log error dan performa aplikasi',
            ),

            _buildSection(
              '2. Bagaimana Kami Menggunakan Informasi',
              'Informasi yang dikumpulkan digunakan untuk:\n\n'
              '**Penyediaan Layanan:**\n'
              '• Autentikasi dan keamanan akun\n'
              '• Personalisasi pengalaman musik\n'
              '• Rekomendasi konten yang relevan\n'
              '• Sinkronisasi data antar perangkat\n\n'
              '**Peningkatan Layanan:**\n'
              '• Analisis penggunaan untuk pengembangan fitur\n'
              '• Pemecahan masalah teknis\n'
              '• Optimasi performa aplikasi\n\n'
              '**Komunikasi:**\n'
              '• Notifikasi penting tentang layanan\n'
              '• Respon terhadap feedback pengguna\n'
              '• Update dan pengumuman produk',
            ),

            _buildSection(
              '3. Penyimpanan dan Keamanan Data',
              '**Lokasi Penyimpanan:**\n'
              '• Data disimpan secara lokal di browser Anda\n'
              '• Menggunakan teknologi IndexedDB/LocalStorage\n'
              '• Tidak ada server eksternal yang menyimpan data pribadi\n\n'
              '**Keamanan Data:**\n'
              '• Password di-hash menggunakan SHA-256\n'
              '• Data sensitif dienkripsi\n'
              '• Akses data dibatasi hanya untuk fungsi yang diperlukan\n'
              '• Tidak ada transmisi data tanpa enkripsi\n\n'
              '**Retensi Data:**\n'
              '• Data disimpan selama akun aktif\n'
              '• Data dihapus saat pengguna menghapus akun\n'
              '• Cache dapat dibersihkan melalui pengaturan browser',
            ),

            _buildSection(
              '4. Berbagi Informasi dengan Pihak Ketiga',
              'Kami TIDAK membagikan informasi pribadi Anda kepada pihak ketiga, kecuali:\n\n'
              '**Situasi Hukum:**\n'
              '• Jika diwajibkan oleh hukum yang berlaku\n'
              '• Untuk melindungi hak dan keamanan pengguna lain\n'
              '• Dalam kasus investigasi aktivitas ilegal\n\n'
              '**Penyedia Layanan:**\n'
              '• CDN untuk pengiriman konten (tanpa data pribadi)\n'
              '• Analytics tools untuk statistik umum (data anonim)\n'
              '• Layanan hosting dan infrastruktur\n\n'
              '**Catatan Penting:**\n'
              'Karena Joytify menggunakan penyimpanan lokal, sebagian besar data Anda tidak pernah meninggalkan perangkat Anda.',
            ),

            _buildSection(
              '5. Hak Pengguna atas Data',
              'Sebagai pengguna, Anda memiliki hak untuk:\n\n'
              '**Akses Data:**\n'
              '• Melihat semua data yang kami kumpulkan\n'
              '• Mengunduh copy data pribadi Anda\n'
              '• Mengetahui bagaimana data digunakan\n\n'
              '**Kontrol Data:**\n'
              '• Mengedit informasi profil kapan saja\n'
              '• Menghapus riwayat pemutaran\n'
              '• Mengatur preferensi privasi\n'
              '• Menonaktifkan analytics (di Settings)\n\n'
              '**Penghapusan Data:**\n'
              '• Menghapus akun dan semua data terkait\n'
              '• Membersihkan cache dan data lokal\n'
              '• Meminta penghapusan data dari server (jika ada)',
            ),

            _buildSection(
              '6. Cookies dan Teknologi Pelacakan',
              '**Penggunaan Cookies:**\n'
              '• Session cookies untuk autentikasi\n'
              '• Preference cookies untuk pengaturan\n'
              '• Analytics cookies (dapat dinonaktifkan)\n\n'
              '**Local Storage:**\n'
              '• Menyimpan data aplikasi secara lokal\n'
              '• Cache musik dan gambar untuk performa\n'
              '• Pengaturan dan preferensi pengguna\n\n'
              '**Kontrol Pengguna:**\n'
              '• Anda dapat membersihkan cookies melalui browser\n'
              '• Pengaturan privasi dapat disesuaikan di Settings\n'
              '• Mode incognito browser akan membatasi penyimpanan',
            ),

            _buildSection(
              '7. Privasi Anak-anak',
              'Joytify tidak secara khusus ditujukan untuk anak-anak di bawah 13 tahun:\n\n'
              '• Kami tidak secara sengaja mengumpulkan data dari anak-anak\n'
              '• Orang tua bertanggung jawab mengawasi penggunaan internet anak\n'
              '• Jika kami mengetahui ada data anak di bawah umur, akan segera dihapus\n'
              '• Orang tua dapat menghubungi kami untuk penghapusan data anak',
            ),

            _buildSection(
              '8. Transfer Data Internasional',
              'Karena sifat aplikasi web:\n\n'
              '• Data utama disimpan secara lokal di perangkat Anda\n'
              '• Konten musik mungkin disajikan dari CDN global\n'
              '• Analytics data (jika diaktifkan) mungkin diproses di luar negeri\n'
              '• Kami memastikan perlindungan data sesuai standar internasional',
            ),

            _buildSection(
              '9. Perubahan Kebijakan Privasi',
              'Kami dapat memperbarui kebijakan ini untuk:\n\n'
              '• Mematuhi perubahan regulasi\n'
              '• Mencerminkan praktik baru dalam layanan\n'
              '• Meningkatkan transparansi\n\n'
              '**Pemberitahuan Perubahan:**\n'
              '• Notifikasi dalam aplikasi\n'
              '• Email ke pengguna terdaftar\n'
              '• Pengumuman di website\n'
              '• Periode review 30 hari sebelum berlaku',
            ),

            _buildSection(
              '10. Kontak dan Pengaduan',
              'Untuk pertanyaan tentang privasi atau pengaduan:\n\n'
              '**Tim Privasi:**\n'
              '• Email: privacy@joytify.com\n'
              '• Response time: maksimal 7 hari kerja\n'
              '• Bahasa: Indonesia dan Inggris\n\n'
              '**Alamat Kantor:**\n'
              '• Jakarta, Indonesia\n'
              '• Telepon: +62-21-XXXXXXX\n\n'
              '**Fitur dalam Aplikasi:**\n'
              '• Menu Feedback untuk pelaporan masalah privasi\n'
              '• Settings > Privasi untuk kontrol data',
            ),

            const SizedBox(height: 32),

            // Privacy Principles
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.security,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Prinsip Privasi Kami',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Transparansi dalam pengumpulan data\n'
                    '• Minimalisasi data yang dikumpulkan\n'
                    '• Keamanan data sebagai prioritas utama\n'
                    '• Kontrol penuh kepada pengguna\n'
                    '• Tidak menjual data pribadi',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Card(
      color: AppTheme.darkCard,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
