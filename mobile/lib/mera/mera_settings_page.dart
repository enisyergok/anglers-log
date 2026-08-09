import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/wrappers/package_info_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/pages/about_page.dart';
import 'package:mobile/pages/backup_restore_page.dart';
import 'package:mobile/pages/map_region_page.dart';
import 'package:mobile/pages/units_page.dart';
import 'package:mobile/user_preference_manager.dart';

/// Mockup screen 12 — Ayarlar.
class MeraSettingsPage extends StatelessWidget {
  const MeraSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MeraPageScaffold(
      title: 'Ayarlar',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const MeraSectionHeader('HESAP'),
          MeraCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tile(
                  context,
                  Icons.person_outline,
                  'Profil',
                  'Yerel kullanım — hesap gerekmez',
                  null,
                ),
                const Divider(height: 1, color: MeraColors.cardBorder),
                _tile(
                  context,
                  Icons.workspace_premium_outlined,
                  'Abonelik',
                  'Tüm özellikler açık (Pro)',
                  null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const MeraSectionHeader('UYGULAMA'),
          MeraCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tile(
                  context,
                  Icons.straighten,
                  'Birimler',
                  'Metrik / İngiliz',
                  () => present(context, UnitsPage()),
                ),
                const Divider(height: 1, color: MeraColors.cardBorder),
                _tile(
                  context,
                  Icons.map_outlined,
                  'Harita ayarları',
                  'Çevrimdışı bölgeler (MBTiles)',
                  () => present(context, const MapRegionPage()),
                ),
                const Divider(height: 1, color: MeraColors.cardBorder),
                _tile(
                  context,
                  Icons.notifications_outlined,
                  'Bildirimler',
                  UserPreferenceManager.get.autoBackup
                      ? 'Yedekleme bildirimleri açık'
                      : 'Yedekleme bildirimleri kapalı',
                  () {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: MeraColors.card,
                        title: const Text('Bildirimler'),
                        content: Text(
                          UserPreferenceManager.get.autoBackup
                              ? 'Otomatik yedekleme açık; bildirim izni ayarlardan yönetilir.'
                              : 'Otomatik yedekleme kapalı. Açmak için Yedekle ekranını kullanın.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Tamam'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              present(context, BackupPage());
                            },
                            child: const Text('Yedekle'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: MeraColors.cardBorder),
                _tile(
                  context,
                  Icons.cloud_upload_outlined,
                  'Yedekle / Geri yükle',
                  'Yerel ZIP dosyası',
                  () => present(context, BackupPage()),
                ),
                const Divider(height: 1, color: MeraColors.cardBorder),
                _tile(
                  context,
                  Icons.lock_outline,
                  'Gizlilik ve güvenlik',
                  'Veriler yalnızca bu cihazda',
                  null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const MeraSectionHeader('HAKKINDA'),
          MeraCard(
            padding: EdgeInsets.zero,
            child: FutureBuilder(
              future: PackageInfoWrapper.get.fromPlatform(),
              builder: (context, snap) {
                final v = snap.data?.version ?? '1.0.0';
                return _tile(
                  context,
                  Icons.info_outline,
                  'Mera Asistanı',
                  'Sürüm $v',
                  () => present(context, AboutPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: MeraColors.card,
                    title: const Text('Çıkış'),
                    content: const Text(
                      'Bu uygulama çevrimdışı çalışır; hesap oturumu yoktur. '
                      'Verilerinizi silmek için yedekten geri yükleme veya '
                      'uygulama verisini temizleme kullanın.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(
                  color: MeraColors.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: MeraColors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: MeraColors.textSecondary, fontSize: 12),
      ),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right, color: MeraColors.textMuted),
    );
  }
}
