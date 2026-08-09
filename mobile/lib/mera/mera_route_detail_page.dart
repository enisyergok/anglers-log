import 'dart:io';

import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/mera/mera_boat_profile.dart';
import 'package:mobile/mera/mera_map_interaction.dart';
import 'package:mobile/mera/mera_route_gpx.dart';
import 'package:mobile/mera/mera_route_manager.dart';
import 'package:mobile/mera/mera_shell.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mockup screen 11 — Rota detayı.
class MeraRouteDetailPage extends StatefulWidget {
  final String routeId;

  const MeraRouteDetailPage({super.key, required this.routeId});

  @override
  State<MeraRouteDetailPage> createState() => _MeraRouteDetailPageState();
}

class _MeraRouteDetailPageState extends State<MeraRouteDetailPage> {
  MeraRoute? _route;
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.wait([
      MeraRouteManager.get.ensureLoaded(),
      MeraBoatProfileManager.get.ensureLoaded(),
    ]).then((_) {
      if (mounted) {
        setState(() {
          _route = MeraRouteManager.get.byId(widget.routeId);
          _loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _route;
    if (_loaded && r == null) {
      return Scaffold(
        backgroundColor: MeraColors.bg,
        appBar: AppBar(title: const Text('Rota')),
        body: const MeraEmptyState(
          icon: Icons.route,
          title: 'Rota bulunamadı',
          subtitle: 'Listeye dönüp başka bir rota seçin',
        ),
      );
    }
    if (r == null) {
      return const Scaffold(
        backgroundColor: MeraColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final center = r.points.isEmpty
        ? const ll.LatLng(40.9, 29.0)
        : ll.LatLng(r.points.first.lat, r.points.first.lng);
    final cruise = MeraBoatProfileManager.get.profile.cruiseKnots;
    final eta = r.estimatedAt(knots: cruise);
    final h = eta.inHours;
    final m = eta.inMinutes % 60;
    final etaLabel = h > 0 ? '$h sa ${m.toString().padLeft(2, '0')} dk' : '$m dk';

    return Scaffold(
      backgroundColor: MeraColors.bg,
      appBar: AppBar(
        title: Text(r.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'GPX paylaş',
            onPressed: () => _exportGpx(context, r),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Yeniden adlandır',
            onPressed: () => _rename(context, r),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: MeraColors.danger),
            tooltip: 'Sil',
            onPressed: () => _delete(context, r),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: fm.FlutterMap(
              options: fm.MapOptions(
                initialCenter: center,
                initialZoom: 10,
              ),
              children: [
                fm.TileLayer(
                  urlTemplate: MapType.light.url,
                  userAgentPackageName: mapTileUserAgentPackageName,
                ),
                fm.PolylineLayer(
                  polylines: [
                    fm.Polyline(
                      points: r.points
                          .map((p) => ll.LatLng(p.lat, p.lng))
                          .toList(),
                      color: MeraColors.green,
                      strokeWidth: 4,
                    ),
                  ],
                ),
                fm.MarkerLayer(
                  markers: [
                    for (var i = 0; i < r.points.length; i++)
                      fm.Marker(
                        point: ll.LatLng(r.points[i].lat, r.points[i].lng),
                        width: 28,
                        height: 28,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: MeraColors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: MeraColors.card,
              border: Border(top: BorderSide(color: MeraColors.cardBorder)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _kv('Mesafe', '${r.distanceNm.toStringAsFixed(1)} NM'),
                    _kv('Süre', etaLabel),
                    _kv('Ort. Hız', '${cruise.toStringAsFixed(1)} kn'),
                  ],
                ),
                const SizedBox(height: 16),
                MeraPrimaryButton(
                  label: 'WP Rehberi Başlat',
                  icon: Icons.navigation,
                  onPressed: () async {
                    final route = r;
                    final pts = route.points
                        .map((p) => ll.LatLng(p.lat, p.lng))
                        .toList();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    MeraShell.goHome();
                    await MeraMapInteraction.instance.startNavigation(
                      pts,
                      name: route.name,
                    );
                  },
                ),
                TextButton(
                  onPressed: () async {
                    final route = r;
                    final pts = route.points
                        .map((p) => ll.LatLng(p.lat, p.lng))
                        .toList();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    MeraShell.goHome();
                    await MeraMapInteraction.instance.beginEditRoute(
                      routeId: route.id,
                      points: pts,
                    );
                  },
                  child: const Text(
                    'Rota Düzenle',
                    style: TextStyle(
                      color: MeraColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Expanded(
      child: Column(
        children: [
          Text(
            v,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            k,
            style: const TextStyle(
              color: MeraColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportGpx(BuildContext context, MeraRoute r) async {
    try {
      final gpx = MeraRouteGpx.export(r);
      final dir = await getTemporaryDirectory();
      final safe = r.name.replaceAll(RegExp(r'[^\w\-]+'), '_');
      final path = p.join(dir.path, '$safe.gpx');
      await File(path).writeAsString(gpx);
      if (!context.mounted) return;
      await SharePlusWrapper.of(context).shareFiles([XFile(path)], null);
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, 'GPX: $e');
      }
    }
  }

  Future<void> _rename(BuildContext context, MeraRoute r) async {
    final ctrl = TextEditingController(text: r.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Rota adı'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
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
    if (ok != true) return;
    await MeraRouteManager.get.rename(r.id, ctrl.text);
    if (!mounted) return;
    setState(() => _route = MeraRouteManager.get.byId(widget.routeId));
  }

  Future<void> _delete(BuildContext context, MeraRoute r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Rotayı sil'),
        content: Text('"${r.name}" silinsin mi?'),
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
    if (ok != true) return;
    await MeraRouteManager.get.delete(r.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
