import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/species_manager.dart';

/// Mockup screen 08 — Yakalama istatistikleri.
class MeraStatsPage extends StatefulWidget {
  const MeraStatsPage({super.key});

  @override
  State<MeraStatsPage> createState() => _MeraStatsPageState();
}

enum _Period { week, month, year, all }

class _MeraStatsPageState extends State<MeraStatsPage> {
  _Period _period = _Period.month;

  @override
  Widget build(BuildContext context) {
    return MeraPageScaffold(
      title: 'İstatistikler',
      body: StreamBuilder(
        stream: CatchManager.get.stream,
        builder: (context, _) {
          final catches = _filtered();
          final speciesMgr = SpeciesManager.of(context);

          var totalWeight = 0.0;
          var totalLength = 0.0;
          var lengthCount = 0;
          double? biggest;
          String? biggestSpecies;
          final bySpecies = <String, int>{};

          for (final c in catches) {
            if (c.hasWeight()) {
              totalWeight += c.weight.mainValue.value;
            }
            final name = speciesMgr.entity(c.speciesId)?.name ?? 'Diğer';
            if (c.hasLength()) {
              final L = c.length.mainValue.value;
              totalLength += L;
              lengthCount++;
              if (biggest == null || L > biggest) {
                biggest = L;
                biggestSpecies = name;
              }
            }
            bySpecies[name] = (bySpecies[name] ?? 0) + 1;
          }

          final avgLen = lengthCount == 0 ? 0.0 : totalLength / lengthCount;
          final sorted = bySpecies.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final colors = [
            MeraColors.warning,
            MeraColors.blue,
            const Color(0xFF4C8C72),
            const Color(0xFF324B58),
            MeraColors.green,
            MeraColors.danger,
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _periodSelector(),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.28,
                children: [
                  _statCard(
                    'Toplam Yakalama',
                    '${catches.length}',
                    Icons.set_meal,
                  ),
                  _statCard(
                    'Toplam Ağırlık',
                    '${totalWeight.toStringAsFixed(1)} kg',
                    Icons.scale,
                  ),
                  _statCard(
                    'En Büyük Balık',
                    biggest == null
                        ? '—'
                        : '${biggestSpecies ?? ''} ${biggest.toStringAsFixed(0)}cm'
                            .trim(),
                    Icons.emoji_events_outlined,
                  ),
                  _statCard(
                    'Ortalama Boy',
                    '${avgLen.toStringAsFixed(0)} cm',
                    Icons.straighten,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const MeraSectionHeader('TÜR DAĞILIMI'),
              MeraCard(
                child: sorted.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Bu dönemde yakalama yok',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: MeraColors.textSecondary),
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 42,
                                sections: [
                                  for (var i = 0; i < sorted.length; i++)
                                    PieChartSectionData(
                                      value: sorted[i].value.toDouble(),
                                      title: '${sorted[i].value}',
                                      color: colors[i % colors.length],
                                      radius: 48,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...[
                            for (var i = 0; i < sorted.length; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: colors[i % colors.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(sorted[i].key)),
                                    Text(
                                      '${sorted[i].value}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _periodSelector() {
    Widget chip(String label, _Period p) {
      final on = _period == p;
      return GestureDetector(
        onTap: () => setState(() => _period = p),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: on ? MeraColors.green : MeraColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: on ? MeraColors.green : MeraColors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: on ? Colors.white : MeraColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Bu Hafta', _Period.week),
          const SizedBox(width: 8),
          chip('Bu Ay', _Period.month),
          const SizedBox(width: 8),
          chip('Bu Yıl', _Period.year),
          const SizedBox(width: 8),
          chip('Tümü', _Period.all),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return MeraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MeraColors.green, size: 22),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: MeraColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<Catch> _filtered() {
    final all = CatchManager.get.list();
    if (_period == _Period.all) {
      return all;
    }
    final now = DateTime.now();
    late DateTime start;
    switch (_period) {
      case _Period.week:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case _Period.month:
        start = DateTime(now.year, now.month, 1);
        break;
      case _Period.year:
        start = DateTime(now.year, 1, 1);
        break;
      case _Period.all:
        start = DateTime.fromMillisecondsSinceEpoch(0);
        break;
    }
    return all
        .where((c) {
          final t = DateTime.fromMillisecondsSinceEpoch(c.timestamp.toInt());
          return !t.isBefore(start);
        })
        .toList();
  }
}
