import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:adair_flutter_lib/wrappers/package_info_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/mera/mera_boat_profile.dart';
import 'package:mobile/mera/mera_no_catch_manager.dart';
import 'package:mobile/mera/mera_route_manager.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/navigation/mera_manager.dart';
import 'package:mobile/pages/about_page.dart';
import 'package:mobile/pages/backup_restore_page.dart';
import 'package:mobile/pages/map_region_page.dart';
import 'package:mobile/pages/units_page.dart';
import 'package:mobile/user_preference_manager.dart';

/// Mockup screen 12 — Ayarlar.
class MeraSettingsPage extends StatefulWidget {
  const MeraSettingsPage({super.key});

  @override
  State<MeraSettingsPage> createState() => _MeraSettingsPageState();
}

class _MeraSettingsPageState extends State<MeraSettingsPage> {
  @override
  void initState() {
    super.initState();
    MeraBoatProfileManager.get.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
    MeraRouteManager.get.ensureLoaded();
    MeraNoCatchManager.get.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final profile = MeraBoatProfileManager.get.profile;
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
                  'Profil Bilgileri',
                  '${profile.captainName} · ${profile.boatName}',
                  () => _editProfile(context),
                ),
                const Divider(height: 1, color: MeraColors.cardBorder),
                _tile(
                  context,
                  Icons.workspace_premium_outlined,
                  'Abonelik',
                  'Pro açık — tüm özellikler',
                  () => _showSubscription(context),
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
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: const Icon(
                    Icons.notifications_outlined,
                    color: MeraColors.green,
                  ),
                  title: const Text(
                    'Otomatik yedekleme',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Değişikliklerden sonra yerel yedek alır; yedek bildirimleri bu tercihe bağlıdır.',
                    style: TextStyle(
                      color: MeraColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  value: UserPreferenceManager.get.autoBackup,
                  activeThumbColor: MeraColors.green,
                  onChanged: (v) async {
                    await UserPreferenceManager.get.setAutoBackup(v);
                    if (mounted) setState(() {});
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
                  'Veri özeti · yedek · temizleme',
                  () => _showPrivacy(context),
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
              onPressed: () => _clearLocalData(context),
              child: const Text(
                'Yerel Mera verilerini temizle',
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

  Future<void> _editProfile(BuildContext context) async {
    await MeraBoatProfileManager.get.ensureLoaded();
    final p = MeraBoatProfileManager.get.profile;
    final captain = TextEditingController(text: p.captainName);
    final boat = TextEditingController(text: p.boatName);
    final fuel = TextEditingController(text: p.fuelPercent.toStringAsFixed(0));
    final cruise = TextEditingController(
      text: p.cruiseKnots.toStringAsFixed(1),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hesap yoktur — bilgiler yalnızca bu telefonda saklanır.',
              style: TextStyle(color: MeraColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: captain,
              decoration: const InputDecoration(labelText: 'Kaptan adı'),
            ),
            TextField(
              controller: boat,
              decoration: const InputDecoration(labelText: 'Tekne adı'),
            ),
            TextField(
              controller: fuel,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Yakıt % (manuel)'),
            ),
            TextField(
              controller: cruise,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Seyir hızı (kn)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final fuelVal = double.tryParse(fuel.text.trim()) ?? p.fuelPercent;
    final cruiseVal = double.tryParse(cruise.text.trim()) ?? p.cruiseKnots;
    await MeraBoatProfileManager.get.save(
      p.copyWith(
        captainName:
            captain.text.trim().isEmpty ? 'Kaptan' : captain.text.trim(),
        boatName: boat.text.trim().isEmpty ? 'Teknem' : boat.text.trim(),
        fuelPercent: fuelVal.clamp(0, 100),
        cruiseKnots: cruiseVal.clamp(0.5, 60),
      ),
    );
    if (mounted) setState(() {});
    if (context.mounted) showSuccessSnackBar(context, 'Profil kaydedildi');
  }

  Future<void> _showSubscription(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Abonelik — Pro'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mağaza aboneliği yok; özellik kilitleri kapalı.',
            ),
            SizedBox(height: 12),
            Text('· Sınırsız av / işaret / rota'),
            Text('· Bathymetry + seamark katmanları'),
            Text('· NMEA UDP dinleyici'),
            Text('· Yerel yedek / geri yükleme'),
            Text('· Çevrimdışı harita bölgeleri'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPrivacy(BuildContext context) async {
    await MeraRouteManager.get.ensureLoaded();
    await MeraNoCatchManager.get.ensureLoaded();
    final catches = CatchManager.get.entityCount;
    final routes = MeraRouteManager.get.routes.length;
    final marks = MeraManager.get.spots.length;
    final noCatch = MeraNoCatchManager.get.items.length;
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Gizlilik'),
        content: Text(
          'Veriler yalnızca bu cihazda tutulur; zorunlu bulut senkronu yoktur.\n\n'
          'Özet:\n'
          '· $catches yakalama\n'
          '· $marks mera işareti\n'
          '· $routes rota\n'
          '· $noCatch “balık alınmadı”\n\n'
          'Dışa aktarım için Yedekle kullanın.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
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
  }

  Future<void> _clearLocalData(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Yerel verileri temizle'),
        content: const Text(
          'Mera işaretleri, rotalar ve “balık alınmadı” kayıtları silinir. '
          'Av kayıtları (Catch) ve yedek ZIP’ler etkilenmez. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Temizle', style: TextStyle(color: MeraColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final marks = List.of(MeraManager.get.spots);
    for (final m in marks) {
      await MeraManager.get.remove(m.id);
    }
    await MeraRouteManager.get.ensureLoaded();
    for (final r in List.of(MeraRouteManager.get.routes)) {
      await MeraRouteManager.get.delete(r.id);
    }
    await MeraNoCatchManager.get.ensureLoaded();
    for (final n in List.of(MeraNoCatchManager.get.items)) {
      await MeraNoCatchManager.get.delete(n.id);
    }
    if (!context.mounted) return;
    showSuccessSnackBar(context, 'Yerel Mera verileri temizlendi');
    setState(() {});
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
