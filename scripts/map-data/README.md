# Bölgesel harita veri hattı (PMTiles)

Bu klasör, **Faz 1.2–1.3** için çevrimdışı harita paketlerinin üretim yeridir.
Uygulama paketleri `MapRegionManager` ile indirir veya dosyadan içe aktarır.

## Hedef çıktı

Her deniz bölgesi için tek bir raster PMTiles dosyası:

| Dosya | Bölge |
|-------|--------|
| `marmara.pmtiles` | Marmara Denizi |
| `ege.pmtiles` | Ege Denizi |
| `karadeniz.pmtiles` | Karadeniz |
| `akdeniz.pmtiles` | Akdeniz |

İçerik (önerilen katmanlar, tek archive veya ayrı bathy dosyası):

1. **Temel / derinlik ısı haritası** — EMODnet Bathymetry (kıyı) + GEBCO (açık deniz)
2. İsteğe bağlı: ileride seamark’ı da pakete gömmek (şu an uygulamada OpenSeaMap online overlay)

## Kaynaklar (ücretsiz / açık)

- [EMODnet Bathymetry](https://emodnet.ec.europa.eu/en/bathymetry) — Avrupa/Akdeniz kıyı detayı
- [GEBCO 2024 Grid](https://www.gebco.net/) — küresel batimetri
- [OpenSeaMap](https://www.openseamap.org/) — seamark (online veya ayrı paket)

**S-57 ENC kullanma** — lisans/yeniden dağıtım riski.

## Önerilen üretim adımları

```text
1. Bölge bbox ile EMODnet/GEBCO GeoTIFF indir
2. Renk skalası (sığ=sıcak, derin=soğuk) ile raster üret (GDAL / QGIS)
3. gdal2tiles veya tippecanoe/rio-mbtiles → MBTiles
4. pmtiles convert *.mbtiles → *.pmtiles
5. Dosyayı GitHub Releases / kendi CDN’ine koy; OfflineMapRegion.downloadUrl güncelle
   veya telefona kopyalayıp uygulamada "Dosyadan aktar"
```

## Güvenlik metni (UI’da zorunlu)

> Bu paket resmi elektronik seyir haritası (ENC/ECDIS) yerine geçmez.
> Yalnızca planlama ve balıkçılık desteği içindir.

## Durum

- Uygulama: bölge yöneticisi + PMTiles okuyucu hazır (`flutter_map_pmtiles`)
- Veri: henüz üretilmiş paket yok — `downloadUrl` null; içe aktarma ile test edilir
