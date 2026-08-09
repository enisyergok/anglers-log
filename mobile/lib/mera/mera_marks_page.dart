import 'package:adair_flutter_lib/utils/page.dart';
import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/mera/mera_records_page.dart';
import 'package:mobile/mera/mera_stats_page.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/navigation/mera_manager.dart';

/// Siren — İşaretlerim (marks + catch records / stats entry).
class MeraMarksPage extends StatelessWidget {
  const MeraMarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final spots = FishingSpotManager.get.list();
    final meras = MeraManager.get.spots;

    return MeraPageScaffold(
      title: 'İşaretlerim',
      actions: [
        IconButton(
          icon: const Icon(Icons.insights_outlined, size: 20),
          tooltip: 'İstatistikler',
          onPressed: () => present(context, const MeraStatsPage()),
        ),
        IconButton(
          icon: const Icon(Icons.menu_book_outlined, size: 20),
          tooltip: 'Yakalamalarım',
          onPressed: () => present(context, const MeraRecordsPage()),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const MeraSectionHeader('YAKIN İŞARETLER'),
          if (meras.isEmpty && spots.isEmpty)
            const MeraEmptyState(
              icon: Icons.place_outlined,
              title: 'Henüz işaret yok',
              subtitle: 'Haritada pin bırakın veya BALIK ALDIM ile kaydedin',
            )
          else ...[
            for (final m in meras.take(40))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MeraCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: MeraColors.danger,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.bottomType?.isNotEmpty == true
                                  ? m.bottomType!
                                  : (m.note?.isNotEmpty == true
                                      ? m.note!
                                      : 'Mera'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${m.lat.toStringAsFixed(4)}°, ${m.lng.toStringAsFixed(4)}°',
                              style: const TextStyle(
                                color: MeraColors.textSecondary,
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
            for (final s in spots.take(40))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MeraCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        color: MeraColors.blue.withValues(alpha: 0.9),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name.isEmpty ? 'Nokta' : s.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${s.lat.toStringAsFixed(4)}°, ${s.lng.toStringAsFixed(4)}°',
                              style: const TextStyle(
                                color: MeraColors.textSecondary,
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
          ],
        ],
      ),
    );
  }
}
