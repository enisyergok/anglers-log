import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/utils/string.dart';
import 'package:adair_flutter_lib/widgets/app_version.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';

import '../utils/string_utils.dart';
import '../widgets/widget.dart';

class AboutPage extends StatelessWidget {
  const AboutPage();

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: AppBar(),
      children: [
        AppVersion(inListTile: true, style: styleSecondary(context)),
        _buildPrivacy(context),
        _buildTideDataSource(context),
        _buildOpenSourceAttribution(context),
      ],
    );
  }

  Widget _buildPrivacy(BuildContext context) {
    return ListItem(
      title: Text(Strings.of(context).aboutPagePrivacy),
      trailing: RightChevronIcon(),
      onTap: () => push(
        context,
        ScrollPage(
          appBar: AppBar(),
          padding: insetsDefault,
          children: [
            Text(
              "CASTIQ (Akıllı. Planlı. Başarılı Av.) tamamen cihazınızda çalışır. Kayıtlarınız, "
              "fotoğraflarınız ve konum verileriniz yalnızca telefonunuzdaki "
              "yerel veritabanında saklanır; hiçbir sunucuya veya buluta "
              "gönderilmez.\n\n"
              "Uygulama, gelgit bilgisi için TideTurtle servisini kullanır "
              "(bkz. aşağıdaki Gelgit Verisi Kaynağı). Bunun dışında "
              "hiçbir üçüncü taraf analiz, reklam veya takip servisi "
              "kullanılmaz.\n\n"
              "Yedekleme, cihazınızda oluşturulan bir zip dosyasını "
              "paylaşma menüsü üzerinden dilediğiniz konuma kaydetmenizi "
              "sağlar; bu işlem de tamamen yereldir ve hesap gerektirmez.",
              style: stylePrimary(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenSourceAttribution(BuildContext context) {
    return ListItem(
      title: const Text("Açık Kaynak Lisansı"),
      subtitle: const Text(
        "CASTIQ, Cohen Adair tarafından GNU GPLv3 lisansı ile "
        "yayımlanan açık kaynaklı \"Anglers' Log\" projesine dayanmaktadır.",
      ),
      trailing: const OpenInWebIcon(),
      onTap: () => UrlLauncherWrapper.of(
        context,
      ).launch("https://github.com/cohenadair/anglers-log"),
    );
  }

  Widget _buildTideDataSource(BuildContext context) {
    return ListItem(
      title: Text(Strings.of(context).aboutPageWorldTides),
      trailing: RightChevronIcon(),
      onTap: () => push(
        context,
        ScrollPage(
          appBar: AppBar(),
          padding: insetsDefault,
          children: [
            Linkify(
              text: Strings.of(context).aboutPageWorldTidePrivacy,
              style: stylePrimary(context),
              linkStyle: styleHyperlink(context),
              onOpen: (link) => UrlLauncherWrapper.of(context).launch(link.url),
            ),
          ],
        ),
      ),
    );
  }
}
