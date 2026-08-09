import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/mera_no_catch_manager.dart';
import 'package:mobile/mera/mera_report_success_page.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';

/// Mockup 05 — Balık almadım.
Future<void> showMeraNoCatchSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: MeraColors.modalScrim,
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
    return MeraModalShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: MeraColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: MeraColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: MeraColors.cardBorder),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: MeraColors.textMuted,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Balık Almadım',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu konumda balık almadığınızı bildirmek ister misiniz?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: MeraColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Not',
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
            child: Text(
              'İPTAL',
              style: GoogleFonts.inter(
                color: MeraColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
      if (!mounted) return;
      final nav = Navigator.of(context);
      Navigator.pop(context);
      await nav.push(
        MaterialPageRoute(builder: (_) => MeraReportSuccessPage(report: report)),
      );
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Hata: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
