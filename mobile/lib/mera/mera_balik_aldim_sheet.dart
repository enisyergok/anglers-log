import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/mera/mera_catch_detail_page.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/species_manager.dart';

/// Mockup 02 — BALIK ALDIM modal (exact copy).
Future<void> showMeraBalikAldimSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: MeraColors.modalScrim,
    builder: (context) => const _BalikAldimSheet(),
  );
}

class _BalikAldimSheet extends StatefulWidget {
  const _BalikAldimSheet();

  @override
  State<_BalikAldimSheet> createState() => _BalikAldimSheetState();
}

class _BalikAldimSheetState extends State<_BalikAldimSheet> {
  Species? _species;
  final _notes = TextEditingController();
  var _didInitSpecies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitSpecies) {
      _didInitSpecies = true;
      final list = SpeciesManager.of(context).list();
      if (list.isNotEmpty) _species = list.first;
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final species = SpeciesManager.of(context).list();

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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: MeraColors.blue,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: MeraColors.blueGlow, blurRadius: 22),
                  ],
                ),
                child: const Icon(Icons.set_meal, color: Colors.white, size: 38),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: MeraColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tebrikler!',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            species.isEmpty
                ? 'Önce Ayarlar’dan veya tür listesinden bir tür ekleyin.'
                : 'Balık yakalamanız kaydedildi.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: MeraColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          if (species.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Kayıtlı tür yok',
                style: GoogleFonts.inter(
                  color: MeraColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            DropdownButtonFormField<Species>(
              initialValue: _species,
              decoration: const InputDecoration(labelText: 'Tür Seçin'),
              dropdownColor: MeraColors.surface,
              items: species
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (s) => setState(() => _species = s),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Not (isteğe bağlı)',
              hintText: 'Not ekleyin…',
            ),
          ),
          const SizedBox(height: 18),
          MeraPrimaryButton(
            label: 'KAYDET',
            onPressed: (_species == null || species.isEmpty)
                ? null
                : () {
                    final selected = _species!;
                    final note = _notes.text.trim();
                    final nav = Navigator.of(context);
                    Navigator.pop(context);
                    nav.push(
                      MaterialPageRoute(
                        builder: (_) => MeraCatchDetailPage(
                          species: selected,
                          initialNotes: note.isEmpty ? null : note,
                        ),
                      ),
                    );
                  },
          ),
          const SizedBox(height: 4),
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
}
