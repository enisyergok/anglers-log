import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/mera/mera_shell.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';

/// Mockup 04 — Başarı ekranı.
class MeraCatchSuccessPage extends StatelessWidget {
  final String speciesName;
  final double lengthCm;
  final double weightKg;
  final int timestampMs;
  final double? lat;
  final double? lng;

  const MeraCatchSuccessPage({
    super.key,
    required this.speciesName,
    required this.lengthCm,
    required this.weightKg,
    required this.timestampMs,
    this.lat,
    this.lng,
  });

  @override
  Widget build(BuildContext context) {
    final when = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final whenLabel = DateFormat('d MMM yyyy · HH:mm', 'tr').format(when);
    final gps = (lat != null && lng != null)
        ? '${lat!.toStringAsFixed(5)}, ${lng!.toStringAsFixed(5)}'
        : '—';

    return Scaffold(
      backgroundColor: MeraColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const MeraGlowCheck(),
              const SizedBox(height: 18),
              Text(
                'Başarıyla kaydedildi!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              MeraCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: MeraFishHero(label: '', height: 72),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            speciesName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${weightKg.toStringAsFixed(1)} kg · ${lengthCm.toStringAsFixed(0)} cm',
                            style: GoogleFonts.plusJakartaSans(
                              color: MeraColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            whenLabel,
                            style: GoogleFonts.plusJakartaSans(
                              color: MeraColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            gps,
                            style: GoogleFonts.plusJakartaSans(
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
              const Spacer(),
              MeraOutlineButton(
                label: 'Paylaş',
                icon: Icons.ios_share,
                onPressed: () {
                  SharePlusWrapper.of(context).share(
                    'Mera Asistanı — $speciesName\n'
                    '${lengthCm.toStringAsFixed(0)} cm · ${weightKg.toStringAsFixed(1)} kg\n'
                    '$whenLabel\n$gps',
                    null,
                  );
                },
              ),
              const SizedBox(height: 10),
              MeraPrimaryButton(
                label: 'Haritaya Dön',
                color: MeraColors.blue,
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
              ),
              TextButton(
                onPressed: () {
                  MeraShell.goRecords();
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                child: Text(
                  'Yakalamalarım',
                  style: GoogleFonts.plusJakartaSans(
                    color: MeraColors.textSecondary,
                    fontWeight: FontWeight.w700,
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
