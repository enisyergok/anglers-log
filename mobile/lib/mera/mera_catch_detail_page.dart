import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
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

/// Mockup screen 03 — Yakalama detayı.
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
    _lengthCm = 35;
    _weightKg = 1.2;
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
      appBar: AppBar(title: const Text('Yakalama Detayı')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          MeraCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A5F), Color(0xFF0F766E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.set_meal, size: 72, color: Colors.white70),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.species.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MeraCard(
            child: Column(
              children: [
                _StepperRow(
                  label: 'Boy (cm)',
                  value: _lengthCm,
                  step: 1,
                  format: (v) => v.toStringAsFixed(0),
                  onChanged: (v) => setState(() => _lengthCm = v),
                ),
                const Divider(color: MeraColors.cardBorder),
                _StepperRow(
                  label: 'Ağırlık (kg)',
                  value: _weightKg,
                  step: 0.1,
                  format: (v) => v.toStringAsFixed(1),
                  onChanged: (v) => setState(() => _weightKg = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MeraCard(
            child: Column(
              children: [
                _MetaRow(icon: Icons.schedule, label: 'Tarih', value: dateLabel),
                const SizedBox(height: 12),
                _MetaRow(
                  icon: Icons.my_location,
                  label: 'GPS',
                  value: loc == null
                      ? 'Konum yok'
                      : '${loc.lat.toStringAsFixed(5)}, ${loc.lng.toStringAsFixed(5)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notlar'),
          ),
          const SizedBox(height: 24),
          MeraPrimaryButton(
            label: 'KAYDET',
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final now = TimeManager.get.currentDateTime;
      final loc = LocationMonitor.of(context).currentLatLng;
      final depth = NmeaUdpListener.get.latest?.depthM;

      Id? spotId;
      if (loc != null) {
        final spot = FishingSpot()
          ..id = randomId()
          ..lat = loc.lat
          ..lng = loc.lng
          ..name = widget.species.name
          ..notes = _notes.text.trim();
        await FishingSpotManager.get.addOrUpdate(spot);
        spotId = spot.id;
        await MeraManager.get.add(
          lat: loc.lat,
          lng: loc.lng,
          depthM: depth,
          bottomType: 'av',
          note: widget.species.name,
        );
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
      if (spotId != null) {
        cat.fishingSpotId = spotId;
      }
      final note = _notes.text.trim();
      if (note.isNotEmpty) {
        cat.notes = note;
      }

      final ok = await CatchManager.get.addOrUpdate(cat);
      if (!mounted) {
        return;
      }
      if (!ok) {
        showErrorSnackBar(context, 'Av kaydedilemedi');
        return;
      }
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
      if (mounted) {
        showErrorSnackBar(context, 'Hata: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final double value;
  final double step;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.step,
    required this.format,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: MeraColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: () => onChanged((value - step).clamp(0.1, 999)),
          icon: const Icon(Icons.remove_circle_outline),
          color: MeraColors.textSecondary,
        ),
        SizedBox(
          width: 64,
          child: Text(
            format(value),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          onPressed: () => onChanged((value + step).clamp(0.1, 999)),
          icon: const Icon(Icons.add_circle_outline),
          color: MeraColors.green,
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: MeraColors.blue),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: MeraColors.textSecondary),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
