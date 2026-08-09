import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';

void main() {
  testWidgets('Mera theme + primary button + glow check render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: meraTheme(),
        home: Scaffold(
          backgroundColor: MeraColors.bg,
          body: Column(
            children: [
              const MeraGlowCheck(size: 64),
              MeraPrimaryButton(label: 'BALIK ALDIM', onPressed: () {}),
              MeraOutlineButton(label: 'Paylaş', onPressed: () {}),
              const MeraSectionHeader('Tür Dağılımı'),
              MeraCard(child: Text('card', style: TextStyle(color: MeraColors.textPrimary))),
              const MeraFishHero(label: 'Çipura', height: 100),
            ],
          ),
          bottomNavigationBar: MeraBottomBar(
            index: 0,
            onTap: (_) {},
            items: const [
              (icon: Icons.home_outlined, active: Icons.home, label: 'Ana Sayfa'),
              (icon: Icons.route_outlined, active: Icons.route, label: 'Rotalarım'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('BALIK ALDIM'), findsOneWidget);
    expect(find.text('Paylaş'), findsOneWidget);
    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Çipura'), findsOneWidget);
  });

  test('MeraColors tokens are stable mockup values', () {
    expect(MeraColors.green, const Color(0xFF1FCB6A));
    expect(MeraColors.blue, const Color(0xFF2F7BFF));
    expect(MeraColors.bg, const Color(0xFF0A0F1A));
  });
}
