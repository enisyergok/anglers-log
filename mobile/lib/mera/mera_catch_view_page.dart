import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/mera/mera_catch_activity_store.dart';
import 'package:mobile/mera/mera_map_interaction.dart';
import 'package:mobile/mera/mera_shell.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/mera/siren_fish_art.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/widgets/photo.dart';

/// Siren-themed catch view: inspect / edit / delete / show on map.
class MeraCatchViewPage extends StatefulWidget {
  final Catch catchEntity;

  const MeraCatchViewPage(this.catchEntity, {super.key});

  @override
  State<MeraCatchViewPage> createState() => _MeraCatchViewPageState();
}

class _MeraCatchViewPageState extends State<MeraCatchViewPage> {
  late Catch _catch;

  @override
  void initState() {
    super.initState();
    _catch = widget.catchEntity;
    MeraCatchActivityStore.get.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final species =
        SpeciesManager.of(context).entity(_catch.speciesId)?.name ?? 'Balık';
    final when = DateTime.fromMillisecondsSinceEpoch(_catch.timestamp.toInt());
    final whenLabel = DateFormat('d MMMM yyyy · HH:mm', 'tr').format(when);
    final spot = _catch.hasFishingSpotId()
        ? FishingSpotManager.get.entity(_catch.fishingSpotId)
        : null;
    final snap = MeraCatchActivityStore.get.forCatch(_catch.id.uuid);
    final hasLen = _catch.hasLength();
    final hasWt = _catch.hasWeight();

    return Scaffold(
      backgroundColor: MeraColors.bg,
      appBar: AppBar(
        title: const Text('Yakalama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await present(context, SaveCatchPage.edit(_catch));
              final updated = CatchManager.get.entity(_catch.id);
              if (updated != null && mounted) {
                setState(() => _catch = updated);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: MeraColors.danger),
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: SirenFishArt.image(
              speciesName: species,
              height: 120,
              width: 220,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            species,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            whenLabel,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: MeraColors.textSecondary),
          ),
          const SizedBox(height: 16),
          MeraCard(
            child: Column(
              children: [
                _row(
                  'Boy',
                  hasLen
                      ? '${_catch.length.mainValue.value.toStringAsFixed(0)} cm'
                      : 'Ölçülmedi',
                ),
                const Divider(height: 20, color: MeraColors.cardBorder),
                _row(
                  'Ağırlık',
                  hasWt
                      ? '${_catch.weight.mainValue.value.toStringAsFixed(1)} kg'
                      : 'Ölçülmedi',
                ),
                if (spot != null) ...[
                  const Divider(height: 20, color: MeraColors.cardBorder),
                  _row(
                    'Konum',
                    '${spot.lat.toStringAsFixed(5)}, ${spot.lng.toStringAsFixed(5)}',
                  ),
                ],
                if (_catch.hasNotes() && _catch.notes.trim().isNotEmpty) ...[
                  const Divider(height: 20, color: MeraColors.cardBorder),
                  _row('Not', _catch.notes),
                ],
                if (snap != null) ...[
                  const Divider(height: 20, color: MeraColors.cardBorder),
                  _row(
                    'Aktivite skoru',
                    '${snap.score.round()} · ${snap.level}',
                  ),
                ],
              ],
            ),
          ),
          if (_catch.imageNames.isNotEmpty) ...[
            const SizedBox(height: 14),
            const MeraSectionHeader('FOTOĞRAF'),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(MeraRadii.lg),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: Photo(
                  fileName: _catch.imageNames.first,
                  width: 400,
                  height: 220,
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          if (spot != null)
            MeraPrimaryButton(
              label: 'Haritada Göster',
              color: MeraColors.blue,
              onPressed: () {
                MeraMapInteraction.instance.centerOnLatLng(
                  ll.LatLng(spot.lat, spot.lng),
                );
                MeraShell.goHome();
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            k,
            style: GoogleFonts.inter(
              color: MeraColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MeraColors.card,
        title: const Text('Sil'),
        content: const Text('Bu yakalamayı silmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final id = _catch.id;
    await CatchManager.get.delete(id);
    await MeraCatchActivityStore.get.remove(id.uuid);
    if (!mounted) return;
    showSuccessSnackBar(context, 'Yakalama silindi');
    Navigator.pop(context);
  }
}
