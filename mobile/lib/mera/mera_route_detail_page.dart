import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/mera/mera_route_manager.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/utils/map_utils.dart';

/// Mockup screen 11 — Rota detayı.
class MeraRouteDetailPage extends StatefulWidget {
  final String routeId;

  const MeraRouteDetailPage({super.key, required this.routeId});

  @override
  State<MeraRouteDetailPage> createState() => _MeraRouteDetailPageState();
}

class _MeraRouteDetailPageState extends State<MeraRouteDetailPage> {
  MeraRoute? _route;

  @override
  void initState() {
    super.initState();
    MeraRouteManager.get.ensureLoaded().then((_) {
      if (mounted) {
        setState(() => _route = MeraRouteManager.get.byId(widget.routeId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _route;
    if (r == null) {
      return const Scaffold(
        backgroundColor: MeraColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final center = r.points.isEmpty
        ? const ll.LatLng(40.9, 29.0)
        : ll.LatLng(r.points.first.lat, r.points.first.lng);
    final eta = r.estimatedAt7kn;
    final etaLabel =
        '${eta.inHours}s ${(eta.inMinutes % 60).toString().padLeft(2, '0')}dk';

    return Scaffold(
      backgroundColor: MeraColors.bg,
      appBar: AppBar(title: Text(r.name)),
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
                    _kv('Ort. Hız', '7.0 kn'),
                  ],
                ),
                const SizedBox(height: 16),
                MeraPrimaryButton(
                  label: 'Navigasyona Başla',
                  icon: Icons.navigation,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Navigasyon harita sekmesinde devam eder — Ana Sayfa’ya dönün.',
                        ),
                      ),
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
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
}
