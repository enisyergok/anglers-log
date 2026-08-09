import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/mera/mera_no_catch_manager.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';

/// Mockup screen 06 — Bildirim başarılı.
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
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: MeraColors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 56, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bildirim kaydedildi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              MeraCard(
                child: Column(
                  children: [
                    _row('Durum', 'Balık alınmadı'),
                    const SizedBox(height: 10),
                    _row('Zaman', whenLabel),
                    const SizedBox(height: 10),
                    _row('Konum', gps),
                    if (report.note != null && report.note!.isNotEmpty) ...[
                      const SizedBox(height: 10),
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
            style: const TextStyle(color: MeraColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
