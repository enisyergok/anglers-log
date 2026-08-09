import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/mera_no_catch_manager.dart';
import 'package:mobile/mera/mera_report_success_page.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';

/// Mockup screen 05 — Balık almadım.
Future<void> showMeraNoCatchSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _NoCatchSheet(),
  );
}

class _NoCatchSheet extends StatefulWidget {
  const _NoCatchSheet();

  @override
  State<_NoCatchSheet> createState() => _NoCatchSheetState();
}

class _NoCatchSheetState extends State<_NoCatchSheet> {
  final _notes = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: MeraColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: MeraColors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MeraColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: MeraColors.danger.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.not_interested,
                color: MeraColors.danger,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Balık Almadım',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu konumda balık almadığınızı bildirmek ister misiniz?',
              textAlign: TextAlign.center,
              style: TextStyle(color: MeraColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                hintText: 'İsteğe bağlı…',
              ),
            ),
            const SizedBox(height: 18),
            MeraPrimaryButton(
              label: 'BİLDİR',
              color: MeraColors.blue,
              loading: _saving,
              onPressed: _submit,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'İPTAL',
                style: TextStyle(color: MeraColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final loc = LocationMonitor.of(context).currentLatLng;
      final report = await MeraNoCatchManager.get.add(
        lat: loc?.lat,
        lng: loc?.lng,
        note: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      if (!mounted) {
        return;
      }
      final nav = Navigator.of(context);
      Navigator.pop(context);
      await nav.push(
        MaterialPageRoute(
          builder: (_) => MeraReportSuccessPage(report: report),
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
