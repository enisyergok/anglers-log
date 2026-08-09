import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/mera/mera_no_catch_manager.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/mera/siren_fish_art.dart';
import 'package:mobile/species_manager.dart';

/// Mockup screen 07 — Kayıtlarım.
class MeraRecordsPage extends StatefulWidget {
  const MeraRecordsPage({super.key});

  @override
  State<MeraRecordsPage> createState() => _MeraRecordsPageState();
}

enum _Filter { all, catches, noCatch }

class _MeraRecordsPageState extends State<MeraRecordsPage> {
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    MeraNoCatchManager.get.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return MeraPageScaffold(
      title: 'Yakalamalarım',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                _chip('Hepsi', _Filter.all),
                const SizedBox(width: 8),
                _chip('Yakalamalarım', _Filter.catches),
                const SizedBox(width: 8),
                _chip('Alınmadı', _Filter.noCatch),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: CatchManager.get.stream,
              builder: (context, _) {
                return StreamBuilder(
                  stream: MeraNoCatchManager.get.stream,
                  builder: (context, __) {
                    return FutureBuilder(
                      future: MeraNoCatchManager.get.ensureLoaded(),
                      builder: (context, ___) {
                        final items = _buildItems(context);
                        if (items.isEmpty) {
                          return const MeraEmptyState(
                            icon: Icons.inbox_outlined,
                            title: 'Henüz kayıt yok',
                            subtitle: 'Haritadan BALIK ALDIM ile başlayın',
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) => items[i],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _Filter f) {
    final selected = _filter == f;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = f),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF183E51) : const Color(0xFF102C3A),
            borderRadius: BorderRadius.circular(MeraRadii.md),
            border: Border.all(
              color: selected ? MeraColors.blue : MeraColors.cardBorder,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? MeraColors.textPrimary : MeraColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final speciesMgr = SpeciesManager.of(context);
    final spotMgr = FishingSpotManager.get;
    final fmt = DateFormat('d MMM yyyy · HH:mm', 'tr');

    final rows = <_Row>[];

    if (_filter != _Filter.noCatch) {
      for (final c in CatchManager.get.list()) {
        final species = speciesMgr.entity(c.speciesId);
        final spot = c.hasFishingSpotId()
            ? spotMgr.entity(c.fishingSpotId)
            : null;
        final length = c.hasLength()
            ? c.length.mainValue.value.toStringAsFixed(0)
            : null;
        final weight = c.hasWeight()
            ? c.weight.mainValue.value.toStringAsFixed(1)
            : null;
        rows.add(
          _Row(
            ts: c.timestamp.toInt(),
            widget: MeraCard(
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: MeraColors.surface,
                      borderRadius: BorderRadius.circular(MeraRadii.sm),
                    ),
                    child: SirenFishArt.image(
                      speciesName: species?.name,
                      height: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          species?.name ?? 'Tür',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          [
                            if (weight != null) '$weight kg',
                            if (length != null) '$length cm',
                          ].join(' · '),
                          style: const TextStyle(
                            color: MeraColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          fmt.format(
                            DateTime.fromMillisecondsSinceEpoch(
                              c.timestamp.toInt(),
                            ),
                          ),
                          style: const TextStyle(
                            color: MeraColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        if (spot != null)
                          Text(
                            '${spot.lat.toStringAsFixed(4)}, ${spot.lng.toStringAsFixed(4)}',
                            style: const TextStyle(
                              color: MeraColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    if (_filter != _Filter.catches) {
      for (final r in MeraNoCatchManager.get.items) {
        rows.add(
          _Row(
            ts: r.timestampMs,
            widget: MeraCard(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: MeraColors.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.close, color: MeraColors.danger),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Balık alınmadı',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        if (r.note != null && r.note!.isNotEmpty)
                          Text(
                            r.note!,
                            style: const TextStyle(
                              color: MeraColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        Text(
                          fmt.format(
                            DateTime.fromMillisecondsSinceEpoch(r.timestampMs),
                          ),
                          style: const TextStyle(
                            color: MeraColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        if (r.lat != null && r.lng != null)
                          Text(
                            '${r.lat!.toStringAsFixed(4)}, ${r.lng!.toStringAsFixed(4)}',
                            style: const TextStyle(
                              color: MeraColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    rows.sort((a, b) => b.ts.compareTo(a.ts));
    return rows.map((e) => e.widget).toList();
  }
}

class _Row {
  final int ts;
  final Widget widget;
  _Row({required this.ts, required this.widget});
}
