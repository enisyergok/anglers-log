import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/fish_activity/solunar.dart';
import 'package:mobile/mera/mera_date_formatter.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';

/// Fully offline solunar / feeding-period forecast. Computed on-device from
/// date/time and GPS only — no network calls.
class MeraSolunarPage extends StatefulWidget {
  const MeraSolunarPage({super.key});

  @override
  State<MeraSolunarPage> createState() => _MeraSolunarPageState();
}

class _MeraSolunarPageState extends State<MeraSolunarPage> {
  var _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final loc = LocationMonitor.of(context).currentLatLng;
    final fmt = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: MeraColors.bg,
      body: SafeArea(
        child: loc == null
            ? Column(
                children: [
                  _header(null),
                  const Expanded(
                    child: MeraEmptyState(
                      icon: Icons.location_off_outlined,
                      title: 'Konum gerekli',
                      subtitle:
                          'Gün/ay tahmini için GPS konumunu açın. Hesaplama '
                          'tamamen cihaz üzerinde, çevrimdışı yapılır.',
                    ),
                  ),
                ],
              )
            : Builder(
                builder: (context) {
                  final day = SolunarCalculator.calculate(
                    localDate: _date,
                    lat: loc.lat,
                    lng: loc.lng,
                  );
                  final now = DateTime.now();
                  final isToday =
                      _date.year == now.year &&
                      _date.month == now.month &&
                      _date.day == now.day;
                  final score = isToday ? day.activityScoreAt(now) : null;
                  final active = isToday ? day.activePeriodAt(now) : null;
                  final next = isToday ? day.nextPeriodAfter(now) : null;

                  return Column(
                    children: [
                      _header(day),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                          children: [
                            if (score != null) _scoreCard(score, active, next, fmt),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _sunMoonCard(
                                    'GÜNEŞ',
                                    Icons.wb_sunny_outlined,
                                    'Doğuş',
                                    day.sunrise,
                                    'Batış',
                                    day.sunset,
                                    fmt,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _sunMoonCard(
                                    'AY',
                                    Icons.nightlight_round,
                                    'Doğuş',
                                    day.moonrise,
                                    'Batış',
                                    day.moonset,
                                    fmt,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            MeraCard(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.brightness_3,
                                    color: MeraColors.blue,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${day.moonPhaseLabel} · '
                                      '%${(day.moonIllumination * 100).round()} aydınlık',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            const MeraSectionHeader('BÜYÜK VE KÜÇÜK DÖNEMLER'),
                            if (day.allPeriods.isEmpty)
                              const MeraCard(
                                child: Text(
                                  'Bugün için hesaplanabilir dönem yok.',
                                  style: TextStyle(
                                    color: MeraColors.textSecondary,
                                  ),
                                ),
                              )
                            else
                              MeraCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    for (var i = 0; i < day.allPeriods.length; i++) ...[
                                      if (i > 0)
                                        const Divider(
                                          height: 1,
                                          color: MeraColors.cardBorder,
                                        ),
                                      _periodRow(day.allPeriods[i], fmt, now, isToday),
                                    ],
                                  ],
                                ),
                              ),
                            const SizedBox(height: 14),
                            const Text(
                              'Büyük dönemler ay tepe/karşı-tepe geçişi, küçük '
                              'dönemler ay doğuş/batışı etrafındadır. Geleneksel '
                              'güneş-ay (solunar) teorisine dayanır; bilimsel bir '
                              'garanti değildir. Tamamen cihaz üzerinde, '
                              'çevrimdışı hesaplanır.',
                              style: TextStyle(
                                color: MeraColors.textMuted,
                                fontSize: 11,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _header(SolunarDay? day) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Expanded(
                child: Text(
                  'Gün / Ay Takvimi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 22),
                onPressed: () => setState(
                  () => _date = _date.subtract(const Duration(days: 1)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 22),
                onPressed: () => setState(
                  () => _date = _date.add(const Duration(days: 1)),
                ),
              ),
            ],
          ),
          Text(
            MeraDateFormatter.formatWithDay(_date),
            style: const TextStyle(
              color: MeraColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard(
    int score,
    SolunarPeriod? active,
    SolunarPeriod? next,
    DateFormat fmt,
  ) {
    final color = score >= 70
        ? MeraColors.green
        : (score >= 40 ? MeraColors.warning : MeraColors.textMuted);
    final label = active != null
        ? '${active.isMajor ? 'Büyük dönem' : 'Küçük dönem'} aktif'
        : (next != null
              ? 'Sonraki: ${next.isMajor ? 'Büyük' : 'Küçük'} dönem ${fmt.format(next.start)}'
              : 'Bugün için dönem yok');
    return MeraCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
            child: Text(
              '$score',
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GÜNCEL AKTİVİTE (deneysel)',
                  style: TextStyle(
                    color: MeraColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sunMoonCard(
    String title,
    IconData icon,
    String riseLabel,
    DateTime? rise,
    String setLabel,
    DateTime? set,
    DateFormat fmt,
  ) {
    return MeraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: MeraColors.warning),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: MeraColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$riseLabel ${rise != null ? fmt.format(rise) : '—'}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            '$setLabel ${set != null ? fmt.format(set) : '—'}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _periodRow(
    SolunarPeriod p,
    DateFormat fmt,
    DateTime now,
    bool isToday,
  ) {
    final isActive = isToday && p.contains(now);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            p.isMajor ? Icons.star : Icons.star_border,
            color: p.isMajor ? MeraColors.warning : MeraColors.blue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              p.isMajor ? 'Büyük dönem' : 'Küçük dönem',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Text(
            '${fmt.format(p.start)} – ${fmt.format(p.end)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isActive ? MeraColors.green : MeraColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
