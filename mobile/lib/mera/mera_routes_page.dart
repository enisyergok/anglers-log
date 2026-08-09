import 'dart:io';

import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:adair_flutter_lib/wrappers/file_picker_wrapper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/mera/mera_map_interaction.dart';
import 'package:mobile/mera/mera_route_detail_page.dart';
import 'package:mobile/mera/mera_route_gpx.dart';
import 'package:mobile/mera/mera_route_manager.dart';
import 'package:mobile/mera/mera_shell.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';

/// Mockup screen 10 — Rotalarım.
class MeraRoutesPage extends StatefulWidget {
  const MeraRoutesPage({super.key});

  @override
  State<MeraRoutesPage> createState() => _MeraRoutesPageState();
}

class _MeraRoutesPageState extends State<MeraRoutesPage> {
  @override
  void initState() {
    super.initState();
    MeraRouteManager.get.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy', 'tr');
    return MeraPageScaffold(
      title: 'Rotalarım',
      actions: [
        IconButton(
          tooltip: 'GPX içe aktar',
          icon: const Icon(Icons.file_upload_outlined, color: MeraColors.blue),
          onPressed: _importGpx,
        ),
        IconButton(
          tooltip: 'Yeni rota',
          icon: const Icon(Icons.add_circle_outline, color: MeraColors.green),
          onPressed: () {
            MeraShell.goHome();
            MeraMapInteraction.instance.setRouteMode(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Rota modu açık — haritaya dokunarak waypoint ekleyin',
                ),
              ),
            );
          },
        ),
      ],
      body: StreamBuilder(
        stream: MeraRouteManager.get.stream,
        builder: (context, _) {
          return FutureBuilder(
            future: MeraRouteManager.get.ensureLoaded(),
            builder: (context, __) {
              final routes = MeraRouteManager.get.routes;
              if (routes.isEmpty) {
                return const MeraEmptyState(
                  icon: Icons.route,
                  title: 'Kayıtlı rota yok',
                  subtitle: 'Haritada rota çizip kaydedebilirsiniz',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: routes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final r = routes[i];
                  return Dismissible(
                    key: ValueKey(r.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: MeraColors.danger.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: MeraColors.danger),
                    ),
                    confirmDismiss: (_) async {
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
                              child: const Text(
                                'Sil',
                                style: TextStyle(color: MeraColors.danger),
                              ),
                            ),
                          ],
                        ),
                      );
                      return ok == true;
                    },
                    onDismissed: (_) => MeraRouteManager.get.delete(r.id),
                    child: MeraCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MeraRouteDetailPage(routeId: r.id),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 110,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              gradient: LinearGradient(
                                colors: [Color(0xFF0F766E), Color(0xFF1E3A5F)],
                              ),
                            ),
                            child: CustomPaint(
                              painter: _MiniRoutePainter(r),
                              child: const Center(
                                child: Icon(
                                  Icons.sailing,
                                  color: Colors.white54,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.name,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${r.distanceNm.toStringAsFixed(1)} NM · ${fmt.format(DateTime.fromMillisecondsSinceEpoch(r.createdMs))}',
                                        style: const TextStyle(
                                          color: MeraColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  color: MeraColors.textMuted,
                                  tooltip: 'Yeniden adlandır',
                                  onPressed: () => _renameRoute(context, r),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _renameRoute(BuildContext context, MeraRoute r) async {
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
  }

  Future<void> _importGpx() async {
    try {
      final result = await FilePickerWrapper.get.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['gpx', 'xml'],
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final bytes = result.files.single.bytes;
      final path = result.files.single.path;
      String gpx;
      if (bytes != null) {
        gpx = String.fromCharCodes(bytes);
      } else if (path != null) {
        gpx = await File(path).readAsString();
      } else {
        if (mounted) showErrorSnackBar(context, 'GPX okunamadı');
        return;
      }
      final pts = MeraRouteGpx.parsePoints(gpx);
      if (pts.length < 2) {
        if (mounted) {
          showErrorSnackBar(context, 'GPX içinde en az 2 nokta gerekli');
        }
        return;
      }
      final name = result.files.single.name.replaceAll(
        RegExp(r'\.gpx$', caseSensitive: false),
        '',
      );
      await MeraRouteManager.get.add(
        name: name.isEmpty ? 'GPX rota' : name,
        points: [
          for (var i = 0; i < pts.length; i++)
            MeraRoutePoint(
              lat: pts[i].latitude,
              lng: pts[i].longitude,
              label: '${i + 1}',
            ),
        ],
      );
      if (mounted) {
        showSuccessSnackBar(context, 'GPX içe aktarıldı (${pts.length} nokta)');
        setState(() {});
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }
}

class _MiniRoutePainter extends CustomPainter {
  final MeraRoute route;
  _MiniRoutePainter(this.route);

  @override
  void paint(Canvas canvas, Size size) {
    if (route.points.length < 2) return;
    final lats = route.points.map((p) => p.lat);
    final lngs = route.points.map((p) => p.lng);
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);
    final dx = (maxLng - minLng).abs() < 1e-6 ? 1.0 : (maxLng - minLng);
    final dy = (maxLat - minLat).abs() < 1e-6 ? 1.0 : (maxLat - minLat);

    final path = Path();
    for (var i = 0; i < route.points.length; i++) {
      final p = route.points[i];
      final x = ((p.lng - minLng) / dx) * (size.width * 0.7) + size.width * 0.15;
      final y =
          (1 - (p.lat - minLat) / dy) * (size.height * 0.6) + size.height * 0.2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniRoutePainter oldDelegate) =>
      oldDelegate.route.id != route.id;
}
