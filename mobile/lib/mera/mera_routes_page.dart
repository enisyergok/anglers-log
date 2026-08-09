import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/mera/mera_route_detail_page.dart';
import 'package:mobile/mera/mera_route_manager.dart';
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
          tooltip: 'Yeni rota',
          icon: const Icon(Icons.add_circle_outline, color: MeraColors.green),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Yeni rota: Ana Sayfa → sol menüden Rotalar ile A–B çizin',
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
                  return MeraCard(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                      ],
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
