import 'dart:io';

import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:adair_flutter_lib/wrappers/file_picker_wrapper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/map/map_region_manager.dart';
import 'package:mobile/map/offline_map_region.dart';
import 'package:mobile/navigation/mera_manager.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';

/// Manage regional offline MBTiles packages (Marmara, Ege, …).
class MapRegionPage extends StatelessWidget {
  static const icon = Icons.map_outlined;

  const MapRegionPage();

  @override
  Widget build(BuildContext context) {
    final manager = MapRegionManager.get;

    return StreamBuilder<void>(
      stream: manager.stream,
      builder: (context, _) {
        return ScrollPage(
          appBar: AppBar(
            title: const Text('Çevrimdışı Harita Bölgeleri'),
            centerTitle: true,
          ),
          children: [
            const Padding(
              padding: insetsDefault,
              child: Text(
                'Resmi seyir haritası değildir. Paketler EMODnet/GEBCO ve '
                'OpenSeaMap verilerinden üretilir. İnternet yokken harita '
                'için bir bölgeyi etkinleştirin.',
              ),
            ),
            const MinDivider(),
            ...OfflineMapRegion.catalog.map(
              (region) => _RegionTile(region: region),
            ),
            const MinDivider(),
            ListItem(
              title: const Text('Çevrimiçi haritaya dön'),
              subtitle: const Text('İndirilen paketi kullanmayı bırak'),
              trailing: Icon(
                manager.activeRegionId == null
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              onTap: () async {
                await manager.clearActive();
                if (context.mounted) {
                  showNoticeSnackBar(
                    context,
                    'Çevrimiçi OSM haritası kullanılıyor',
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _RegionTile extends StatelessWidget {
  final OfflineMapRegion region;

  const _RegionTile({required this.region});

  @override
  Widget build(BuildContext context) {
    final manager = MapRegionManager.get;

    return FutureBuilder<bool>(
      future: manager.isDownloaded(region.id),
      builder: (context, snap) {
        final downloaded = snap.data ?? false;
        final active = manager.activeRegionId == region.id;
        final downloading = manager.downloadingId == region.id;

        String status;
        if (downloading) {
          final pct = (manager.downloadProgress * 100).round();
          status = 'İndiriliyor… %$pct';
        } else if (active) {
          status = 'Etkin (çevrimdışı)';
        } else if (downloaded) {
          status = 'İndirildi — dokunarak etkinleştir';
        } else if (region.downloadUrl == null) {
          status = 'Uzak paket yok — dosyadan içe aktar';
        } else {
          status = 'İndirilmedi';
        }

        return Column(
          children: [
            ListItem(
              title: Text(region.nameTr),
              subtitle: Text(region.descriptionTr),
              subtitle2: Text(status),
              trailing: active
                  ? const Icon(Icons.check_circle, color: Colors.lightBlue)
                  : null,
              onTap: downloaded && !downloading
                  ? () async {
                      await manager.setActive(region.id);
                      if (context.mounted) {
                        showSuccessSnackBar(
                          context,
                          '${region.nameTr} çevrimdışı etkin',
                        );
                      }
                    }
                  : null,
            ),
            if (downloading)
              Padding(
                padding: insetsHorizontalDefault,
                child: LinearProgressIndicator(
                  value: manager.downloadProgress > 0
                      ? manager.downloadProgress
                      : null,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(
                left: paddingDefault,
                right: paddingDefault,
                bottom: paddingSmall,
              ),
              child: Wrap(
                spacing: paddingSmall,
                runSpacing: paddingSmall,
                children: [
                  if (!downloaded &&
                      region.downloadUrl != null &&
                      !manager.isDownloading)
                    OutlinedButton.icon(
                      onPressed: () => _download(context, region),
                      icon: const Icon(Icons.download),
                      label: const Text('İndir'),
                    ),
                  if (!manager.isDownloading)
                    OutlinedButton.icon(
                      onPressed: () => _import(context, region),
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Dosyadan aktar'),
                    ),
                  if (downloaded && !downloading)
                    OutlinedButton.icon(
                      onPressed: () => _delete(context, region),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Sil'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => _importMeraJson(context),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Mera JSON'),
                  ),
                ],
              ),
            ),
            const MinDivider(),
          ],
        );
      },
    );
  }

  Future<void> _importMeraJson(BuildContext context) async {
    try {
      final result = await FilePickerWrapper.get.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final bytes = result.files.single.bytes;
      final path = result.files.single.path;
      String json;
      if (bytes != null) {
        json = String.fromCharCodes(bytes);
      } else if (path != null) {
        json = await File(path).readAsString();
      } else {
        showErrorSnackBar(context, 'JSON okunamadı');
        return;
      }
      final n = await MeraManager.get.importJson(json);
      if (context.mounted) {
        showSuccessSnackBar(context, '$n mera noktası içe aktarıldı');
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _download(BuildContext context, OfflineMapRegion region) async {
    try {
      await MapRegionManager.get.download(region);
      if (context.mounted) {
        showSuccessSnackBar(
          context,
          '${region.nameTr} indirildi ve etkinleştirildi',
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _import(BuildContext context, OfflineMapRegion region) async {
    try {
      final result = await FilePickerWrapper.get.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['mbtiles'],
        allowMultiple: false,
        withData: false,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final path = result.files.single.path;
      if (path == null) {
        if (context.mounted) {
          showErrorSnackBar(context, 'Dosya yolu alınamadı');
        }
        return;
      }
      await MapRegionManager.get.importFile(region, path);
      if (context.mounted) {
        showSuccessSnackBar(context, '${region.nameTr} içe aktarıldı');
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _delete(BuildContext context, OfflineMapRegion region) async {
    await MapRegionManager.get.delete(region);
    if (context.mounted) {
      showNoticeSnackBar(context, '${region.nameTr} silindi');
    }
  }
}
