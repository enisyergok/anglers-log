import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/mera/mera_no_catch_manager.dart';
import 'package:mobile/mera/mera_shell.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';

/// Mockup 06 — Bildirim başarılı.
class MeraReportSuccessPage extends StatelessWidget {
  final MeraNoCatchReport report;

  const MeraReportSuccessPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final when = DateTime.fromMillisecondsSinceEpoch(report.timestampMs);
    final whenLabel = DateFormat('d MMM yyyy · HH:mm', 'tr').format(when);
    final gps = (report.lat != null && report.lng != null)
        ? '${report.lat!.toStringAsFixed(5)}, ${report.lng!.toStringAsFixed(5)}'
        : 'Konum yok';

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
                'Teşekkürler!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bildiriminiz kaydedildi.',
                style: GoogleFonts.plusJakartaSans(
                  color: MeraColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              MeraCard(
                child: Column(
                  children: [
                    _row('Durum', 'Balık Alınmadı'),
                    const SizedBox(height: 12),
                    _row('Zaman', whenLabel),
                    const SizedBox(height: 12),
                    _row('Konum', gps),
                    if (report.note != null && report.note!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _row('Not', report.note!),
                    ],
                  ],
                ),
              ),
              const Spacer(),
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
                  'Kayıtlarım',
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

  Widget _row(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            k,
            style: GoogleFonts.plusJakartaSans(
              color: MeraColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
