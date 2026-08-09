import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/mera_catch_success_page.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/navigation/mera_manager.dart';
import 'package:mobile/navigation/nmea_udp_listener.dart';
import 'package:mobile/utils/protobuf_utils.dart';

/// Mockup 03 — Yakalama detayı.
class MeraCatchDetailPage extends StatefulWidget {
  final Species species;
  final String? initialNotes;

  const MeraCatchDetailPage({
    super.key,
    required this.species,
    this.initialNotes,
  });

  @override
  State<MeraCatchDetailPage> createState() => _MeraCatchDetailPageState();
}

class _MeraCatchDetailPageState extends State<MeraCatchDetailPage> {
  late double _lengthCm;
  late double _weightKg;
  late final TextEditingController _notes;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _lengthCm = 42;
    _weightKg = 1.8;
    _notes = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeManager.get.currentDateTime;
    final loc = LocationMonitor.of(context).currentLatLng;
    final dateLabel = DateFormat('d MMMM yyyy · HH:mm', 'tr').format(now);

    return Scaffold(
      backgroundColor: MeraColors.bg,
      appBar: AppBar(
        title: const Text('Yakalama Detayı'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          MeraFishHero(label: widget.species.name),
          const SizedBox(height: 8),
          Text(
            widget.species.name,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          MeraCard(
            child: Column(
              children: [
                _stepper(
                  'Boy',
                  '${_lengthCm.toStringAsFixed(0)} cm',
                  () => setState(() => _lengthCm = (_lengthCm - 1).clamp(1, 300)),
                  () => setState(() => _lengthCm = (_lengthCm + 1).clamp(1, 300)),
                ),
                const Divider(height: 22, color: MeraColors.cardBorder),
                _stepper(
                  'Ağırlık',
                  '${_weightKg.toStringAsFixed(1)} kg',
                  () => setState(
                    () => _weightKg = double.parse(
                      (_weightKg - 0.1).clamp(0.1, 200).toStringAsFixed(1),
                    ),
                  ),
                  () => setState(
                    () => _weightKg = double.parse(
                      (_weightKg + 0.1).clamp(0.1, 200).toStringAsFixed(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MeraCard(
            child: Column(
              children: [
                _meta(Icons.schedule, 'Yakalandığı Zaman', dateLabel),
                const SizedBox(height: 14),
                _meta(
                  Icons.place_outlined,
                  'Konum',
                  loc == null
                      ? 'Konum yok'
                      : '${loc.lat.toStringAsFixed(5)}, ${loc.lng.toStringAsFixed(5)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Not'),
          ),
          const SizedBox(height: 22),
          MeraPrimaryButton(label: 'KAYDET', loading: _saving, onPressed: _save),
        ],
      ),
    );
  }

  Widget _stepper(
    String label,
    String value,
    VoidCallback minus,
    VoidCallback plus,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: MeraColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _roundIcon(Icons.remove, minus),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _roundIcon(Icons.add, plus, color: MeraColors.green),
      ],
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: MeraColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: MeraColors.cardBorder),
        ),
        child: Icon(icon, size: 18, color: color ?? MeraColors.textSecondary),
      ),
    );
  }

  Widget _meta(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: MeraColors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: MeraColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final now = TimeManager.get.currentDateTime;
      final loc = LocationMonitor.of(context).currentLatLng;
      final depth = NmeaUdpListener.get.latest?.depthM;

      if (loc == null) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: MeraColors.card,
            title: const Text('Konum yok'),
            content: const Text(
              'GPS konumu alınamadı. Yine de konumsuz kaydetmek ister misiniz?',
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
        if (proceed != true) {
          if (mounted) setState(() => _saving = false);
          return;
        }
      }

      final cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(now.millisecondsSinceEpoch)
        ..timeZone = now.locationName
        ..speciesId = widget.species.id
        ..length = MultiMeasurement(
          mainValue: Measurement(unit: Unit.centimeters, value: _lengthCm),
        )
        ..weight = MultiMeasurement(
          mainValue: Measurement(unit: Unit.kilograms, value: _weightKg),
        );
      final note = _notes.text.trim();
      if (note.isNotEmpty) cat.notes = note;

      final ok = await CatchManager.get.addOrUpdate(cat);
      if (!ok) {
        if (mounted) showErrorSnackBar(context, 'Av kaydedilemedi');
        return;
      }

      if (loc != null) {
        final spot = FishingSpot()
          ..id = randomId()
          ..lat = loc.lat
          ..lng = loc.lng
          ..name = widget.species.name
          ..notes = note;
        await FishingSpotManager.get.addOrUpdate(spot);
        cat.fishingSpotId = spot.id;
        await CatchManager.get.addOrUpdate(cat);
        await MeraManager.get.add(
          lat: loc.lat,
          lng: loc.lng,
          depthM: depth,
          bottomType: 'av',
          note: widget.species.name,
        );
      }

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MeraCatchSuccessPage(
            speciesName: widget.species.name,
            lengthCm: _lengthCm,
            weightKg: _weightKg,
            timestampMs: now.millisecondsSinceEpoch,
            lat: loc?.lat,
            lng: loc?.lng,
          ),
        ),
      );
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Hata: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
