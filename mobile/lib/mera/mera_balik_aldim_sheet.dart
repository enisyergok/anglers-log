import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/mera/mera_catch_detail_page.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/siren_fish_art.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/species_manager.dart';

/// Screen 02 — BALIK ALDIM modal (Siren reference reproduction).
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

  /// Prefer reference species first (Çipura / Levrek / Mercan).
  List<Species> _sortedSpecies(BuildContext context) {
    final list = List<Species>.from(SpeciesManager.of(context).list());
    const prefer = ['çipura', 'cipura', 'levrek', 'mercan'];
    int rank(Species s) {
      final n = s.name.toLowerCase();
      for (var i = 0; i < prefer.length; i++) {
        if (n.contains(prefer[i])) return i;
      }
      return 100;
    }

    list.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitSpecies) {
      _didInitSpecies = true;
      final list = _sortedSpecies(context);
      if (list.isNotEmpty) {
        _species = list.firstWhere(
          (s) => s.name.toLowerCase().contains('cipura') ||
              s.name.toLowerCase().contains('çipura'),
          orElse: () => list.first,
        );
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
    final species = _sortedSpecies(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    // Reference .phone width 212px → device scale.
    final scale =
        (MediaQuery.sizeOf(context).width / 212.0).clamp(1.65, 1.95);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.9,
            ),
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.2, -1),
                end: Alignment(0.3, 1),
                colors: [Color(0xFF0A2231), Color(0xFF071A27)],
              ),
              borderRadius: BorderRadius.circular(12 * scale * 0.75),
              border: Border.all(color: const Color(0xFF294857)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x88000000),
                  blurRadius: 25,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Photographic fish hero — no cyan circle / icon badge.
                SizedBox(
                  height: 72 * scale,
                  child: Center(
                    child: SirenFishArt.image(
                      speciesName: _species?.name ?? 'Çipura',
                      height: 66 * scale,
                      width: 146 * scale,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Text(
                  'Tebrikler!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                    color: MeraColors.textPrimary,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 5 * scale),
                Text(
                  species.isEmpty
                      ? 'Önce bir balık türü ekleyin.'
                      : 'Türü seçin, not ekleyin ve devam ederek kaydı tamamlayın.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 6.6 * scale,
                    fontWeight: FontWeight.w400,
                    color: MeraColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 12 * scale),
                if (species.isEmpty)
                  Text(
                    'Kayıtlı tür yok',
                    style: GoogleFonts.inter(
                      color: MeraColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  _SpeciesField(
                    scale: scale,
                    species: species,
                    selected: _species,
                    onChanged: (s) => setState(() => _species = s),
                  ),
                SizedBox(height: 6 * scale),
                _NoteField(scale: scale, controller: _notes),
                SizedBox(height: 8 * scale),
                SizedBox(
                  width: double.infinity,
                  height: 32 * scale,
                  child: FilledButton(
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
                    style: FilledButton.styleFrom(
                      backgroundColor: MeraColors.green,
                      disabledBackgroundColor:
                          MeraColors.green.withValues(alpha: 0.35),
                      foregroundColor: const Color(0xFF002511),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7 * scale),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 8 * scale,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.32,
                      ),
                    ),
                    child: const Text('KAYDET'),
                  ),
                ),
                SizedBox(height: 8 * scale),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2 * scale),
                    child: Text(
                      'İPTAL',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 7 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF19A9FF),
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeciesField extends StatelessWidget {
  const _SpeciesField({
    required this.scale,
    required this.species,
    required this.selected,
    required this.onChanged,
  });

  final double scale;
  final List<Species> species;
  final Species? selected;
  final ValueChanged<Species?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29 * scale,
      padding: EdgeInsets.symmetric(horizontal: 8 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF071B28),
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: const Color(0xFF284653)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Species>(
          value: selected,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: MeraColors.textSecondary,
            size: 14 * scale,
          ),
          dropdownColor: const Color(0xFF0A2231),
          style: GoogleFonts.inter(
            color: MeraColors.textPrimary,
            fontSize: 6.5 * scale,
            fontWeight: FontWeight.w500,
          ),
          hint: Text(
            'Lütfen balık türünü seçin',
            style: GoogleFonts.inter(
              color: const Color(0xFF8197A2),
              fontSize: 6.5 * scale,
            ),
          ),
          selectedItemBuilder: (context) {
            return species.map((s) {
              return Row(
                children: [
                  SirenFishArt.image(
                    speciesName: s.name,
                    height: 20 * scale * 0.55,
                    width: 36 * scale * 0.55,
                  ),
                  SizedBox(width: 8 * scale * 0.5),
                  const SizedBox(width: 4),
                  Text(
                    s.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: MeraColors.textPrimary,
                      fontSize: 6.5 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: species
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      SirenFishArt.image(
                        speciesName: s.name,
                        height: 18,
                        width: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        s.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.scale, required this.controller});

  final double scale;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47 * scale,
      padding: EdgeInsets.fromLTRB(8 * scale, 7 * scale, 8 * scale, 7 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF071B28),
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: const Color(0xFF284653)),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        style: GoogleFonts.inter(
          color: MeraColors.textPrimary,
          fontSize: 6.5 * scale,
          height: 1.35,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
          labelText: 'Not (isteğe bağlı)',
          labelStyle: GoogleFonts.inter(
            color: const Color(0xFF8197A2),
            fontSize: 6.5 * scale,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: 'Not eklemek için...',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF8197A2),
            fontSize: 6.5 * scale,
          ),
        ),
      ),
    );
  }
}
