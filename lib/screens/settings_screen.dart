import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;
  int _cacheSize = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCacheSize();
  }

  void _loadSettings() {
    setState(() {
      _settings = SettingsService.getSettings();
    });
  }

  Future<void> _loadCacheSize() async {
    final size = await SettingsService.getCacheSize();
    if (mounted) {
      setState(() {
        _cacheSize = size;
      });
    }
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    setState(() {
      _settings = newSettings;
      _isLoading = true;
    });

    try {
      await SettingsService.saveSettings(newSettings);
      _showSuccess('Pengaturan berhasil disimpan');
    } catch (e) {
      _showError('Gagal menyimpan pengaturan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await _showConfirmDialog(
      'Hapus Cache',
      'Apakah Anda yakin ingin menghapus semua cache? Ini akan menghapus lagu dan gambar yang telah di-cache.',
    );

    if (confirmed) {
      setState(() => _isLoading = true);
      try {
        await SettingsService.clearCache();
        await _loadCacheSize();
        _showSuccess('Cache berhasil dihapus');
      } catch (e) {
        _showError('Gagal menghapus cache: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await _showConfirmDialog(
      'Reset Pengaturan',
      'Apakah Anda yakin ingin mengembalikan semua pengaturan ke default? Tindakan ini tidak dapat dibatalkan.',
    );

    if (confirmed) {
      setState(() => _isLoading = true);
      try {
        await SettingsService.resetToDefaults();
        _loadSettings();
        _showSuccess('Pengaturan berhasil direset');
      } catch (e) {
        _showError('Gagal mereset pengaturan: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.darkCard,
            title: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              content,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Ya'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.darkCard,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Audio Settings
                _buildSectionHeader('Audio'),
                _buildAudioSettings(),
                const SizedBox(height: 24),

                // Display Settings
                _buildSectionHeader('Tampilan'),
                _buildDisplaySettings(),
                const SizedBox(height: 24),

                // Storage Settings
                _buildSectionHeader('Penyimpanan'),
                _buildStorageSettings(),
                const SizedBox(height: 24),

                // Notifications Settings
                _buildSectionHeader('Notifikasi'),
                _buildNotificationSettings(),
                const SizedBox(height: 24),

                // Privacy Settings
                _buildSectionHeader('Privasi'),
                _buildPrivacySettings(),
                const SizedBox(height: 24),

                // General Settings
                _buildSectionHeader('Umum'),
                _buildGeneralSettings(),
                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader('Tentang'),
                _buildAboutSection(),
                const SizedBox(height: 24),

                // Reset Button
                _buildResetButton(),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildAudioSettings() {
    return Card(
      color: AppTheme.darkCard,
      child: Column(
        children: [
          _buildDropdownTile(
            icon: Icons.high_quality,
            title: 'Kualitas Audio',
            value: _settings.audioQuality.displayName,
            onTap: () => _showAudioQualityDialog(),
          ),
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: 'Normalisasi Volume',
            subtitle: 'Menyamakan volume antar lagu',
            value: _settings.volumeNormalization,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(volumeNormalization: value),
            ),
          ),
          _buildSliderTile(
            icon: Icons.tune,
            title: 'Crossfade',
            subtitle: '${_settings.crossfadeDuration} detik',
            value: _settings.crossfadeDuration.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(crossfadeDuration: value.round()),
            ),
          ),
          _buildSwitchTile(
            icon: Icons.skip_next,
            title: 'Gapless Playback',
            subtitle: 'Putar lagu tanpa jeda',
            value: _settings.gaplessPlayback,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(gaplessPlayback: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings() {
    return Card(
      color: AppTheme.darkCard,
      child: Column(
        children: [
          _buildDropdownTile(
            icon: Icons.palette,
            title: 'Tema',
            value: _settings.themeMode.displayName,
            onTap: () => _showThemeModeDialog(),
          ),
          // _buildDropdownTile(
          //   icon: Icons.language,
          //   title: 'Bahasa',
          //   value: _settings.language == 'id' ? 'Indonesia' : 'English',
          //   onTap: () => _showLanguageDialog(),
          // ),
          _buildDropdownTile(
            icon: Icons.text_fields,
            title: 'Ukuran Teks',
            value: _settings.textSize.displayName,
            onTap: () => _showTextSizeDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSettings() {
    return Card(
      color: AppTheme.darkCard,
      child: Column(
        children: [
          _buildSliderTile(
            icon: Icons.storage,
            title: 'Maksimal Cache',
            subtitle: '${_settings.maxCacheSize} MB',
            value: _settings.maxCacheSize.toDouble(),
            min: 100,
            max: 5000,
            divisions: 49,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(maxCacheSize: value.round()),
            ),
          ),
          _buildActionTile(
            icon: Icons.cached,
            title: 'Cache Saat Ini',
            subtitle: '$_cacheSize MB digunakan',
            actionIcon: Icons.delete_outline,
            actionText: 'Hapus',
            onActionPressed: _clearCache,
          ),
          _buildSwitchTile(
            icon: Icons.offline_pin,
            title: 'Mode Offline',
            subtitle: 'Prioritaskan lagu offline',
            value: _settings.offlineMode,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(offlineMode: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      color: AppTheme.darkCard,
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Notifikasi Push',
            subtitle: 'Terima notifikasi dari aplikasi',
            value: _settings.pushNotifications,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(pushNotifications: value),
            ),
          ),
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: 'Suara Notifikasi',
            subtitle: 'Putar suara untuk notifikasi',
            value: _settings.soundNotifications,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(soundNotifications: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      color: AppTheme.darkCard,
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.share,
            title: 'Berbagi Data',
            subtitle: 'Izinkan berbagi data penggunaan',
            value: _settings.dataSharing,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(dataSharing: value),
            ),
          ),
          _buildSwitchTile(
            icon: Icons.analytics,
            title: 'Analytics',
            subtitle: 'Bantu tingkatkan aplikasi',
            value: _settings.analytics,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(analytics: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      color: AppTheme.darkCard,
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.play_arrow,
            title: 'Auto Play',
            subtitle: 'Lanjutkan memutar lagu otomatis',
            value: _settings.autoPlay,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(autoPlay: value),
            ),
          ),
          _buildDropdownTile(
            icon: Icons.launch,
            title: 'Perilaku Startup',
            value: _settings.startupBehavior.displayName,
            onTap: () => _showStartupBehaviorDialog(),
          ),
          _buildSwitchTile(
            icon: Icons.lyrics,
            title: 'Tampilkan Lirik',
            subtitle: 'Tampilkan lirik lagu jika tersedia',
            value: _settings.showLyrics,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(showLyrics: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      color: AppTheme.darkCard,
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.info,
            title: 'Versi Aplikasi',
            subtitle: '1.0.0',
          ),
          _buildInfoTile(
            icon: Icons.code,
            title: 'Developer',
            subtitle: 'Joytify Team',
          ),
          _buildInfoTile(
            icon: Icons.flutter_dash,
            title: 'Built with',
            subtitle: 'Flutter Web',
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: _resetSettings,
        icon: const Icon(Icons.refresh, color: Colors.red),
        label: const Text(
          'Reset ke Default',
          style: TextStyle(color: Colors.red),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: AppTheme.primaryColor),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white.withOpacity(0.5),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppTheme.primaryColor),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppTheme.primaryColor,
            inactiveColor: Colors.white.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required IconData actionIcon,
    required String actionText,
    required VoidCallback onActionPressed,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
      trailing: TextButton.icon(
        onPressed: onActionPressed,
        icon: Icon(actionIcon, color: Colors.red, size: 18),
        label: Text(
          actionText,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
    );
  }

  // Dialog methods
  void _showAudioQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Kualitas Audio',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AudioQuality.values
              .map(
                (quality) => RadioListTile<AudioQuality>(
                  title: Text(
                    quality.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: quality,
                  groupValue: _settings.audioQuality,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    if (value != null) {
                      _updateSettings(_settings.copyWith(audioQuality: value));
                      Navigator.pop(context);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showThemeModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Tema',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values
              .map(
                (mode) => RadioListTile<AppThemeMode>(
                  title: Text(
                    mode.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: mode,
                  groupValue: _settings.themeMode,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    if (value != null) {
                      _updateSettings(_settings.copyWith(themeMode: value));
                      Navigator.pop(context);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Ukuran Teks',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TextSize.values
              .map(
                (size) => RadioListTile<TextSize>(
                  title: Text(
                    size.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: size,
                  groupValue: _settings.textSize,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    if (value != null) {
                      _updateSettings(_settings.copyWith(textSize: value));
                      Navigator.pop(context);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showStartupBehaviorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Perilaku Startup',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: StartupBehavior.values
              .map(
                (behavior) => RadioListTile<StartupBehavior>(
                  title: Text(
                    behavior.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: behavior,
                  groupValue: _settings.startupBehavior,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    if (value != null) {
                      _updateSettings(_settings.copyWith(startupBehavior: value));
                      Navigator.pop(context);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
