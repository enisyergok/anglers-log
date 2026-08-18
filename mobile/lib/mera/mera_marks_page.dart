import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/mera_map_interaction.dart';
import 'package:mobile/mera/mera_records_page.dart';
import 'package:mobile/mera/mera_shell.dart';
import 'package:mobile/mera/mera_stats_page.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/navigation/mera_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';

/// Siren — İşaretlerim (marks + catch records / stats entry).
class MeraMarksPage extends StatefulWidget {
  const MeraMarksPage({super.key});

  @override
  State<MeraMarksPage> createState() => _MeraMarksPageState();
}

class _MeraMarksPageState extends State<MeraMarksPage> {
  @override
  Widget build(BuildContext context) {
    return MeraPageScaffold(
      title: 'İşaretlerim',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_location_alt_outlined, size: 22),
          tooltip: 'GPS’te işaret ekle',
          onPressed: () => _addPinAtGps(context),
        ),
        IconButton(
          icon: const Icon(Icons.insights_outlined, size: 20),
          tooltip: 'İstatistikler',
          onPressed: () => present(context, const MeraStatsPage()),
        ),
        IconButton(
          icon: const Icon(Icons.menu_book_outlined, size: 20),
          tooltip: 'Yakalamalarım',
          onPressed: () => present(context, const MeraRecordsPage()),
        ),
      ],
      body: StreamBuilder(
        stream: MeraManager.get.stream,
        builder: (context, _) {
          return StreamBuilder(
            stream: FishingSpotManager.get.stream,
            builder: (context, __) {
              final meras = MeraManager.get.spots;
              final spots = FishingSpotManager.get.list()
                  .where((s) => !_nearAnyMera(s.lat, s.lng, meras))
                  .toList();
              if (meras.isEmpty && spots.isEmpty) {
                return const MeraEmptyState(
                  icon: Icons.place_outlined,
                  title: 'Henüz işaret yok',
                  subtitle:
                      '+ ile GPS konumuna pin ekleyin veya BALIK ALDIM kullanın',
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  const MeraSectionHeader('MERA İŞARETLERİ'),
                  for (final m in meras)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: ValueKey('mera-${m.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: MeraColors.danger.withValues(alpha: 0.25),
                          child: const Icon(Icons.delete, color: MeraColors.danger),
                        ),
                        confirmDismiss: (_) => _confirmDelete(context, 'Bu işareti sil?'),
                        onDismissed: (_) => _deleteMeraSynced(m),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(MeraRadii.lg),
                          onTap: () => _openMeraOnMap(m),
                          onLongPress: () => _meraActions(context, m),
                          child: MeraCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: MeraColors.danger,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _meraTitle(m),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${m.lat.toStringAsFixed(4)}°, ${m.lng.toStringAsFixed(4)}°'
                                        '${m.depthM != null ? ' · ${m.depthM!.toStringAsFixed(1)} m' : ''}',
                                        style: const TextStyle(
                                          color: MeraColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  color: MeraColors.textMuted,
                                  onPressed: () => _meraActions(context, m),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (spots.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const MeraSectionHeader('AV NOKTALARI'),
                    for (final s in spots)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: ValueKey('spot-${s.id.uuid}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            color: MeraColors.danger.withValues(alpha: 0.25),
                            child:
                                const Icon(Icons.delete, color: MeraColors.danger),
                          ),
                          confirmDismiss: (_) =>
                              _confirmDelete(context, 'Bu av noktasını sil?'),
                          onDismissed: (_) => _deleteSpotSynced(s),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(MeraRadii.lg),
                            onTap: () => _openSpotOnMap(s),
                            onLongPress: () => _spotActions(context, s),
                            child: MeraCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    color: MeraColors.blue.withValues(alpha: 0.9),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.name.isEmpty ? 'Nokta' : s.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${s.lat.toStringAsFixed(4)}°, ${s.lng.toStringAsFixed(4)}°',
                                          style: const TextStyle(
                                            color: MeraColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    color: MeraColors.textMuted,
                                    onPressed: () => _spotActions(context, s),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _meraTitle(MeraSpot m) {
    if (m.note?.isNotEmpty == true) return m.note!;
    if (m.bottomType?.isNotEmpty == true) return m.bottomType!;
    return 'Mera';
  }

  Future<bool> _confirmDelete(BuildContext context, String msg) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Sil'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: MeraColors.danger)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _openMeraOnMap(MeraSpot m) async {
    MeraShell.goHome();
    await MeraMapInteraction.instance.centerOn(
      LatLng(lat: m.lat, lng: m.lng),
      zoom: 14,
    );
  }

  Future<void> _openSpotOnMap(FishingSpot s) async {
    MeraShell.goHome();
    await MeraMapInteraction.instance.centerOn(s.latLng, zoom: 14);
  }

  Future<void> _meraActions(BuildContext context, MeraSpot m) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: MeraColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(MeraRadii.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map_outlined, color: MeraColors.blue),
              title: const Text('Haritada göster'),
              onTap: () {
                Navigator.pop(ctx);
                _openMeraOnMap(m);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: MeraColors.green),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(ctx);
                _editMera(context, m);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: MeraColors.danger),
              title: const Text('Sil'),
              onTap: () async {
                Navigator.pop(ctx);
                if (await _confirmDelete(context, 'Bu işareti sil?')) {
                  await _deleteMeraSynced(m);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _spotActions(BuildContext context, FishingSpot s) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: MeraColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(MeraRadii.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map_outlined, color: MeraColors.blue),
              title: const Text('Haritada göster'),
              onTap: () {
                Navigator.pop(ctx);
                _openSpotOnMap(s);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: MeraColors.green),
              title: const Text('Adı düzenle'),
              onTap: () {
                Navigator.pop(ctx);
                _editSpotName(context, s);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: MeraColors.danger),
              title: const Text('Sil'),
              onTap: () async {
                Navigator.pop(ctx);
                if (await _confirmDelete(context, 'Bu av noktasını sil?')) {
                  await _deleteSpotSynced(s);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editMera(BuildContext context, MeraSpot m) async {
    final note = TextEditingController(text: m.note ?? '');
    final type = TextEditingController(text: m.bottomType ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('İşareti düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: 'Not / ad'),
            ),
            TextField(
              controller: type,
              decoration: const InputDecoration(labelText: 'Tür / zemin'),
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
    if (ok == true) {
      await MeraManager.get.update(
        m.copyWith(
          note: note.text.trim().isEmpty ? null : note.text.trim(),
          bottomType: type.text.trim().isEmpty ? null : type.text.trim(),
          clearNote: note.text.trim().isEmpty,
          clearBottomType: type.text.trim().isEmpty,
        ),
      );
    }
  }

  Future<void> _editSpotName(BuildContext context, FishingSpot s) async {
    final name = TextEditingController(text: s.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Nokta adı'),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Ad'),
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
    if (ok == true) {
      s.name = name.text.trim();
      await FishingSpotManager.get.addOrUpdate(s);
      if (mounted) setState(() {});
    }
  }

  Future<void> _deleteMeraSynced(MeraSpot m) async {
    await MeraManager.get.remove(m.id);
    for (final s in FishingSpotManager.get.list()) {
      if (_near(m.lat, m.lng, s.lat, s.lng)) {
        await FishingSpotManager.get.delete(s.id);
      }
    }
  }

  Future<void> _deleteSpotSynced(FishingSpot s) async {
    await FishingSpotManager.get.delete(s.id);
    for (final m in MeraManager.get.spots) {
      if (_near(m.lat, m.lng, s.lat, s.lng)) {
        await MeraManager.get.remove(m.id);
      }
    }
  }

  static bool _nearAnyMera(double lat, double lng, List<MeraSpot> meras) {
    for (final m in meras) {
      if (_near(lat, lng, m.lat, m.lng)) return true;
    }
    return false;
  }

  static bool _near(double aLat, double aLng, double bLat, double bLng) {
    final dLat = (aLat - bLat).abs();
    final dLng = (aLng - bLng).abs();
    // ~30 m at mid-latitudes
    return dLat < 0.00028 && dLng < 0.00035;
  }

  Future<void> _addPinAtGps(BuildContext context) async {
    final loc = LocationMonitor.of(context).currentLatLng;
    if (loc == null) {
      showErrorSnackBar(context, 'Konum yok — GPS açın');
      return;
    }
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Yeni işaret'),
        content: TextField(
          controller: note,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Ad / not',
            hintText: 'Örn. İskele yanı',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final label = note.text.trim().isEmpty ? 'İşaret' : note.text.trim();
    await MeraManager.get.add(
      lat: loc.lat,
      lng: loc.lng,
      note: label,
      bottomType: 'pin',
    );
    await FishingSpotManager.get.addOrUpdate(
      FishingSpot()
        ..id = randomId()
        ..name = label
        ..lat = loc.lat
        ..lng = loc.lng,
    );
    if (!mounted) return;
    showSuccessSnackBar(context, 'İşaret eklendi');
  }
}
