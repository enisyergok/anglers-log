import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/fish_activity/env_provider.dart';
import 'package:mobile/mera/fish_activity/models.dart';
import 'package:mobile/mera/fish_activity/score_gauge.dart';
import 'package:mobile/mera/fish_activity/service.dart';
import 'package:mobile/mera/fish_activity/species_profiles.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/mera/siren_fish_art.dart';
import 'package:mobile/mera/turkish_sea_fish_catalog.dart';

/// Siren — Hava / Deniz / Balık Aktivitesi / Av Penceresi (Fish Activity Intelligence).
class MeraWeatherPage extends StatefulWidget {
  const MeraWeatherPage({super.key});

  @override
  State<MeraWeatherPage> createState() => _MeraWeatherPageState();
}

enum _Tab { weather, sea, activity, window }

class _MeraWeatherPageState extends State<MeraWeatherPage> {
  final _service = FishActivityService();
  var _tab = _Tab.weather;
  var _species = SpeciesActivityProfiles.cipura;
  Future<({FishEnvSnapshot env, FishActivityResult activity})>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<({FishEnvSnapshot env, FishActivityResult activity})> _load({
    bool force = false,
  }) async {
    final loc = LocationMonitor.of(context).currentLatLng;
    final lat = loc?.lat ?? 41.01;
    final lng = loc?.lng ?? 28.98;
    return _service.load(
      lat: lat,
      lng: lng,
      species: _species,
      forceRefresh: force,
    );
  }

  void _refresh() => setState(() => _future = _load(force: true));

  void _selectSpecies(SpeciesActivityProfile p) {
    setState(() {
      _species = p;
      if (_service.lastEnv != null) {
        _service.recalculate(p);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeraColors.bg,
      body: SafeArea(
        child: FutureBuilder(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError || !snap.hasData) {
              return Column(
                children: [
                  _header(null, null),
                  Expanded(
                    child: MeraEmptyState(
                      icon: Icons.cloud_off,
                      title: 'Veri alınamadı',
                      subtitle: snap.error?.toString() ?? 'Bağlantıyı kontrol edin',
                    ),
                  ),
                ],
              );
            }
            final env = snap.data!.env;
            final activity = _service.lastResult ?? snap.data!.activity;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(env, activity),
                _tabs(),
                if (_tab == _Tab.activity || _tab == _Tab.window)
                  _speciesPicker(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: MeraColors.blue,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      children: [
                        switch (_tab) {
                          _Tab.weather => _weatherBody(env),
                          _Tab.sea => _seaBody(env),
                          _Tab.activity => _activityBody(env, activity),
                          _Tab.window => _windowBody(activity),
                        },
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(FishEnvSnapshot? env, FishActivityResult? activity) {
    final place = env?.placeName ?? 'Mevcut konum';
    final lat = env?.lat;
    final lng = env?.lng;
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
                  'Balık Aktivitesi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 22),
                onPressed: _refresh,
              ),
            ],
          ),
          Text(
            place,
            style: const TextStyle(
              color: MeraColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (lat != null && lng != null)
            Text(
              '${lat.abs().toStringAsFixed(3)}° ${lat >= 0 ? 'N' : 'S'}  '
              '${lng.abs().toStringAsFixed(3)}° ${lng >= 0 ? 'E' : 'W'}',
              style: const TextStyle(
                color: MeraColors.textMuted,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabs() {
    Widget chip(_Tab t, String label) {
      final on = _tab == t;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _tab = t),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: on ? MeraColors.textPrimary : MeraColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  color: on ? MeraColors.blue : Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          chip(_Tab.weather, 'Hava'),
          chip(_Tab.sea, 'Deniz'),
          chip(_Tab.activity, 'Balık Aktivitesi'),
          chip(_Tab.window, 'Av Penceresi'),
        ],
      ),
    );
  }

  Widget _speciesPicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: MeraCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onTap: _openSpeciesSheet,
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 40,
              child: SirenFishArt.image(
                speciesName: _species.nameTr,
                height: 36,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _species.nameTr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    TurkishSeaFishCatalog.match(_species.nameTr)?.scientificName ??
                        _species.scientificName,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: MeraColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.expand_more, color: MeraColors.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _openSpeciesSheet() async {
    final picked = await showModalBottomSheet<SpeciesActivityProfile>(
      context: context,
      backgroundColor: MeraColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tür seçin',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            for (final p in SpeciesActivityProfiles.primary)
              ListTile(
                leading: SizedBox(
                  width: 48,
                  child: SirenFishArt.image(speciesName: p.nameTr, height: 32),
                ),
                title: Text(p.nameTr),
                subtitle: Text(
                  p.scientificName,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                trailing: p.key == _species.key
                    ? const Icon(Icons.check, color: MeraColors.green)
                    : null,
                onTap: () => Navigator.pop(ctx, p),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) _selectSpecies(picked);
  }

  // ─── Hava ─────────────────────────────────────────────
  Widget _weatherBody(FishEnvSnapshot env) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MeraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                env.placeName ?? 'Konum',
                style: const TextStyle(color: MeraColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    env.airTempC == null
                        ? '—'
                        : '${env.airTempC!.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _wmoIcon(env.weatherCode),
                    size: 48,
                    color: MeraColors.blue,
                  ),
                ],
              ),
              Text(
                _wmoLabel(env.weatherCode),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metric(
                'Rüzgâr',
                env.windKmh == null
                    ? 'Veri yok'
                    : '${(env.windKmh! / 1.852).toStringAsFixed(0)} kn',
                Icons.air,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                'Basınç',
                env.pressureHpa == null
                    ? 'Veri yok'
                    : '${env.pressureHpa!.toStringAsFixed(0)} hPa',
                Icons.speed,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                'Nem',
                env.humidity == null
                    ? 'Veri yok'
                    : '%${env.humidity!.toStringAsFixed(0)}',
                Icons.water_drop_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metric(
                'Bulut',
                env.cloudCover == null
                    ? 'Veri yok'
                    : '%${env.cloudCover!.round()}',
                Icons.cloud_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                'Trend 6s',
                env.pressureChange6h == null
                    ? 'Veri yok'
                    : '${env.pressureChange6h! >= 0 ? '+' : ''}${env.pressureChange6h!.toStringAsFixed(1)} hPa',
                Icons.trending_down,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                'Ay',
                env.moonPhaseLabel ?? 'Veri yok',
                Icons.nightlight_round,
              ),
            ),
          ],
        ),
        if (env.sunrise != null || env.sunset != null) ...[
          const SizedBox(height: 12),
          MeraCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Doğuş ${env.sunrise != null ? DateFormat('HH:mm').format(env.sunrise!) : '—'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Batış ${env.sunset != null ? DateFormat('HH:mm').format(env.sunset!) : '—'}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Güncelleme ${DateFormat('HH:mm').format(env.fetchedAt)}',
          style: const TextStyle(color: MeraColors.textMuted, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── Deniz ────────────────────────────────────────────
  Widget _seaBody(FishEnvSnapshot env) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MeraSectionHeader('DENİZ KOŞULLARI'),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: [
            _metric(
              'Dalga Yüksekliği',
              env.waveHeightM == null
                  ? 'Veri yok'
                  : '${env.waveHeightM!.toStringAsFixed(1)} m',
              Icons.waves,
            ),
            _metric(
              'Dalga Periyodu',
              env.wavePeriodS == null
                  ? 'Veri yok'
                  : '${env.wavePeriodS!.toStringAsFixed(1)} s',
              Icons.timelapse,
            ),
            _metric(
              'Deniz Durumu',
              FishEnvProvider.seaState(env.waveHeightM),
              Icons.sailing,
            ),
            _metric(
              'Yüzey Sıcaklığı',
              env.waterTempC == null
                  ? 'Veri yok'
                  : '${env.waterTempC!.toStringAsFixed(1)} °C',
              Icons.thermostat,
            ),
            _metric(
              'Tuzluluk',
              env.salinityPsu == null
                  ? 'Veri yok'
                  : '${env.salinityPsu!.toStringAsFixed(1)} PSU',
              Icons.opacity,
            ),
            _metric(
              'Berraklık',
              env.clarityM == null ? 'Veri yok' : '${env.clarityM} m',
              Icons.visibility,
            ),
          ],
        ),
        const SizedBox(height: 14),
        const MeraSectionHeader('AKINTI'),
        MeraCard(
          child: env.currentSpeedKn == null
              ? const Text(
                  'Akıntı verisi mevcut değil',
                  style: TextStyle(color: MeraColors.textSecondary),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${env.currentSpeedKn!.toStringAsFixed(2)} kn → '
                      '${FishEnvProvider.compass(env.currentDirDeg)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Open-Meteo okyanus akıntısı (varsa). Sahte vektör üretilmez.',
                      style: TextStyle(
                        color: MeraColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 10),
        MeraCard(
          child: Row(
            children: [
              const Icon(Icons.air, color: MeraColors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Çözünmüş Oksijen: '
                  '${env.dissolvedOxygenMgL == null ? 'Veri yok' : '${env.dissolvedOxygenMgL} mg/L'}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Aktivite ─────────────────────────────────────────
  Widget _activityBody(FishEnvSnapshot env, FishActivityResult a) {
    final palette = ActivityGaugePalette.forScore(a.score);
    final level = FishActivityResult.levelLabel(a.level);
    final window = a.bestWindow;
    final fmt = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MeraCard(
          child: Row(
            children: [
              ActivityScoreGauge(score: a.score, palette: palette),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AKTİVİTE SKORU',
                      style: TextStyle(
                        color: MeraColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.toUpperCase(),
                      style: TextStyle(
                        color: palette.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _levelBlurb(a.level, a.speciesName),
                      style: const TextStyle(
                        color: MeraColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (window != null) ...[
          const SizedBox(height: 10),
          MeraCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  a.dayPhase == DayPhase.sunset || a.dayPhase == DayPhase.dusk
                      ? Icons.wb_twilight
                      : Icons.schedule,
                  color: MeraColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EN İYİ AV PENCERESİ',
                        style: TextStyle(
                          color: MeraColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${fmt.format(window.start)} – ${fmt.format(window.end)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        const MeraSectionHeader('KOŞUL ÖZETİ'),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.05,
          children: [
            _mini(
              'Su Sıc.',
              env.waterTempC == null
                  ? '—'
                  : '${env.waterTempC!.toStringAsFixed(1)}°',
            ),
            _mini(
              'Rüzgâr',
              env.windKmh == null
                  ? '—'
                  : '${(env.windKmh! / 1.852).toStringAsFixed(0)} kn',
            ),
            _mini(
              'Basınç',
              env.pressureHpa == null
                  ? '—'
                  : env.pressureHpa!.toStringAsFixed(0),
            ),
            _mini(
              'Akıntı',
              env.currentSpeedKn == null
                  ? '—'
                  : '${env.currentSpeedKn!.toStringAsFixed(1)} kn',
            ),
            _mini('Ay', env.moonPhaseLabel ?? '—'),
            _mini(
              'O₂',
              env.dissolvedOxygenMgL == null ? 'Veri yok' : 'mg/L',
            ),
          ],
        ),
        const SizedBox(height: 14),
        const MeraSectionHeader('KOŞULLARIN AKTİVİTEYE ETKİSİ'),
        MeraCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < a.factors.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: MeraColors.cardBorder),
                _factorRow(a.factors[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        MeraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEDEN ${level.toUpperCase()}?',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: MeraColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                a.explanation,
                style: const TextStyle(
                  color: MeraColors.textSecondary,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        MeraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: _confidenceColor(a.confidence),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'GÜVEN SEVİYESİ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _confidenceLabel(a.confidence),
                    style: TextStyle(
                      color: _confidenceColor(a.confidence),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _confidenceBar(a.confidence),
              const SizedBox(height: 10),
              Text(
                a.disclaimer,
                style: const TextStyle(
                  color: MeraColors.textMuted,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Veri güncelleme ${DateFormat('HH:mm').format(env.fetchedAt)}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: MeraColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _factorRow(ActivityFactor f) {
    final pos = f.contribution >= 0;
    final barW = (f.contribution.abs().clamp(0, 20) / 20) * 72;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(_factorIcon(f.id), color: MeraColors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  f.available ? f.valueLabel : 'Veri yok',
                  style: const TextStyle(
                    color: MeraColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (f.available) ...[
            Container(
              width: 72,
              height: 6,
              alignment: pos ? Alignment.centerLeft : Alignment.centerRight,
              decoration: BoxDecoration(
                color: MeraColors.borderSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Container(
                width: barW,
                decoration: BoxDecoration(
                  color: pos ? MeraColors.green : MeraColors.danger,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              child: Text(
                '${f.contribution >= 0 ? '+' : ''}${f.contribution.toStringAsFixed(0)}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: pos ? MeraColors.green : MeraColors.danger,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ] else
            const Text(
              '—',
              style: TextStyle(color: MeraColors.textMuted),
            ),
        ],
      ),
    );
  }

  // ─── Av penceresi ─────────────────────────────────────
  Widget _windowBody(FishActivityResult a) {
    final pts = a.hourly;
    final window = a.bestWindow;
    final fmt = DateFormat('HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MeraSectionHeader('24 SAATLİK AKTİVİTE TAHMİNİ'),
        MeraCard(
          child: SizedBox(
            height: 200,
            child: pts.length < 2
                ? const Center(child: Text('Grafik için veri yetersiz'))
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: MeraColors.cardBorder.withValues(alpha: 0.6),
                          strokeWidth: 1,
                        ),
                        drawVerticalLine: false,
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 25,
                            getTitlesWidget: (v, _) => Text(
                              v.toInt().toString(),
                              style: const TextStyle(
                                color: MeraColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 6,
                            getTitlesWidget: (v, _) {
                              final i = v.round();
                              if (i < 0 || i >= pts.length) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                DateFormat('HH').format(pts[i].time),
                                style: const TextStyle(
                                  color: MeraColors.textMuted,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < pts.length; i++)
                              FlSpot(i.toDouble(), pts[i].score),
                          ],
                          isCurved: true,
                          color: MeraColors.green,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                MeraColors.green.withValues(alpha: 0.35),
                                MeraColors.warning.withValues(alpha: 0.08),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (window != null) ...[
          const SizedBox(height: 12),
          MeraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EN İYİ AV PENCERESİ',
                  style: TextStyle(
                    color: MeraColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${fmt.format(window.start)} – ${fmt.format(window.end)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Süre ${(window.duration.inMinutes)} dk · '
                  'Ort. ${window.avgScore.toStringAsFixed(0)} / 100',
                  style: const TextStyle(color: MeraColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          a.disclaimer,
          style: const TextStyle(
            color: MeraColors.textMuted,
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return MeraCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: MeraColors.green, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: MeraColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value) {
    return MeraCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: MeraColors.textMuted, fontSize: 10),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _confidenceBar(ConfidenceLevel c) {
    final filled = switch (c) {
      ConfidenceLevel.low => 1,
      ConfidenceLevel.medium => 2,
      ConfidenceLevel.high => 3,
    };
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            decoration: BoxDecoration(
              color: i < filled
                  ? _confidenceColor(c)
                  : MeraColors.borderSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  static String _levelBlurb(ActivityLevel l, String species) {
    switch (l) {
      case ActivityLevel.veryHigh:
        return 'Koşullar $species aktivitesi açısından oldukça olumlu görünüyor.';
      case ActivityLevel.high:
        return 'Koşullar $species için olumlu görünüyor.';
      case ActivityLevel.medium:
        return 'Koşullar orta seviyede görünüyor.';
      case ActivityLevel.low:
        return 'Koşullar daha zorlayıcı görünüyor.';
      case ActivityLevel.veryLow:
        return 'Veri veya koşullar zayıf; tahmin düşük.';
    }
  }

  static String _confidenceLabel(ConfidenceLevel c) {
    switch (c) {
      case ConfidenceLevel.low:
        return 'Düşük';
      case ConfidenceLevel.medium:
        return 'Orta';
      case ConfidenceLevel.high:
        return 'Yüksek';
    }
  }

  static Color _confidenceColor(ConfidenceLevel c) {
    switch (c) {
      case ConfidenceLevel.low:
        return MeraColors.danger;
      case ConfidenceLevel.medium:
        return MeraColors.warning;
      case ConfidenceLevel.high:
        return MeraColors.green;
    }
  }

  static IconData _factorIcon(String id) {
    switch (id) {
      case 'waterTemp':
        return Icons.thermostat;
      case 'light':
        return Icons.wb_sunny_outlined;
      case 'time':
        return Icons.schedule;
      case 'wind':
        return Icons.air;
      case 'wave':
        return Icons.waves;
      case 'current':
        return Icons.waves_outlined;
      case 'pressure':
        return Icons.speed;
      case 'moon':
        return Icons.nightlight_round;
      case 'cloud':
        return Icons.cloud_outlined;
      case 'clarity':
        return Icons.visibility;
      case 'oxygen':
        return Icons.bubble_chart_outlined;
      case 'tide':
        return Icons.waterfall_chart;
      default:
        return Icons.info_outline;
    }
  }

  static IconData _wmoIcon(int? code) {
    final c = code ?? 0;
    if (c == 0) return Icons.wb_sunny_outlined;
    if (c <= 3) return Icons.wb_cloudy_outlined;
    if (c <= 67) return Icons.grain;
    if (c <= 77) return Icons.ac_unit;
    return Icons.thunderstorm_outlined;
  }

  static String _wmoLabel(int? code) {
    final c = code ?? 0;
    if (c == 0) return 'Açık';
    if (c <= 3) return 'Parçalı bulutlu';
    if (c <= 67) return 'Yağmurlu';
    if (c <= 77) return 'Karlı';
    return 'Fırtınalı';
  }
}
