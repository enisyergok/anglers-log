import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';

/// Mockup screen 04 — Kayıt başarılı.
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
                  color: MeraColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 56, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Başarıyla kaydedildi!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              MeraCard(
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: MeraColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.set_meal, color: MeraColors.blue),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            speciesName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${lengthCm.toStringAsFixed(0)} cm · ${weightKg.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              color: MeraColors.textSecondary,
                            ),
                          ),
                          Text(
                            whenLabel,
                            style: const TextStyle(
                              color: MeraColors.textMuted,
                              fontSize: 12,
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
                onPressed: () {
                  final gps = (lat != null && lng != null)
                      ? '\nGPS: ${lat!.toStringAsFixed(5)}, ${lng!.toStringAsFixed(5)}'
                      : '';
                  SharePlusWrapper.of(context).share(
                    'Mera Asistanı — $speciesName\n'
                    '${lengthCm.toStringAsFixed(0)} cm · ${weightKg.toStringAsFixed(1)} kg\n'
                    '$whenLabel$gps',
                    null,
                  );
                },
              ),
              const SizedBox(height: 10),
              MeraPrimaryButton(
                label: 'Haritaya Dön',
                color: MeraColors.blue,
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
              const SizedBox(height: 10),
              MeraOutlineButton(
                label: 'Yakalamalarım',
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  // Parent IndexedStack switch is handled by user via tab.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
