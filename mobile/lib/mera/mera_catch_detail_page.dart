import 'dart:io';

import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/atmosphere_fetcher.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/mera_date_formatter.dart';
import 'package:mobile/mera/fish_activity/models.dart';
import 'package:mobile/mera/fish_activity/service.dart';
import 'package:mobile/mera/fish_activity/species_profiles.dart';
import 'package:mobile/mera/mera_animated_entry.dart';
import 'package:mobile/mera/mera_catch_activity_store.dart';
import 'package:mobile/mera/mera_catch_success_page.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
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
  double? _lengthCm;
  double? _weightKg;
  var _measured = false;
  File? _photo;
  Id? _baitId;
  late final TextEditingController _notes;
  var _saving = false;

  @override
  void initState() {
    super.initState();
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
    final dateLabel = MeraDateFormatter.formatFull(now);

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
          MeraAnimatedEntry(
            delay: const Duration(milliseconds: 60),
            child: MeraFishHero(label: widget.species.name),
          ),
          const SizedBox(height: 8),
          MeraAnimatedEntry(
            delay: const Duration(milliseconds: 120),
            child: Text(
              widget.species.name,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          MeraAnimatedEntry(
            delay: const Duration(milliseconds: 180),
            child: MeraCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Ölçü kaydet',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      _measured
                          ? 'Boy ve ağırlık zorunlu'
                          : 'Ölçülmedi — boy/ağırlık kaydedilmez',
                      style: GoogleFonts.inter(
                        color: MeraColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    value: _measured,
                    activeThumbColor: MeraColors.green,
                    onChanged: (v) => setState(() {
                      _measured = v;
                      if (v) {
                        _lengthCm ??= 30;
                        _weightKg ??= 0.5;
                      } else {
                        _lengthCm = null;
                        _weightKg = null;
                      }
                    }),
                  ),
                  if (_measured) ...[
                    const Divider(height: 22, color: MeraColors.cardBorder),
                    _stepper(
                      'Boy',
                      '${_lengthCm!.toStringAsFixed(0)} cm',
                      () => setState(
                        () => _lengthCm = (_lengthCm! - 1).clamp(1, 300),
                      ),
                      () => setState(
                        () => _lengthCm = (_lengthCm! + 1).clamp(1, 300),
                      ),
                    ),
                    const Divider(height: 22, color: MeraColors.cardBorder),
                    _stepper(
                      'Ağırlık',
                      '${_weightKg!.toStringAsFixed(1)} kg',
                      () => setState(
                        () => _weightKg = double.parse(
                          (_weightKg! - 0.1).clamp(0.1, 200).toStringAsFixed(1),
                        ),
                      ),
                      () => setState(
                        () => _weightKg = double.parse(
                          (_weightKg! + 0.1).clamp(0.1, 200).toStringAsFixed(1),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          MeraAnimatedEntry(
            delay: const Duration(milliseconds: 240),
            child: MeraCard(
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
          ),
          const SizedBox(height: 12),
          MeraAnimatedEntry(
            delay: const Duration(milliseconds: 300),
            child: MeraCard(
              onTap: _pickPhoto,
              child: Row(
                children: [
                  if (_photo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _photo!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: MeraColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: MeraColors.cardBorder),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: MeraColors.textMuted,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _photo == null
                          ? 'Fotoğraf ekle (opsiyonel)'
                          : 'Fotoğraf seçildi — değiştirmek için dokunun',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_photo != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _photo = null),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          MeraAnimatedEntry(
            delay: const Duration(milliseconds: 360),
            child: _baitPicker(),
          ),
          const SizedBox(height: 12),
          MeraAnimatedEntry(
            delay: const Duration(milliseconds: 400),
            child: TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Not'),
            ),
          ),
          const SizedBox(height: 22),
          MeraAnimatedEntry(
            delay: const Duration(milliseconds: 460),
            child: MeraBreathingGlow(
              color: MeraColors.green,
              child: MeraPrimaryButton(
                label: 'KAYDET',
                loading: _saving,
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baitPicker() {
    final baits = List.of(BaitManager.of(context).list())
      ..sort((a, b) => a.name.compareTo(b.name));
    return MeraCard(
      child: Row(
        children: [
          const Icon(Icons.set_meal_outlined, size: 20, color: MeraColors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<Id?>(
                initialValue: _baitId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Yem / Zoka',
                  border: InputBorder.none,
                ),
                hint: const Text('Yem seç (opsiyonel)'),
                items: [
                  for (final b in baits)
                    DropdownMenuItem(value: b.id, child: Text(b.name)),
                ],
                onChanged: (v) => setState(() => _baitId = v),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22),
            tooltip: 'Yeni yem ekle',
            onPressed: _addNewBait,
          ),
        ],
      ),
    );
  }

  Future<void> _addNewBait() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Yeni yem'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Yem adı',
            hintText: 'Örn. Gümüş kaşık',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final bait = Bait()
      ..id = randomId()
      ..name = name;
    await BaitManager.of(context).addOrUpdate(bait);
    if (!mounted) return;
    setState(() => _baitId = bait.id);
  }

  Future<void> _pickPhoto() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;
    setState(() => _photo = File(x.path));
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
    if (_measured && (_lengthCm == null || _weightKg == null)) {
      showErrorSnackBar(context, 'Boy ve ağırlık girin veya ölçülmedi seçin');
      return;
    }
    setState(() => _saving = true);
    try {
      final now = TimeManager.get.currentDateTime;
      final loc = LocationMonitor.of(context).currentLatLng;

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
        ..speciesId = widget.species.id;
      if (_measured && _lengthCm != null) {
        cat.length = MultiMeasurement(
          mainValue: Measurement(unit: Unit.centimeters, value: _lengthCm!),
        );
      }
      if (_measured && _weightKg != null) {
        cat.weight = MultiMeasurement(
          mainValue: Measurement(unit: Unit.kilograms, value: _weightKg!),
        );
      }
      final note = _notes.text.trim();
      if (note.isNotEmpty) cat.notes = note;
      if (_baitId != null) {
        cat.baits.add(BaitAttachment()..baitId = _baitId!);
      }

      if (loc != null) {
        try {
          final atmo = await AtmosphereFetcher(
            now,
            LatLng(lat: loc.lat, lng: loc.lng),
          ).fetch(context);
          if (atmo.data != null) {
            cat.atmosphere = atmo.data!;
          }
        } catch (_) {
          // Atmosphere optional
        }
      }

      final images = _photo != null ? <File>[_photo!] : const <File>[];
      final ok = await CatchManager.get.addOrUpdate(
        cat,
        imageFiles: images,
        setImages: true,
      );
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
        await CatchManager.get.addOrUpdate(cat, setImages: false);

        try {
          final profile =
              SpeciesActivityProfiles.matchName(widget.species.name) ??
                  SpeciesActivityProfiles.cipura;
          final loaded = await FishActivityService().load(
            lat: loc.lat,
            lng: loc.lng,
            species: profile,
          );
          await MeraCatchActivityStore.get.put(
            MeraCatchActivitySnapshot(
              catchId: cat.id.uuid,
              score: loaded.activity.score,
              level: FishActivityResult.levelLabel(loaded.activity.level),
              speciesKey: profile.key,
              speciesName: profile.nameTr,
              lat: loc.lat,
              lng: loc.lng,
              computedAtMs: now.millisecondsSinceEpoch,
              envSummary: {
                if (loaded.env.waterTempC != null)
                  'waterTempC': loaded.env.waterTempC,
                if (loaded.env.windKmh != null) 'windKmh': loaded.env.windKmh,
                if (loaded.env.tidePhaseLabel != null)
                  'tide': loaded.env.tidePhaseLabel,
              },
            ),
          );
        } catch (_) {
          // Activity snapshot optional
        }
      }

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MeraCatchSuccessPage(
            speciesName: widget.species.name,
            lengthCm: _lengthCm ?? 0,
            weightKg: _weightKg ?? 0,
            measured: _measured,
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
