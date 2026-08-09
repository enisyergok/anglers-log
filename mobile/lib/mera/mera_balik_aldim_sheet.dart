import 'package:flutter/material.dart';
import 'package:mobile/mera/mera_catch_detail_page.dart';
import 'package:mobile/mera/mera_no_catch_sheet.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/species_manager.dart';

/// Mockup screen 02 — BALIK ALDIM modal.
Future<void> showMeraBalikAldimSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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
      if (list.isNotEmpty) {
        _species = list.first;
      }
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
              decoration: const BoxDecoration(
                color: MeraColors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.set_meal, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tebrikler!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: MeraColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Yakalamanızı kaydedin',
              style: TextStyle(color: MeraColors.textSecondary),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Species>(
              initialValue: _species,
              decoration: const InputDecoration(labelText: 'Tür Seçin'),
              dropdownColor: MeraColors.surface,
              items: species
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name),
                    ),
                  )
                  .toList(),
              onChanged: (s) => setState(() => _species = s),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                hintText: 'İsteğe bağlı not ekleyin…',
              ),
            ),
            const SizedBox(height: 18),
            MeraPrimaryButton(
              label: 'KAYDET',
              onPressed: _species == null
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'İPTAL',
                style: TextStyle(
                  color: MeraColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final parentNav = Navigator.of(context);
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showMeraNoCatchSheet(parentNav.context);
                });
              },
              child: const Text(
                'Balık almadım',
                style: TextStyle(color: MeraColors.warning),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
