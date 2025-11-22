import 'package:flutter/material.dart';
import '../utils/utils.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Perjanjian Pengguna',
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
                          Icons.description,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Perjanjian Pengguna Joytify',
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
                      'Selamat datang di Joytify! Dengan menggunakan layanan kami, Anda menyetujui perjanjian ini.',
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

            // Terms Content
            _buildSection(
              '1. Penerimaan Syarat',
              'Dengan mengakses dan menggunakan aplikasi Joytify ("Layanan"), Anda menyetujui untuk terikat oleh syarat dan ketentuan dalam perjanjian ini. Jika Anda tidak menyetujui syarat-syarat ini, mohon jangan gunakan layanan kami.',
            ),

            _buildSection(
              '2. Deskripsi Layanan',
              'Joytify adalah platform streaming musik berbasis web yang memungkinkan pengguna untuk:\n\n'
              '• Mendengarkan musik dari koleksi yang tersedia\n'
              '• Membuat dan mengelola playlist pribadi\n'
              '• Menyimpan lagu favorit\n'
              '• Mengatur preferensi audio dan tampilan\n'
              '• Berinteraksi dengan komunitas musik',
            ),

            _buildSection(
              '3. Akun Pengguna',
              'Untuk menggunakan layanan Joytify, Anda perlu membuat akun dengan memberikan informasi yang akurat dan terkini. Anda bertanggung jawab untuk:\n\n'
              '• Menjaga kerahasiaan password akun Anda\n'
              '• Semua aktivitas yang terjadi di akun Anda\n'
              '• Memberitahu kami jika terjadi penggunaan tidak sah\n'
              '• Memperbarui informasi akun secara berkala',
            ),

            _buildSection(
              '4. Penggunaan yang Diizinkan',
              'Anda diizinkan menggunakan Joytify untuk:\n\n'
              '• Streaming musik untuk penggunaan pribadi\n'
              '• Membuat playlist dan koleksi musik\n'
              '• Berbagi musik melalui fitur yang disediakan\n'
              '• Memberikan feedback dan saran\n\n'
              'Penggunaan komersial memerlukan izin tertulis dari kami.',
            ),

            _buildSection(
              '5. Penggunaan yang Dilarang',
              'Anda dilarang untuk:\n\n'
              '• Mengunduh, menyalin, atau mendistribusikan konten tanpa izin\n'
              '• Menggunakan layanan untuk tujuan ilegal\n'
              '• Mengganggu atau merusak sistem kami\n'
              '• Membuat akun palsu atau menyesatkan\n'
              '• Melanggar hak cipta atau hak kekayaan intelektual\n'
              '• Mengunggah konten yang melanggar hukum',
            ),

            _buildSection(
              '6. Hak Kekayaan Intelektual',
              'Semua konten musik, desain, kode, dan materi lainnya di Joytify dilindungi oleh hak cipta dan hukum kekayaan intelektual. Kami memiliki atau memiliki lisensi untuk semua konten yang disediakan.\n\n'
              'Pengguna tetap memiliki hak atas konten yang mereka unggah, namun memberikan kami lisensi untuk menggunakan konten tersebut dalam penyediaan layanan.',
            ),

            _buildSection(
              '7. Privasi dan Data',
              'Pengumpulan dan penggunaan data pribadi Anda diatur dalam Kebijakan Privasi kami yang merupakan bagian tak terpisahkan dari perjanjian ini. Dengan menggunakan layanan, Anda menyetujui praktik yang dijelaskan dalam kebijakan tersebut.',
            ),

            _buildSection(
              '8. Pembayaran dan Berlangganan',
              'Beberapa fitur Joytify mungkin memerlukan pembayaran atau berlangganan:\n\n'
              '• Pembayaran akan diproses secara otomatis\n'
              '• Harga dapat berubah dengan pemberitahuan 30 hari\n'
              '• Pembatalan dapat dilakukan kapan saja\n'
              '• Tidak ada pengembalian untuk periode yang telah digunakan',
            ),

            _buildSection(
              '9. Penangguhan dan Penghentian',
              'Kami berhak untuk menangguhkan atau menghentikan akun Anda jika:\n\n'
              '• Melanggar syarat dan ketentuan ini\n'
              '• Melakukan aktivitas yang merugikan layanan\n'
              '• Atas permintaan Anda sendiri\n'
              '• Karena alasan teknis atau bisnis\n\n'
              'Penghentian akun akan mengakibatkan hilangnya akses ke semua konten dan data.',
            ),

            _buildSection(
              '10. Disclaimer dan Batasan Tanggung Jawab',
              'Layanan Joytify disediakan "sebagaimana adanya" tanpa jaminan apapun. Kami tidak bertanggung jawab atas:\n\n'
              '• Kerusakan langsung atau tidak langsung\n'
              '• Kehilangan data atau konten\n'
              '• Gangguan layanan atau downtime\n'
              '• Kerugian finansial atau bisnis\n\n'
              'Tanggung jawab kami terbatas pada jumlah yang Anda bayarkan dalam 12 bulan terakhir.',
            ),

            _buildSection(
              '11. Perubahan Syarat',
              'Kami dapat mengubah syarat dan ketentuan ini sewaktu-waktu. Perubahan akan diberitahukan melalui:\n\n'
              '• Notifikasi dalam aplikasi\n'
              '• Email ke alamat terdaftar\n'
              '• Pengumuman di website\n\n'
              'Dengan melanjutkan penggunaan setelah perubahan, Anda menyetujui syarat yang baru.',
            ),

            _buildSection(
              '12. Penyelesaian Sengketa',
              'Setiap sengketa yang timbul akan diselesaikan melalui:\n\n'
              '• Musyawarah dan negosiasi terlebih dahulu\n'
              '• Mediasi jika diperlukan\n'
              '• Arbitrase sebagai langkah terakhir\n'
              '• Hukum Indonesia yang berlaku\n\n'
              'Pengadilan Jakarta Pusat memiliki yurisdiksi eksklusif.',
            ),

            _buildSection(
              '13. Kontak',
              'Jika Anda memiliki pertanyaan tentang syarat dan ketentuan ini, silakan hubungi kami melalui:\n\n'
              '• Email: legal@joytify.com\n'
              '• Alamat: Jakarta, Indonesia\n'
              '• Telepon: +62-21-XXXXXXX\n'
              '• Fitur Feedback dalam aplikasi',
            ),

            const SizedBox(height: 32),

            // Agreement Footer
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
                    Icons.check_circle_outline,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Perjanjian Diterima',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dengan menggunakan Joytify, Anda telah menyetujui semua syarat dan ketentuan di atas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
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
