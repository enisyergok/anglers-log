import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/mera/mera_animated_entry.dart';
import 'package:mobile/mera/mera_records_page.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/mera/siren_fish_art.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';

import 'package:mobile/mera/mera_date_formatter.dart';

/// Mockup 04 — Başarı ekranı.
class MeraCatchSuccessPage extends StatelessWidget {
  final String speciesName;
  final double lengthCm;
  final double weightKg;
  final bool measured;
  final int timestampMs;
  final double? lat;
  final double? lng;

  const MeraCatchSuccessPage({
    super.key,
    required this.speciesName,
    required this.lengthCm,
    required this.weightKg,
    this.measured = true,
    required this.timestampMs,
    this.lat,
    this.lng,
  });

  @override
  Widget build(BuildContext context) {
    final when = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final whenLabel = MeraDateFormatter.formatShort(when);
    final gps = (lat != null && lng != null)
        ? '${lat!.toStringAsFixed(5)}, ${lng!.toStringAsFixed(5)}'
        : '—';
    final measureLabel = measured
        ? '${weightKg.toStringAsFixed(1)} kg · ${lengthCm.toStringAsFixed(0)} cm'
        : 'Ölçülmedi';

    return Scaffold(
      backgroundColor: MeraColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              MeraAnimatedEntry(
                delay: const Duration(milliseconds: 80),
                child: const MeraGlowCheck(),
              ),
              const SizedBox(height: 14),
              MeraAnimatedEntry(
                delay: const Duration(milliseconds: 140),
                child: Image.asset(
                  'assets/castiq_logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 18),
              MeraAnimatedEntry(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Başarıyla kaydedildi!',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              MeraAnimatedEntry(
                delay: const Duration(milliseconds: 300),
                child: MeraCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        height: 48,
                        child: SirenFishArt.image(
                          speciesName: speciesName,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              speciesName,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              measureLabel,
                              style: GoogleFonts.inter(
                                color: MeraColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              whenLabel,
                              style: GoogleFonts.inter(
                                color: MeraColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              gps,
                              style: GoogleFonts.inter(
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
              const Spacer(),
              MeraAnimatedEntry(
                delay: const Duration(milliseconds: 420),
                child: MeraOutlineButton(
                  label: 'Paylaş',
                  icon: Icons.ios_share,
                  onPressed: () {
                    SharePlusWrapper.of(context).share(
                      'CASTIQ — $speciesName\n'
                      '$measureLabel\n'
                      '$whenLabel\n$gps',
                      null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              MeraAnimatedEntry(
                delay: const Duration(milliseconds: 500),
                child: MeraBreathingGlow(
                  color: MeraColors.blue,
                  child: MeraPrimaryButton(
                    label: 'Haritaya Dön',
                    color: MeraColors.blue,
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ),
              ),
              MeraAnimatedEntry(
                delay: const Duration(milliseconds: 560),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MeraRecordsPage(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  child: Text(
                    'Yakalamalarım',
                    style: GoogleFonts.inter(
                      color: MeraColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
