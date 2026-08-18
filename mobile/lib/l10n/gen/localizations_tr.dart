// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AnglersLogLocalizationsTr extends AnglersLogLocalizations {
  AnglersLogLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get catchFieldFavorite => 'Favori';

  @override
  String get catchFieldFavoriteDescription =>
      'Bir avın favorilerinizden biri olup olmadığı.';

  @override
  String get saveReportPageFavorites => 'Yalnızca Favoriler';

  @override
  String get saveReportPageFavoritesFilter => 'Yalnızca favoriler';

  @override
  String unitsPageCentimeters(String value) {
    return 'Santimetre ($value)';
  }

  @override
  String unitsPageMeters(String value) {
    return 'Metre ($value)';
  }

  @override
  String unitsPageAirVisibilityKilometers(String value) {
    return 'Kilometre ($value)';
  }

  @override
  String unitsPageWindSpeedKilometers(String value) {
    return 'Kilometre/saat ($value)';
  }

  @override
  String unitsPageWindSpeedMeters(String value) {
    return 'Metre/saniye ($value)';
  }

  @override
  String get keywordsSpeedMetric => 'kilometre saat hız rüzgar';

  @override
  String get inputColorLabel => 'Renk';

  @override
  String get hashtag => '#MeraAsistaniApp';

  @override
  String get shareTextAndroid =>
      '#MeraAsistaniApp ile Android için paylaşıldı.';

  @override
  String get shareTextApple => '#MeraAsistaniApp ile iOS için paylaşıldı.';

  @override
  String shareLength(String value) {
    return 'Boy: $value';
  }

  @override
  String shareWeight(String value) {
    return 'Ağırlık: $value';
  }

  @override
  String shareBait(String value) {
    return 'Yem: $value';
  }

  @override
  String shareBaits(String value) {
    return 'Yemler: $value';
  }

  @override
  String shareCatches(int value) {
    return 'Avlar: $value';
  }

  @override
  String get done => 'Tamam';

  @override
  String get save => 'Kaydet';

  @override
  String get edit => 'Düzenle';

  @override
  String get copy => 'Kopyala';

  @override
  String get none => 'Yok';

  @override
  String get all => 'Tümü';

  @override
  String get next => 'İleri';

  @override
  String get skip => 'Atla';

  @override
  String get clear => 'Temizle';

  @override
  String get directions => 'Yol tarifi';

  @override
  String get close => 'Kapat';

  @override
  String get back => 'Geri';

  @override
  String get latitude => 'Enlem';

  @override
  String get longitude => 'Boylam';

  @override
  String latLng(String lat, String lng) {
    return 'Enlem: $lat, Boylam: $lng';
  }

  @override
  String latLngNoLabels(String lat, String lng) {
    return '$lat, $lng';
  }

  @override
  String get add => 'Ekle';

  @override
  String get more => 'Diğer';

  @override
  String get na => 'Yok';

  @override
  String get finish => 'Bitir';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String numberOfCatches(int numOfCatches) {
    return '$numOfCatches Av';
  }

  @override
  String get numberOfCatchesSingular => '1 Av';

  @override
  String get unknownSpecies => 'Bilinmeyen Tür';

  @override
  String get unknownBait => 'Bilinmeyen Yem';

  @override
  String get share => 'Paylaş';

  @override
  String get fieldTypeNumber => 'Sayı';

  @override
  String get fieldTypeBoolean => 'Onay kutusu';

  @override
  String get fieldTypeText => 'Metin';

  @override
  String get inputNotesLabel => 'Notlar';

  @override
  String get inputPhotoLabel => 'Fotoğraf';

  @override
  String get inputPhotosLabel => 'Fotoğraf Ekle';

  @override
  String get inputNotSelected => 'Seçilmedi';

  @override
  String get inputAtmosphere => 'Atmosfer ve Hava Durumu';

  @override
  String get inputFetch => 'Getir';

  @override
  String get inputAutoFetch => 'Otomatik getir';

  @override
  String get inputCurrentLocation => 'Mevcut Konum';

  @override
  String get inputGenericFetchError =>
      'Şu anda veri getirilemiyor. Cihazınızın internete bağlı olduğundan emin olun ve yeniden deneyin.';

  @override
  String get fieldWaterClarityLabel => 'Su Berraklığı';

  @override
  String get fieldWaterDepthLabel => 'Su Derinliği';

  @override
  String get fieldWaterTemperatureLabel => 'Su Sıcaklığı';

  @override
  String catchListPageTitle(int numOfCatches) {
    return 'Avlar ($numOfCatches)';
  }

  @override
  String get catchListPageSearchHint => 'Avlarda ara';

  @override
  String get catchListPageEmptyListTitle => 'Av Yok';

  @override
  String get catchListPageEmptyListDescription =>
      'Henüz hiç av eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String catchListItemLength(String value) {
    return 'Boy: $value';
  }

  @override
  String catchListItemWeight(String value) {
    return 'Ağırlık: $value';
  }

  @override
  String get catchListItemNotSet => '-';

  @override
  String catchPageDeleteMessage(String value) {
    return '$value avını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String catchPageDeleteWithTripMessage(String value) {
    return '$value bir geziyle ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get catchPageReleased => 'Bırakıldı';

  @override
  String get catchPageKept => 'Tutuldu';

  @override
  String catchPageQuantityLabel(int value) {
    return 'Adet: $value';
  }

  @override
  String get saveCatchPageNewTitle => 'Yeni Av';

  @override
  String get saveCatchPageEditTitle => 'Avı Düzenle';

  @override
  String get catchFieldTide => 'Gelgit';

  @override
  String get catchFieldDateTime => 'Tarih ve Saat';

  @override
  String get catchFieldDate => 'Tarih';

  @override
  String get catchFieldTime => 'Saat';

  @override
  String get catchFieldPeriod => 'Günün Zamanı';

  @override
  String get catchFieldPeriodDescription => 'Şafak, sabah, alacakaranlık vb.';

  @override
  String get catchFieldSeason => 'Mevsim';

  @override
  String get catchFieldSeasonDescription => 'Kış, ilkbahar, yaz veya sonbahar.';

  @override
  String get catchFieldImages => 'Fotoğraflar';

  @override
  String get catchFieldFishingSpot => 'Av Noktası';

  @override
  String get catchFieldFishingSpotDescription =>
      'Avın yapıldığı konumun koordinatları.';

  @override
  String get catchFieldBait => 'Yem';

  @override
  String get catchFieldAngler => 'Balıkçı';

  @override
  String get catchFieldGear => 'Ekipman';

  @override
  String get catchFieldMethodsDescription => 'Avın nasıl yapıldığı.';

  @override
  String get catchFieldNoMethods => 'Balık tutma yöntemi yok';

  @override
  String get catchFieldNoBaits => 'Yem yok';

  @override
  String get catchFieldNoGear => 'Ekipman yok';

  @override
  String get catchFieldCatchAndRelease => 'Yakala ve Bırak';

  @override
  String get catchFieldCatchAndReleaseDescription =>
      'Bu avın bırakılıp bırakılmadığı.';

  @override
  String get catchFieldTideHeightLabel => 'Gelgit Yüksekliği';

  @override
  String get catchFieldLengthLabel => 'Boy';

  @override
  String get catchFieldWeightLabel => 'Ağırlık';

  @override
  String get catchFieldQuantityLabel => 'Adet';

  @override
  String get catchFieldQuantityDescription => 'Seçilen türden yakalanan adet.';

  @override
  String get catchFieldNotesLabel => 'Notlar';

  @override
  String get saveReportPageNewTitle => 'Yeni Rapor';

  @override
  String get saveReportPageEditTitle => 'Raporu Düzenle';

  @override
  String get saveReportPageNameExists => 'Rapor adı zaten var';

  @override
  String get saveReportPageComparison => 'Karşılaştırma';

  @override
  String get saveReportPageSummary => 'Özet';

  @override
  String get saveReportPageStartDateRangeLabel => 'Karşılaştır';

  @override
  String get saveReportPageEndDateRangeLabel => 'ile';

  @override
  String get saveReportPageAllAnglers => 'Tüm balıkçılar';

  @override
  String get saveReportPageAllWaterClarities => 'Tüm su berraklıkları';

  @override
  String get saveReportPageAllSpecies => 'Tüm türler';

  @override
  String get saveReportPageAllBaits => 'Tüm yemler';

  @override
  String get saveReportPageAllGear => 'Tüm ekipman';

  @override
  String get saveReportPageAllBodiesOfWater => 'Tüm su kütleleri';

  @override
  String get saveReportPageAllFishingSpots => 'Tüm av noktaları';

  @override
  String get saveReportPageAllMethods => 'Tüm balık tutma yöntemleri';

  @override
  String get saveReportPageCatchAndRelease => 'Yalnızca Yakala ve Bırak';

  @override
  String get saveReportPageCatchAndReleaseFilter => 'Yalnızca yakala ve bırak';

  @override
  String get saveReportPageAllWindDirections => 'Tüm rüzgar yönleri';

  @override
  String get saveReportPageAllSkyConditions => 'Tüm gökyüzü koşulları';

  @override
  String get saveReportPageAllMoonPhases => 'Tüm ay evreleri';

  @override
  String get saveReportPageAllTideTypes => 'Tüm gelgitler';

  @override
  String get photosPageMenuLabel => 'Fotoğraflar';

  @override
  String get photosPageEmptyTitle => 'Fotoğraf Yok';

  @override
  String get photosPageEmptyDescription =>
      'Avlara eklenen tüm fotoğraflar burada gösterilir. Av eklemek için %s simgesine dokunun.';

  @override
  String baitListPageTitle(int numOfBaits) {
    return 'Yemler ($numOfBaits)';
  }

  @override
  String get baitListPageOtherCategory => 'Kategori Yok';

  @override
  String get baitListPageSearchHint => 'Yemlerde ara';

  @override
  String baitListPageDeleteMessage(String bait, int numOfCatches) {
    return '$bait, $numOfCatches av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String baitListPageDeleteMessageSingular(String bait) {
    return '$bait, 1 av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get baitListPageEmptyListTitle => 'Yem Yok';

  @override
  String get baitListPageEmptyListDescription =>
      'Henüz hiç yem eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String get baitsSummaryEmpty =>
      'Günlüğünüze yem eklendiğinde, avlarının özeti burada gösterilir.';

  @override
  String baitListPageVariantsLabel(int numOfVariants) {
    return '$numOfVariants Varyant';
  }

  @override
  String get baitListPageVariantLabel => '1 Varyant';

  @override
  String get saveBaitPageNewTitle => 'Yeni Yem';

  @override
  String get saveBaitPageEditTitle => 'Yemi Düzenle';

  @override
  String get saveBaitPageCategoryLabel => 'Yem Kategorisi';

  @override
  String get saveBaitPageBaitExists =>
      'Bu özelliklere sahip bir yem zaten var. Lütfen en az bir alanı değiştirip yeniden deneyin.';

  @override
  String get saveBaitPageVariants => 'Varyantlar';

  @override
  String get saveBaitPageDeleteVariantSingular =>
      'Bu varyant 1 av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String saveBaitPageDeleteVariantPlural(int numOfCatches) {
    return 'Bu varyant $numOfCatches av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get saveBaitCategoryPageNewTitle => 'Yeni Yem Kategorisi';

  @override
  String get saveBaitCategoryPageEditTitle => 'Yem Kategorisini Düzenle';

  @override
  String get saveBaitCategoryPageExistsMessage => 'Yem kategorisi zaten var';

  @override
  String baitCategoryListPageTitle(int numOfCategories) {
    return 'Yem Kategorileri ($numOfCategories)';
  }

  @override
  String baitCategoryListPageDeleteMessage(String bait, int numOfBaits) {
    return '$bait, $numOfBaits yem ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String baitCategoryListPageDeleteMessageSingular(String category) {
    return '$category, 1 yem ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get baitCategoryListPageSearchHint => 'Yem kategorilerinde ara';

  @override
  String get baitCategoryListPageEmptyListTitle => 'Yem Kategorisi Yok';

  @override
  String get baitCategoryListPageEmptyListDescription =>
      'Henüz hiç yem kategorisi eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String get saveAnglerPageNewTitle => 'Yeni Balıkçı';

  @override
  String get saveAnglerPageEditTitle => 'Balıkçıyı Düzenle';

  @override
  String get saveAnglerPageExistsMessage => 'Balıkçı zaten var';

  @override
  String anglerListPageTitle(int numOfAnglers) {
    return 'Balıkçılar ($numOfAnglers)';
  }

  @override
  String anglerListPageDeleteMessage(String angler, int numOfCatches) {
    return '$angler, $numOfCatches av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String anglerListPageDeleteMessageSingular(String angler) {
    return '$angler, 1 av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get anglerListPageSearchHint => 'Balıkçılarda ara';

  @override
  String get anglerListPageEmptyListTitle => 'Balıkçı Yok';

  @override
  String get anglerListPageEmptyListDescription =>
      'Henüz hiç balıkçı eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String get anglersSummaryEmpty =>
      'Günlüğünüze balıkçı eklendiğinde, avlarının özeti burada gösterilir.';

  @override
  String get saveMethodPageNewTitle => 'Yeni Balık Tutma Yöntemi';

  @override
  String get saveMethodPageEditTitle => 'Balık Tutma Yöntemini Düzenle';

  @override
  String get saveMethodPageExistsMessage => 'Balık tutma yöntemi zaten var';

  @override
  String methodListPageTitle(int numOfMethods) {
    return 'Balık Tutma Yöntemleri ($numOfMethods)';
  }

  @override
  String methodListPageDeleteMessage(String method, int numOfCatches) {
    return '$method, $numOfCatches av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String methodListPageDeleteMessageSingular(String method) {
    return '$method, 1 av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get methodListPageSearchHint => 'Balık tutma yöntemlerinde ara';

  @override
  String get methodListPageEmptyListTitle => 'Balık Tutma Yöntemi Yok';

  @override
  String get methodListPageEmptyListDescription =>
      'Henüz hiç balık tutma yöntemi eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String get methodSummaryEmpty =>
      'Günlüğünüze balık tutma yöntemi eklendiğinde, avlarının özeti burada gösterilir.';

  @override
  String get saveWaterClarityPageNewTitle => 'Yeni Su Berraklığı';

  @override
  String get saveWaterClarityPageEditTitle => 'Su Berraklığını Düzenle';

  @override
  String get saveWaterClarityPageExistsMessage => 'Su berraklığı zaten var';

  @override
  String waterClarityListPageTitle(int numOfClarities) {
    return 'Su Berraklıkları ($numOfClarities)';
  }

  @override
  String waterClarityListPageDeleteMessage(String clarity, int numOfCatches) {
    return '$clarity, $numOfCatches av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String waterClarityListPageDeleteMessageSingular(String clarity) {
    return '$clarity, 1 av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get waterClarityListPageSearchHint => 'Su berraklıklarında ara';

  @override
  String get waterClarityListPageEmptyListTitle => 'Su Berraklığı Yok';

  @override
  String get waterClarityListPageEmptyListDescription =>
      'Henüz hiç su berraklığı eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String get waterClaritiesSummaryEmpty =>
      'Günlüğünüze su berraklığı eklendiğinde, avlarının özeti burada gösterilir.';

  @override
  String get statsPageSpeciesSummary => 'Tür Özeti';

  @override
  String get statsPageCatchSummary => 'Av Özeti';

  @override
  String get statsPageAnglerSummary => 'Balıkçı Özeti';

  @override
  String get statsPageBaitSummary => 'Yem Özeti';

  @override
  String statsPageBaitVariantAllLabel(String bait) {
    return '$bait (Tüm Varyantlar)';
  }

  @override
  String get statsPageBodyOfWaterSummary => 'Su Kütlesi Özeti';

  @override
  String get statsPageFishingSpotSummary => 'Av Noktası Özeti';

  @override
  String get statsPageMethodSummary => 'Balık Tutma Yöntemi Özeti';

  @override
  String get statsPageMoonPhaseSummary => 'Ay Evresi Özeti';

  @override
  String get statsPagePeriodSummary => 'Günün Zamanı Özeti';

  @override
  String get statsPageSeasonSummary => 'Mevsim Özeti';

  @override
  String get statsPageTideSummary => 'Gelgit Özeti';

  @override
  String get statsPageWaterClaritySummary => 'Su Berraklığı Özeti';

  @override
  String get statsPageGearSummary => 'Ekipman Özeti';

  @override
  String get statsPagePersonalBests => 'Kişisel Rekorlar';

  @override
  String get personalBestsTrip => 'En İyi Gezi';

  @override
  String get personalBestsLongest => 'En Uzun';

  @override
  String get personalBestsHeaviest => 'En Ağır';

  @override
  String get personalBestsSpeciesByLength => 'Boyuna Göre Türler';

  @override
  String get personalBestsSpeciesByLengthLabel => 'En Uzun';

  @override
  String get personalBestsSpeciesByWeight => 'Ağırlığa Göre Türler';

  @override
  String get personalBestsSpeciesByWeightLabel => 'En Ağır';

  @override
  String get personalBestsShowAllSpecies => 'Tüm türleri gör';

  @override
  String get personalBestsAverage => 'Ortalama';

  @override
  String get personalBestsNoDataTitle => 'Veri Yok';

  @override
  String get personalBestsNoDataDescription =>
      'Seçilen tarih aralığı için kişisel rekorlarınız belirlenemiyor. Bir gezi eklediğinizden veya boy/ağırlık değeri olan bir av eklediğinizden emin olun.';

  @override
  String get reportViewEmptyLog => 'Boş Günlük';

  @override
  String get reportViewEmptyLogDescription =>
      'Henüz hiç av eklemediniz. Av eklemek için %s simgesine dokunun.';

  @override
  String get reportSummaryPerSpecies => 'Tür Başına';

  @override
  String get reportSummaryPerFishingSpot => 'Av Noktası Başına';

  @override
  String get reportSummaryPerBait => 'Yem Başına';

  @override
  String get reportSummaryPerAngler => 'Balıkçı Başına';

  @override
  String get reportSummaryPerBodyOfWater => 'Su Kütlesi Başına';

  @override
  String get reportSummaryPerMethod => 'Balık Tutma Yöntemi Başına';

  @override
  String get reportSummaryPerMoonPhase => 'Ay Evresi Başına';

  @override
  String get reportSummaryPerPeriod => 'Günün Zamanı Başına';

  @override
  String get reportSummaryPerSeason => 'Mevsim Başına';

  @override
  String get reportSummaryPerTideType => 'Gelgit Başına';

  @override
  String get reportSummaryPerWaterClarity => 'Su Berraklığı Başına';

  @override
  String get reportSummarySinceLastCatch => 'Son Avdan Bu Yana';

  @override
  String get reportSummaryFilters => 'Filtreler';

  @override
  String get reportSummaryViewSpecies => 'Tüm türleri gör';

  @override
  String get reportSummaryPerSpeciesDescription =>
      'Tür başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryViewFishingSpots => 'Tüm av noktalarını gör';

  @override
  String get reportSummaryPerFishingSpotDescription =>
      'Av noktası başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryViewBaits => 'Tüm yemleri gör';

  @override
  String get reportSummaryPerBaitDescription =>
      'Yem başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryViewMoonPhases => 'Tüm ay evrelerini gör';

  @override
  String get reportSummaryPerMoonPhaseDescription =>
      'Ay evresi başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryViewTides => 'Tüm gelgit türlerini gör';

  @override
  String get reportSummaryPerTideDescription =>
      'Gelgit türü başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryViewAnglers => 'Tüm balıkçıları gör';

  @override
  String get reportSummaryPerAnglerDescription =>
      'Balıkçı başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryViewBodiesOfWater => 'Tüm su kütlelerini gör';

  @override
  String get reportSummaryPerBodyOfWaterDescription =>
      'Su kütlesi başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryViewMethods => 'Tüm balık tutma yöntemlerini gör';

  @override
  String get reportSummaryPerMethodDescription =>
      'Balık tutma yöntemi başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryViewPeriods => 'Tüm günün zamanlarını gör';

  @override
  String get reportSummaryPerPeriodDescription =>
      'Günün zamanı başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryViewSeasons => 'Tüm mevsimleri gör';

  @override
  String get reportSummaryPerSeasonDescription =>
      'Mevsim başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryViewWaterClarities => 'Tüm su berraklıklarını gör';

  @override
  String get reportSummaryPerWaterClarityDescription =>
      'Su berraklığı başına av sayısı gösteriliyor.';

  @override
  String get reportSummaryPerHour => 'Saat Başına';

  @override
  String get reportSummaryViewAllHours => 'Tüm saatleri gör';

  @override
  String get reportSummaryViewAllHoursDescription =>
      'Günün her saati için av sayısı gösteriliyor.';

  @override
  String get reportSummaryPerMonth => 'Ay Başına';

  @override
  String get reportSummaryViewAllMonths => 'Tüm ayları gör';

  @override
  String get reportSummaryViewAllMonthsDescription =>
      'Yılın her ayı için av sayısı gösteriliyor.';

  @override
  String get reportSummaryPerGear => 'Ekipman Başına';

  @override
  String get reportSummaryViewGear => 'Tüm ekipmanı gör';

  @override
  String get reportSummaryPerGearDescription =>
      'Ekipman başına av sayısı gösteriliyor.';

  @override
  String get morePageTitle => 'Diğer';

  @override
  String get morePageRateApp => 'Mera Asistanı\'nı Değerlendir';

  @override
  String get morePagePro => 'Mera Asistanı Pro';

  @override
  String get morePageRateErrorApple => 'Cihazda App Store yüklü değil.';

  @override
  String get morePageRateErrorAndroid =>
      'Cihazda web tarayıcı uygulaması yüklü değil.';

  @override
  String tripListPageTitle(int numOfTrips) {
    return 'Geziler ($numOfTrips)';
  }

  @override
  String get tripListPageSearchHint => 'Gezilerde ara';

  @override
  String get tripListPageEmptyListTitle => 'Gezi Yok';

  @override
  String get tripListPageEmptyListDescription =>
      'Henüz hiç gezi eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String tripListPageDeleteMessage(String trip) {
    return '$trip gezisini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get saveTripPageEditTitle => 'Geziyi Düzenle';

  @override
  String get saveTripPageNewTitle => 'Yeni Gezi';

  @override
  String get saveTripPageAutoSetTitle => 'Alanları Otomatik Ayarla';

  @override
  String get saveTripPageAutoSetDescription =>
      'Avlar seçildiğinde uygun alanları otomatik ayarla.';

  @override
  String get saveTripPageAutoAddCatchesTitle => 'Avları Otomatik Ekle';

  @override
  String get saveTripPageAutoAddCatchesDescription =>
      'Gezinin zaman aralığına düşen avları otomatik ekle.';

  @override
  String saveTripPageAutoAddCatchesPrompt(int numOfCatches) {
    return 'Bu gezi sırasında henüz eklenmemiş $numOfCatches av yapıldı. Şimdi eklensin mi?';
  }

  @override
  String get saveTripPageAutoAddCatchesPromptSingular =>
      'Bu gezi sırasında henüz eklenmemiş 1 av yapıldı. Şimdi eklensin mi?';

  @override
  String get saveTripPageStartDate => 'Başlangıç Tarihi';

  @override
  String get saveTripPageStartTime => 'Başlangıç Saati';

  @override
  String get saveTripPageStartDateTime => 'Başlangıç Tarihi ve Saati';

  @override
  String get saveTripPageEndDate => 'Bitiş Tarihi';

  @override
  String get saveTripPageEndTime => 'Bitiş Saati';

  @override
  String get saveTripPageEndDateTime => 'Bitiş Tarihi ve Saati';

  @override
  String get saveTripPageAllDay => 'Tüm Gün';

  @override
  String get saveTripPageCatchesDesc => 'Bu gezide kaydedilen kupalar.';

  @override
  String get saveTripPageNoCatches => 'Av yok';

  @override
  String get saveTripPageNoBodiesOfWater => 'Su kütlesi yok';

  @override
  String get saveTripPageNoGpsTrails => 'GPS izi yok';

  @override
  String get tripCatchesPerSpecies => 'Tür Başına Avlar';

  @override
  String get tripCatchesPerFishingSpot => 'Av Noktası Başına Avlar';

  @override
  String get tripCatchesPerAngler => 'Balıkçı Başına Avlar';

  @override
  String get tripCatchesPerBait => 'Yem Başına Avlar';

  @override
  String get tripSkunked => 'Boş Dönüldü';

  @override
  String get settingsPageTitle => 'Ayarlar';

  @override
  String get settingsPageFetchAtmosphereTitle => 'Hava Durumunu Otomatik Getir';

  @override
  String get settingsPageFetchAtmosphereDescription =>
      'Yeni av ve gezi eklerken atmosfer ve hava durumu verilerini otomatik getir.';

  @override
  String get settingsPageFetchTideTitle => 'Gelgiti Otomatik Getir';

  @override
  String get settingsPageFetchTideDescription =>
      'Yeni av eklerken gelgit verilerini otomatik getir.';

  @override
  String get settingsPageAbout => 'Hakkında, Koşullar ve Gizlilik';

  @override
  String get settingsPageFishingSpotDistanceTitle =>
      'Otomatik Av Noktası Mesafesi';

  @override
  String get settingsPageFishingSpotDistanceDescription =>
      'Av eklerken av noktalarının otomatik seçileceği mesafe.';

  @override
  String get settingsPageMinGpsTrailDistanceTitle => 'GPS İzi Mesafesi';

  @override
  String get settingsPageMinGpsTrailDistanceDescription =>
      'Bir GPS izindeki noktalar arasındaki minimum mesafe.';

  @override
  String get settingsPageThemeTitle => 'Tema';

  @override
  String get settingsPageThemeSystem => 'Sistem';

  @override
  String get settingsPageThemeLight => 'Açık';

  @override
  String get settingsPageThemeDark => 'Koyu';

  @override
  String get settingsPageThemeSelect => 'Tema Seç';

  @override
  String get unitsPageTitle => 'Ölçü Birimleri';

  @override
  String unitsPageFractionalInches(String value) {
    return 'Kesirli inç ($value)';
  }

  @override
  String unitsPageInches(String value) {
    return 'İnç ($value)';
  }

  @override
  String get unitsPageCatchWeight => 'Av Ağırlığı';

  @override
  String unitsPageCatchWeightPoundsOunces(String value) {
    return 'Pound ve ons ($value)';
  }

  @override
  String unitsPageCatchWeightPounds(String value) {
    return 'Pound ($value)';
  }

  @override
  String unitsPageCatchWeightKilograms(String value) {
    return 'Kilogram ($value)';
  }

  @override
  String unitsPageWaterTemperatureFahrenheit(String value) {
    return 'Fahrenhayt ($value)';
  }

  @override
  String unitsPageWaterTemperatureCelsius(String value) {
    return 'Santigrat ($value)';
  }

  @override
  String unitsPageFeetInches(String value) {
    return 'Fit ve inç ($value)';
  }

  @override
  String unitsPageFeet(String value) {
    return 'Ayaklar ($value)';
  }

  @override
  String unitsPageAirTemperatureFahrenheit(String value) {
    return 'Fahrenhayt ($value)';
  }

  @override
  String unitsPageAirTemperatureCelsius(String value) {
    return 'Santigrat ($value)';
  }

  @override
  String unitsPageAirPressureInHg(String value) {
    return 'İnç cıva ($value)';
  }

  @override
  String unitsPageAirPressurePsi(String value) {
    return 'İnç kare başına pound ($value)';
  }

  @override
  String unitsPageAirPressureMillibars(String value) {
    return 'Milibar ($value)';
  }

  @override
  String unitsPageAirVisibilityMiles(String value) {
    return 'Mil ($value)';
  }

  @override
  String unitsPageWindSpeedMiles(String value) {
    return 'Saat başına mil ($value)';
  }

  @override
  String get unitsPageDistanceTitle => 'Mesafe';

  @override
  String get unitsPageTippetLengthTitle => 'Atkı Uzunluğu';

  @override
  String mapPageDeleteFishingSpot(String spot, int numOfCatches) {
    return '$spot, $numOfCatches av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String mapPageDeleteFishingSpotSingular(String spot) {
    return '$spot, 1 av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String mapPageDeleteFishingSpotNoName(int numOfCatches) {
    return 'Bu av noktası $numOfCatches av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get mapPageDeleteFishingSpotNoNameSingular =>
      'Bu av noktası 1 av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get mapPageAddCatch => 'Av Ekle';

  @override
  String get mapPageSearchHint => 'Av noktalarında ara';

  @override
  String get mapPageDroppedPin => 'Yeni Av Noktası';

  @override
  String get mapPageMapTypeLight => 'Açık';

  @override
  String get mapPageMapTypeSatellite => 'Uydu';

  @override
  String get mapPageMapTypeDark => 'Koyu';

  @override
  String get mapPageErrorGettingLocation =>
      'Mevcut konum alınamadı. Cihazınızın konum hizmetlerinin açık olduğundan emin olun ve daha sonra yeniden deneyin.';

  @override
  String get mapPageErrorOpeningDirections =>
      'Bu cihazda kullanılabilir bir navigasyon uygulaması yok.';

  @override
  String get mapPageAppleMaps => 'Apple Haritalar™';

  @override
  String get mapPageGoogleMaps => 'Google Haritalar™';

  @override
  String get mapPageWaze => 'Waze™';

  @override
  String get mapPageMapTypeTooltip => 'Harita Türünü Seç';

  @override
  String get mapPageMyLocationTooltip => 'Konumumu Göster';

  @override
  String get mapPageShowAllTooltip => 'Tüm Av Noktalarını Göster';

  @override
  String get mapPageStartTrackingTooltip => 'GPS İzini Başlat';

  @override
  String get mapPageStopTrackingTooltip => 'GPS İzini Durdur';

  @override
  String get mapPageAddTooltip => 'Av Noktası Ekle';

  @override
  String get saveFishingSpotPageEditTitle => 'Av Noktasını Düzenle';

  @override
  String get saveFishingSpotPageBodyOfWaterLabel => 'Su Kütlesi';

  @override
  String get saveFishingSpotPageCoordinatesLabel => 'Koordinatlar';

  @override
  String get formPageManageFieldText => 'Alanları Yönet';

  @override
  String get formPageAddCustomFieldNote =>
      'Özel alan eklemek için %s simgesine dokunun.';

  @override
  String get formPageManageFieldsNote =>
      'Alanları yönetmek için %s simgesine dokunun.';

  @override
  String get formPageManageFieldsProDescription =>
      'Özel alanları kullanabilmek için Mera Asistanı Pro abonesi olmanız gerekir.';

  @override
  String get formPageManageUnits => 'Birimleri Yönet';

  @override
  String get formPageConfirmBackDesc =>
      'Kaydedilmemiş değişiklikler kaybolacak. Değişiklikleri silip geri dönmek istediğinizden emin misiniz?';

  @override
  String get formPageConfirmBackAction => 'Vazgeç';

  @override
  String get saveCustomEntityPageNewTitle => 'Yeni Alan';

  @override
  String get saveCustomEntityPageEditTitle => 'Alanı Düzenle';

  @override
  String get saveCustomEntityPageNameExists => 'Alan adı zaten var';

  @override
  String customEntityListPageTitle(int numOfFields) {
    return 'Özel Alanlar ($numOfFields)';
  }

  @override
  String customEntityListPageDelete(
    String field,
    int numOfCatches,
    int numOfBaits,
  ) {
    return '$field özel alanı artık avlar ($numOfCatches) veya yemler ($numOfBaits) ile ilişkilendirilmeyecek; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get customEntityListPageSearchHint => 'Alanlarda ara';

  @override
  String get customEntityListPageEmptyListTitle => 'Özel Alan Yok';

  @override
  String get customEntityListPageEmptyListDescription =>
      'Henüz hiç özel alan eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String get imagePickerConfirmDelete =>
      'Bu fotoğrafı silmek istediğinizden emin misiniz?';

  @override
  String get imagePickerPageNoPhotosFoundTitle => 'Fotoğraf bulunamadı';

  @override
  String get imagePickerPageNoPhotosFound =>
      'Yukarıdaki açılır menüden fotoğraf kaynağını değiştirmeyi deneyin.';

  @override
  String get imagePickerPageCameraLabel => 'Kamera';

  @override
  String get imagePickerPageGalleryLabel => 'Galeri';

  @override
  String get imagePickerPageBrowseLabel => 'Gözat';

  @override
  String get imagePickerPageChooseSourceTitle => 'Fotoğraf Kaynağını Seç';

  @override
  String get imagePickerPageNoPhotoLabel => 'Fotoğraf Yok';

  @override
  String imagePickerPageSelectedLabel(int numSelected, int numTotal) {
    return '$numSelected / $numTotal Seçildi';
  }

  @override
  String get imagePickerPageNoPermissionTitle => 'İzin gerekli';

  @override
  String get imagePickerPageNoPermissionMessage =>
      'Fotoğraf eklemek için Mera Asistanı\'na fotoğraf kitaplığınıza erişim izni vermelisiniz. Bunun için cihaz ayarlarını açın.\n\nAlternatif olarak yukarıdaki açılır menüden fotoğraf kaynağını değiştirebilirsiniz.';

  @override
  String get imagePickerPageOpenSettings => 'Ayarları Aç';

  @override
  String get imagePickerPageImageDownloadError =>
      'Fotoğraf eklenemedi. İnternete bağlı olduğunuzdan emin olun ve yeniden deneyin.';

  @override
  String get imagePickerPageImagesDownloadError =>
      'Bir veya daha fazla fotoğraf eklenemedi. İnternete bağlı olduğunuzdan emin olun ve yeniden deneyin.';

  @override
  String reportListPageConfirmDelete(String report) {
    return '$report raporunu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get reportListPageReportTitle => 'Özel Raporlar';

  @override
  String get reportListPageReportAddNote =>
      'Özel rapor eklemek için %s simgesine dokunun.';

  @override
  String get reportListPageReportsProDescription =>
      'Özel raporları görüntülemek için Mera Asistanı Pro abonesi olmanız gerekir.';

  @override
  String get saveSpeciesPageNewTitle => 'Yeni Tür';

  @override
  String get saveSpeciesPageEditTitle => 'Türü Düzenle';

  @override
  String get saveSpeciesPageExistsError => 'Tür zaten var';

  @override
  String speciesListPageTitle(int numOfSpecies) {
    return 'Türler ($numOfSpecies)';
  }

  @override
  String speciesListPageConfirmDelete(String species) {
    return '$species, 0 av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String speciesListPageCatchDeleteErrorSingular(String species) {
    return '$species, 1 av ile ilişkilidir ve silinemez.';
  }

  @override
  String speciesListPageCatchDeleteErrorPlural(
    String species,
    int numOfCatches,
  ) {
    return '$species, $numOfCatches av ile ilişkilidir ve silinemez.';
  }

  @override
  String get speciesListPageSearchHint => 'Türlerde ara';

  @override
  String get speciesListPageEmptyListTitle => 'Tür Yok';

  @override
  String get speciesListPageEmptyListDescription =>
      'Henüz hiç tür eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String fishingSpotListPageTitle(int numOfSpots) {
    return 'Av Noktaları ($numOfSpots)';
  }

  @override
  String get fishingSpotListPageSearchHint => 'Av noktalarında ara';

  @override
  String get fishingSpotListPageEmptyListTitle => 'Av Noktası Yok';

  @override
  String get fishingSpotListPageEmptyListDescription =>
      'Av noktası eklemek için haritadaki %s düğmesine dokunun ve bırakılan pimi kaydedin.';

  @override
  String get fishingSpotsSummaryEmpty =>
      'Günlüğünüze av noktası eklendiğinde, avlarının özeti burada gösterilir.';

  @override
  String get fishingSpotListPageNoBodyOfWater => 'Su Kütlesi Yok';

  @override
  String get editCoordinatesHint =>
      'Av noktasının koordinatlarını güncellemek için haritayı sürükleyin.';

  @override
  String get feedbackPageTitle => 'Geri Bildirim Gönder';

  @override
  String get feedbackPageSend => 'Gönder';

  @override
  String get feedbackPageMessage => 'Mesaj';

  @override
  String get feedbackPageBugType => 'Hata';

  @override
  String get feedbackPageSuggestionType => 'Öneri';

  @override
  String get feedbackPageFeedbackType => 'Geri bildirim';

  @override
  String get feedbackPageErrorSending =>
      'Geri bildirim gönderilirken hata oluştu. Lütfen daha sonra yeniden deneyin.';

  @override
  String get feedbackPageConnectionError =>
      'İnternet bağlantısı yok. Bağlantınızı kontrol edip yeniden deneyin.';

  @override
  String get onboardingJourneyCatchFieldDescription =>
      'Bir av kaydederken ne bilmek istiyorsunuz?';

  @override
  String get onboardingJourneyManageFieldsTitle => 'Alanları Yönet';

  @override
  String get onboardingJourneyManageFieldsDescription =>
      'Varsayılan alanları yönetin veya ekipman, av, yem, gezi ya da hava durumu eklerken/düzenlerken istediğiniz zaman özel alan ekleyin.';

  @override
  String get onboardingJourneyLocationAccessTitle => 'Konum Erişimi';

  @override
  String get onboardingJourneyLocationAccessDescription =>
      'Mera Asistanı, uygulama içi haritada konumunuzu göstermek, av eklerken av noktalarını otomatik oluşturmak ve balık tutarken GPS izleri oluşturmak için konum hizmetlerini kullanır.';

  @override
  String get onboardingJourneyHowToFeedbackTitle => 'Geri Bildirim Gönder';

  @override
  String get onboardingJourneyHowToFeedbackDescription =>
      'Sorun bildirin, özellik önerin veya istediğiniz zaman geri bildirim gönderin. Sizden haber almak isteriz!';

  @override
  String get onboardingJourneyNotNow => 'Şimdi Değil';

  @override
  String get emptyListPlaceholderNoResultsTitle => 'Sonuç bulunamadı';

  @override
  String get emptyListPlaceholderNoResultsDescription =>
      'Aradığınızı bulmak için lütfen arama filtrenizi ayarlayın.';

  @override
  String get proPageBackup => 'Otomatik yerel yedekleme';

  @override
  String get proPageCsv => 'Günlüğü elektronik tabloya dışa aktar (CSV)';

  @override
  String get proPageAtmosphere =>
      'Atmosfer, hava durumu ve gelgit verilerini getir';

  @override
  String get proPageReports => 'Özel raporlar ve filtreler oluştur';

  @override
  String get proPageCustomFields => 'Özel giriş alanları oluştur';

  @override
  String get proPageGpsTrails =>
      'Gerçek zamanlı GPS izleri oluştur ve takip et';

  @override
  String get proPageCopyCatch => 'Avları kopyala';

  @override
  String get proPageSpeciesCounter => 'Gerçek zamanlı yakalanan tür sayacı';

  @override
  String get periodDawn => 'Şafak';

  @override
  String get periodMorning => 'Sabah';

  @override
  String get periodMidday => 'Öğle';

  @override
  String get periodAfternoon => 'Öğleden sonra';

  @override
  String get periodEvening => 'Akşam';

  @override
  String get periodDusk => 'Alacakaranlık';

  @override
  String get periodNight => 'Gece';

  @override
  String get periodPickerAll => 'Tüm günün zamanları';

  @override
  String get seasonWinter => 'Kış';

  @override
  String get seasonSpring => 'İlkbahar';

  @override
  String get seasonSummer => 'Yaz';

  @override
  String get seasonAutumn => 'Sonbahar';

  @override
  String get seasonPickerAll => 'Tüm mevsimler';

  @override
  String get measurementSystemImperial => 'İngiliz';

  @override
  String get measurementSystemImperialDecimal => 'İngiliz Ondalık';

  @override
  String get measurementSystemMetric => 'Metrik';

  @override
  String get numberBoundaryAny => 'Herhangi';

  @override
  String get numberBoundaryLessThan => 'Küçüktür (<)';

  @override
  String get numberBoundaryLessThanOrEqualTo => 'Küçük veya eşittir (≤)';

  @override
  String get numberBoundaryEqualTo => 'Eşittir (=)';

  @override
  String get numberBoundaryGreaterThan => 'Büyüktür (>)';

  @override
  String get numberBoundaryGreaterThanOrEqualTo => 'Büyük veya eşittir (≥)';

  @override
  String get numberBoundaryRange => 'Aralık';

  @override
  String numberBoundaryLessThanValue(String value) {
    return '< $value';
  }

  @override
  String numberBoundaryLessThanOrEqualToValue(String value) {
    return '≤ $value';
  }

  @override
  String numberBoundaryEqualToValue(String value) {
    return '= $value';
  }

  @override
  String numberBoundaryGreaterThanValue(String value) {
    return '> $value';
  }

  @override
  String numberBoundaryGreaterThanOrEqualToValue(String value) {
    return '≥ $value';
  }

  @override
  String numberBoundaryRangeValue(String from, String to) {
    return '$from - $to';
  }

  @override
  String get unitFeet => 'ft';

  @override
  String get unitInches => 'in';

  @override
  String get unitPounds => 'lbs';

  @override
  String get unitOunces => 'oz';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitMeters => 'm';

  @override
  String get unitCentimeters => 'cm';

  @override
  String get unitKilograms => 'kg';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitMilesPerHour => 'mph';

  @override
  String get unitKilometersPerHour => 'km/s';

  @override
  String get unitMillibars => 'MB';

  @override
  String get unitPoundsPerSquareInch => 'psi';

  @override
  String get unitPercent => '%';

  @override
  String get unitInchOfMercury => 'inHg';

  @override
  String get unitMiles => 'mi';

  @override
  String get unitKilometers => 'km';

  @override
  String get unitX => 'X';

  @override
  String get unitAught => 'O';

  @override
  String get unitPoundTest => 'lb test';

  @override
  String get unitHashtag => '#';

  @override
  String get unitMetersPerSecond => 'm/s';

  @override
  String unitConvertToValue(String unit) {
    return '$unit birimine dönüştür';
  }

  @override
  String get numberFilterInputFrom => 'Başlangıç';

  @override
  String get numberFilterInputTo => 'Bitiş';

  @override
  String get numberFilterInputValue => 'Değer';

  @override
  String get filterTitleWaterTemperature => 'Su Sıcaklığı Filtresi';

  @override
  String get filterTitleWaterDepth => 'Su Derinliği Filtresi';

  @override
  String get filterTitleLength => 'Boy Filtresi';

  @override
  String get filterTitleWeight => 'Ağırlık Filtresi';

  @override
  String get filterTitleQuantity => 'Adet Filtresi';

  @override
  String get filterTitleAirTemperature => 'Hava Sıcaklığı Filtresi';

  @override
  String get filterTitleAirPressure => 'Atmosfer Basıncı Filtresi';

  @override
  String get filterTitleAirHumidity => 'Hava Nemi Filtresi';

  @override
  String get filterTitleAirVisibility => 'Hava Görüş Filtresi';

  @override
  String get filterTitleWindSpeed => 'Rüzgar Hızı Filtresi';

  @override
  String filterValueWaterTemperature(String value) {
    return 'Su Sıcaklığı: $value';
  }

  @override
  String filterValueWaterDepth(String value) {
    return 'Su Derinliği: $value';
  }

  @override
  String filterValueLength(String value) {
    return 'Uzunluk: $value';
  }

  @override
  String filterValueWeight(String value) {
    return 'Ağırlık: $value';
  }

  @override
  String filterValueQuantity(String value) {
    return 'Adet: $value';
  }

  @override
  String filterValueAirTemperature(String value) {
    return 'Hava Sıcaklığı: $value';
  }

  @override
  String filterValueAirPressure(String value) {
    return 'Atmosfer Basıncı: $value';
  }

  @override
  String filterValueAirHumidity(String value) {
    return 'Hava Nemi: $value%';
  }

  @override
  String filterValueAirVisibility(String value) {
    return 'Hava Görünürlüğü: $value';
  }

  @override
  String filterValueWindSpeed(String value) {
    return 'Rüzgar Hızı: $value';
  }

  @override
  String filterPageInvalidEndValue(String value) {
    return '$value\'dan büyük olmalı';
  }

  @override
  String get moonPhaseNew => 'Yeni';

  @override
  String get moonPhaseWaxingCrescent => 'Hilal (büyüyen)';

  @override
  String get moonPhaseFirstQuarter => 'İlk Dördün';

  @override
  String get moonPhaseWaxingGibbous => 'Şişkin (büyüyen)';

  @override
  String get moonPhaseFull => 'Dolunay';

  @override
  String get moonPhaseWaningGibbous => 'Şişkin (küçülen)';

  @override
  String get moonPhaseLastQuarter => 'Son Dördün';

  @override
  String get moonPhaseWaningCrescent => 'Hilal (küçülen)';

  @override
  String moonPhaseChip(String value) {
    return '$value Ay';
  }

  @override
  String get atmosphereInputTemperature => 'Sıcaklık';

  @override
  String get atmosphereInputAirTemperature => 'Hava Sıcaklığı';

  @override
  String get atmosphereInputSkyConditions => 'Gökyüzü Koşulları';

  @override
  String get atmosphereInputNoSkyConditions => 'Gökyüzü koşulu yok';

  @override
  String get atmosphereInputWindSpeed => 'Rüzgar Hızı';

  @override
  String get atmosphereInputWind => 'Rüzgar';

  @override
  String get atmosphereInputWindDirection => 'Rüzgar Yönü';

  @override
  String get atmosphereInputPressure => 'Basınç';

  @override
  String get atmosphereInputAtmosphericPressure => 'Atmosfer Basıncı';

  @override
  String get atmosphereInputHumidity => 'Nem';

  @override
  String get atmosphereInputAirHumidity => 'Hava Nemi';

  @override
  String get atmosphereInputVisibility => 'Görüş';

  @override
  String get atmosphereInputAirVisibility => 'Hava Görüşü';

  @override
  String get atmosphereInputMoon => 'Ay';

  @override
  String get atmosphereInputMoonPhase => 'Ay Evresi';

  @override
  String get atmosphereInputSunrise => 'Gündoğumu';

  @override
  String get atmosphereInputTimeOfSunrise => 'Gündoğumu Saati';

  @override
  String get atmosphereInputSunset => 'Günbatımı';

  @override
  String get atmosphereInputTimeOfSunset => 'Günbatımı Saati';

  @override
  String get directionNorth => 'K';

  @override
  String get directionNorthEast => 'KD';

  @override
  String get directionEast => 'D';

  @override
  String get directionSouthEast => 'GD';

  @override
  String get directionSouth => 'G';

  @override
  String get directionSouthWest => 'GB';

  @override
  String get directionWest => 'B';

  @override
  String get directionNorthWest => 'KB';

  @override
  String directionWindChip(String value) {
    return 'Rüzgar: $value';
  }

  @override
  String get skyConditionSnow => 'Kar';

  @override
  String get skyConditionDrizzle => 'Çiseleme';

  @override
  String get skyConditionDust => 'Toz';

  @override
  String get skyConditionFog => 'Sis';

  @override
  String get skyConditionRain => 'Yağmur';

  @override
  String get skyConditionTornado => 'Hortum';

  @override
  String get skyConditionHail => 'Dolu';

  @override
  String get skyConditionIce => 'Buz';

  @override
  String get skyConditionStorm => 'Fırtına';

  @override
  String get skyConditionMist => 'Pus';

  @override
  String get skyConditionSmoke => 'Duman';

  @override
  String get skyConditionOvercast => 'Kapalı';

  @override
  String get skyConditionCloudy => 'Bulutlu';

  @override
  String get skyConditionClear => 'Açık';

  @override
  String get skyConditionSunny => 'Güneşli';

  @override
  String get pickerTitleBait => 'Yem Seç';

  @override
  String get pickerTitleBaits => 'Yem Seç';

  @override
  String get pickerTitleBaitCategory => 'Yem Kategorisi Seç';

  @override
  String get pickerTitleAngler => 'Balıkçı Seç';

  @override
  String get pickerTitleAnglers => 'Balıkçı Seç';

  @override
  String get pickerTitleFishingMethods => 'Balık Tutma Yöntemi Seç';

  @override
  String get pickerTitleWaterClarity => 'Su Berraklığı Seç';

  @override
  String get pickerTitleWaterClarities => 'Su Berraklığı Seç';

  @override
  String get pickerTitleDateRange => 'Tarih Aralığı Seç';

  @override
  String get pickerTitleFields => 'Alan Seç';

  @override
  String get pickerTitleReport => 'Rapor Seç';

  @override
  String get pickerTitleSpecies => 'Tür Seç';

  @override
  String get pickerTitleFishingSpot => 'Av Noktası Seç';

  @override
  String get pickerTitleFishingSpots => 'Av Noktası Seç';

  @override
  String get pickerTitleTimeOfDay => 'Günün Zamanını Seç';

  @override
  String get pickerTitleTimesOfDay => 'Günün Zamanlarını Seç';

  @override
  String get pickerTitleSeason => 'Mevsim Seç';

  @override
  String get pickerTitleSeasons => 'Mevsim Seç';

  @override
  String get pickerTitleMoonPhase => 'Ay Evresi Seç';

  @override
  String get pickerTitleMoonPhases => 'Ay Evresi Seç';

  @override
  String get pickerTitleSkyConditions => 'Gökyüzü Koşulu Seç';

  @override
  String get pickerTitleWindDirection => 'Rüzgar Yönü Seç';

  @override
  String get pickerTitleWindDirections => 'Rüzgar Yönü Seç';

  @override
  String get pickerTitleTide => 'Gelgit Seç';

  @override
  String get pickerTitleTides => 'Gelgit Seç';

  @override
  String get pickerTitleBodyOfWater => 'Su Kütlesi Seç';

  @override
  String get pickerTitleBodiesOfWater => 'Su Kütlesi Seç';

  @override
  String get pickerTitleCatches => 'Av Seç';

  @override
  String get pickerTitleTimeZone => 'Saat Dilimi Seç';

  @override
  String get pickerTitleGpsTrails => 'GPS İzi Seç';

  @override
  String get pickerTitleGear => 'Ekipman Seç';

  @override
  String get pickerTitleRodAction => 'Aksiyon Seç';

  @override
  String get pickerTitleRodPower => 'Güç Seç';

  @override
  String get pickerTitleTrip => 'Gezi Seç';

  @override
  String get keywordsTemperatureMetric => 'santigrat sıcaklık derece c';

  @override
  String get keywordsTemperatureImperial => 'fahrenheit sıcaklık derece f';

  @override
  String get keywordsSpeedImperial => 'saatte mil hızında rüzgar';

  @override
  String get keywordsAirPressureMetric => 'atmosferik hava basıncı milibar';

  @override
  String get keywordsAirPressureImperial =>
      'atmosferik hava basıncı inç kare başına pound';

  @override
  String get keywordsAirHumidity => 'nem yüzde nem';

  @override
  String get keywordsAirVisibilityMetric => 'kilometre kilometre görünürlük';

  @override
  String get keywordsAirVisibilityImperial => 'kilometre görünürlüğü';

  @override
  String get keywordsPercent => 'yüzde';

  @override
  String get keywordsInchOfMercury => 'inç cıva barometrik atmosfer basıncı';

  @override
  String get keywordsSunrise => 'gündoğumu';

  @override
  String get keywordsSunset => 'gün batımı';

  @override
  String get keywordsCatchAndRelease => 'serbest bırakıldı';

  @override
  String get keywordsFavorite => 'favori yıldız yıldızlı';

  @override
  String get keywordsDepthMetric => 'derinlik ölçerler metre';

  @override
  String get keywordsDepthImperial => 'derinlik ayak inç';

  @override
  String get keywordsLengthMetric => 'uzunluk santimetre cm';

  @override
  String get keywordsLengthImperial => 'uzunluk inç \"';

  @override
  String get keywordsWeightMetric => 'ağırlık kilo kilogram kg';

  @override
  String get keywordsWeightImperial => 'ağırlık pound ons lbs ons';

  @override
  String get keywordsX => 'x';

  @override
  String get keywordsAught => 'bir şey olmalı';

  @override
  String get keywordsPoundTest => 'pound testi';

  @override
  String get keywordsHashtag => '#';

  @override
  String get keywordsMetersPerSecond => 'metre metre saniyede m/s';

  @override
  String get keywordsNorth => 'kuzeyde';

  @override
  String get keywordsNorthEast => 'ne kuzeydoğu';

  @override
  String get keywordsEast => 'doğu doğu';

  @override
  String get keywordsSouthEast => 'güneydoğuya doğru';

  @override
  String get keywordsSouth => 'güney';

  @override
  String get keywordsSouthWest => 'GB güneybatı';

  @override
  String get keywordsWest => 'Batı batı';

  @override
  String get keywordsNorthWest => 'kuzeybatı';

  @override
  String get keywordsWindDirection => 'rüzgar yönü';

  @override
  String get keywordsMoon => 'ay evresi';

  @override
  String get tideInputTitle => 'Gelgit';

  @override
  String tideInputLowTimeValue(String value) {
    return 'Alçak: $value';
  }

  @override
  String tideInputHighTimeValue(String value) {
    return 'Yüksek: $value';
  }

  @override
  String tideInputDatumValue(String value) {
    return 'Referans: $value';
  }

  @override
  String get tideInputFirstLowTimeLabel => 'İlk Alçak Gelgit Saati';

  @override
  String get tideInputFirstHighTimeLabel => 'İlk Yüksek Gelgit Saati';

  @override
  String get tideInputSecondLowTimeLabel => 'İkinci Alçak Gelgit Saati';

  @override
  String get tideInputSecondHighTimeLabel => 'İkinci Yüksek Gelgit Saati';

  @override
  String get tideTypeLow => 'Alçak';

  @override
  String get tideTypeOutgoing => 'Çeken';

  @override
  String get tideTypeHigh => 'Yüksek';

  @override
  String get tideTypeSlack => 'Durgun';

  @override
  String get tideTypeIncoming => 'Gelen';

  @override
  String get tideLow => 'Alçak Gelgit';

  @override
  String get tideOutgoing => 'Çeken Gelgit';

  @override
  String get tideHigh => 'Yüksek Gelgit';

  @override
  String get tideSlack => 'Durgun Gelgit';

  @override
  String get tideIncoming => 'Gelen Gelgit';

  @override
  String tideTimeAndHeight(String height, String time) {
    return '$height, $time';
  }

  @override
  String get saveBaitVariantPageTitle => 'Yem Varyantını Düzenle';

  @override
  String get saveBaitVariantPageEditTitle => 'Yeni Yem Varyantı';

  @override
  String get saveBaitVariantPageModelNumber => 'Model Numarası';

  @override
  String get saveBaitVariantPageSize => 'Boyut';

  @override
  String get saveBaitVariantPageMinDiveDepth => 'Minimum Dalış Derinliği';

  @override
  String get saveBaitVariantPageMaxDiveDepth => 'Maksimum Dalış Derinliği';

  @override
  String get saveBaitVariantPageDescription => 'Açıklama';

  @override
  String get baitVariantPageVariantLabel => 'Şunun varyantı';

  @override
  String get baitVariantPageModel => 'Model Numarası';

  @override
  String get baitVariantPageSize => 'Boyut';

  @override
  String get baitVariantPageDiveDepth => 'Dalış Derinliği';

  @override
  String get baitTypeArtificial => 'Yapay';

  @override
  String get baitTypeReal => 'Gerçek';

  @override
  String get baitTypeLive => 'Canlı';

  @override
  String bodyOfWaterListPageDeleteMessage(String bodyOfWater, int numOfSpots) {
    return '$bodyOfWater, $numOfSpots av noktası ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String bodyOfWaterListPageDeleteMessageSingular(String bodyOfWater) {
    return '$bodyOfWater, 1 av noktası ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String bodyOfWaterListPageTitle(int numOfBodiesOfWater) {
    return 'Su Kütleleri ($numOfBodiesOfWater)';
  }

  @override
  String get bodyOfWaterListPageSearchHint => 'Su kütlelerinde ara';

  @override
  String get bodyOfWaterListPageEmptyListTitle => 'Su Kütlesi Yok';

  @override
  String get bodyOfWaterListPageEmptyListDescription =>
      'Henüz hiç su kütlesi eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String get bodiesOfWaterSummaryEmpty =>
      'Günlüğünüze su kütlesi eklendiğinde, avlarının özeti burada gösterilir.';

  @override
  String get saveBodyOfWaterPageNewTitle => 'Yeni Su Kütlesi';

  @override
  String get saveBodyOfWaterPageEditTitle => 'Su Kütlesini Düzenle';

  @override
  String get saveBodyOfWaterPageExistsMessage => 'Su kütlesi zaten var';

  @override
  String get mapAttributionOpenStreetMap => '© OpenStreetMap';

  @override
  String get mapAttributionImproveThisMap => 'Bu Haritayı İyileştir';

  @override
  String get entityNameAnglers => 'Balıkçılar';

  @override
  String get entityNameAngler => 'Balıkçı';

  @override
  String get entityNameBaitCategories => 'Yem Kategorileri';

  @override
  String get entityNameBaitCategory => 'Yem Kategorisi';

  @override
  String get entityNameBaits => 'Yemler';

  @override
  String get entityNameBait => 'Yem';

  @override
  String get entityNameBodiesOfWater => 'Su Kütleleri';

  @override
  String get entityNameBodyOfWater => 'Su Kütlesi';

  @override
  String get entityNameCatch => 'Av';

  @override
  String get entityNameCatches => 'Avlar';

  @override
  String get entityNameCustomFields => 'Özel Alanlar';

  @override
  String get entityNameCustomField => 'Özel Alan';

  @override
  String get entityNameFishingMethods => 'Balık Tutma Yöntemleri';

  @override
  String get entityNameFishingMethod => 'Balık Tutma Yöntemi';

  @override
  String get entityNameGear => 'Ekipman';

  @override
  String get entityNameGpsTrails => 'GPS İzleri';

  @override
  String get entityNameGpsTrail => 'GPS İzi';

  @override
  String get entityNameSpecies => 'Türler';

  @override
  String get entityNameTrip => 'Gezi';

  @override
  String get entityNameTrips => 'Geziler';

  @override
  String get entityNameWaterClarities => 'Su Berraklıkları';

  @override
  String get entityNameWaterClarity => 'Su Berraklığı';

  @override
  String get tripSummaryTitle => 'Gezi Özeti';

  @override
  String get tripSummaryTotalTripTime => 'Toplam Gezi Süresi';

  @override
  String get tripSummaryLongestTrip => 'En Uzun Gezi';

  @override
  String get tripSummarySinceLastTrip => 'Son Geziden Bu Yana';

  @override
  String get tripSummaryAverageTripTime => 'Ortalama Gezi Süresi';

  @override
  String get tripSummaryAverageTimeBetweenTrips => 'Geziler Arası';

  @override
  String get tripSummaryAverageTimeBetweenCatches => 'Avlar Arası';

  @override
  String get tripSummaryCatchesPerTrip => 'Gezi Başına Avlar';

  @override
  String get tripSummaryCatchesPerHour => 'Saat Başına Avlar';

  @override
  String get tripSummaryWeightPerTrip => 'Gezi Başına Ağırlık';

  @override
  String get tripSummaryBestWeight => 'En İyi Ağırlık';

  @override
  String get tripSummaryLengthPerTrip => 'Gezi Başına Boy';

  @override
  String get tripSummaryBestLength => 'En İyi Boy';

  @override
  String get backupPageTitle => 'Yedek';

  @override
  String get backupPageDescription =>
      'Verileriniz cihazınızda bir zip dosyası olarak paketlenir; bu dosyayı dilediğiniz konuma kaydedebilir veya paylaşabilirsiniz.\n\nYedekleme işlemi birkaç dakika sürebilir.';

  @override
  String get backupPageAction => 'Şimdi Yedekle';

  @override
  String get backupPageErrorTitle => 'Yedekleme Hatası';

  @override
  String get backupPageAutoTitle => 'Otomatik Yedekle';

  @override
  String get backupPageLastBackupLabel => 'Son Yedek';

  @override
  String get backupPageLastBackupNever => 'Hiç';

  @override
  String get restorePageTitle => 'Geri Yükle';

  @override
  String get restorePageDescription =>
      'Verileri geri yüklemek, mevcut günlüğünüzü seçtiğiniz yedek dosyasındaki verilerle tamamen değiştirir. Veri yoksa günlüğünüz değişmez.\n\nGeri yükleme işlemi birkaç dakika sürebilir.';

  @override
  String get restorePageAction => 'Şimdi Geri Yükle';

  @override
  String get restorePageErrorTitle => 'Geri Yükleme Hatası';

  @override
  String get backupRestoreAuthError =>
      'Kimlik doğrulama hatası. Lütfen daha sonra tekrar deneyin.';

  @override
  String get backupRestoreAutoSignedOutError =>
      'Kimlik doğrulama zaman aşımı nedeniyle otomatik yedek başarısız oldu. Lütfen tekrar oturum açın.';

  @override
  String get backupRestoreAutoNetworkError =>
      'Ağ bağlantısı sorunu nedeniyle otomatik yedek başarısız oldu. Lütfen manuel yedek yapın veya bir sonraki otomatik yedek denemesini bekleyin.';

  @override
  String get backupRestoreCreateFolderError =>
      'yedek klasörü oluşturulamadı, lütfen daha sonra tekrar deneyin.';

  @override
  String get backupRestoreFolderNotFound =>
      'Yedek klasör bulunamadı. Verilerinizin geri yükled olabilmesi için yedek yapmanız gerekir.';

  @override
  String get backupRestoreApiRequestError =>
      'Ağ kesintiye uğramış olabilir. İnternet bağlantınızı doğrulayıp tekrar deneyin. Sorun devam ederse lütfen Geri Bildirim menüsünden bir rapor gönderin.';

  @override
  String get backupRestoreDatabaseNotFound =>
      'Yedek veri dosyası bulunamadı. Verilerinizin geri yükled olabilmesi için yedek yapmanız gerekir.';

  @override
  String get backupRestoreAccessDenied =>
      'Uygulamanın yedek dosyalarını cihazınızda oluşturma izni yok. Lütfen cihaz depolama izinlerini kontrol edip tekrar deneyin.';

  @override
  String get backupRestoreStorageFull =>
      'Cihazınızın depolama alanı dolu. Lütfen biraz yer açın ve tekrar deneyin.';

  @override
  String get backupRestoreAuthenticating => 'Kimlik doğrulanıyor...';

  @override
  String get backupRestoreFetchingFiles => 'Veriler getiriliyor...';

  @override
  String get backupRestoreCreatingFolder => 'yedek klasörü oluşturuluyor...';

  @override
  String get backupRestoreDownloadingDatabase => 'Veritabanı indiriliyor...';

  @override
  String backupRestoreDownloadingImages(String percent) {
    return 'Resimler indiriliyor$percent...';
  }

  @override
  String get backupRestoreReloadingData => 'Veriler yeniden yükleniyor...';

  @override
  String get backupRestoreSuccess => 'Başarılı!';

  @override
  String get asyncFeedbackSendReport => 'Rapor Gönder';

  @override
  String get addAnythingTitle => 'Yeni Ekle';

  @override
  String get proBlurUpgradeButton => 'Yükselt';

  @override
  String get aboutPagePrivacy => 'Gizlilik Politikası';

  @override
  String get aboutPageWorldTides => 'Gelgit Verisi Kaynağı';

  @override
  String get aboutPageWorldTidePrivacy =>
      'Gelgit bilgileri, ücretsiz ve API anahtarı gerektirmeyen TideTurtle servisinden (tideturtle.com) alınır. İstek sırasında yalnızca seçtiğiniz konumun enlem/boylam bilgisi gönderilir; başka bir kişisel veri paylaşılmaz.\n\nBU GELGİT VERİLERİNİN DOĞRULUĞU KONUSUNDA HİÇBİR GARANTİ VERİLMEZ.\nBu verileri, kullanımı sonucu birinin veya bir şeyin zarar görebileceği durumlarda (ör. seyrüsefer amaçlı) kullanamazsınız.\n\nDaha fazla bilgi için: https://tideturtle.com';

  @override
  String get fishingSpotDetailsAddDetails => 'Ayrıntı Ekle';

  @override
  String fishingSpotDetailsCatches(int numOfCatches) {
    return '$numOfCatches Av';
  }

  @override
  String get fishingSpotDetailsCatch => '1 Av';

  @override
  String get timeZoneInputLabel => 'Saat Dilimi';

  @override
  String get timeZoneInputDescription =>
      'Varsayılan olarak geçerli saat diliminiz kullanılır.';

  @override
  String get timeZoneInputSearchHint => 'Saat dilimlerinde ara';

  @override
  String get pollsPageTitle => 'Özellik Anketleri';

  @override
  String get pollsPageDescription =>
      'Mera Asistanı\'nın sonraki sürümüne hangi özelliklerin ekleneceğini oylayarak belirleyin.';

  @override
  String get pollsPageNoPollsTitle => 'Anket Yok';

  @override
  String get pollsPageNoPollsDescription =>
      'Şu anda herhangi bir özellik anketi yok. Bir özellik talep etmek istiyorsanız lütfen bize geri bildirim gönderin!';

  @override
  String get pollsPageSendFeedback => 'Geri Bildirim Gönder';

  @override
  String get pollsPageNextFreeFeature => 'Sonraki Ücretsiz Özellik';

  @override
  String get pollsPageNextProFeature => 'Sonraki Pro Özellik';

  @override
  String get pollsPageThankYouFree =>
      'Ücretsiz özellik anketine oy verdiğiniz için teşekkür ederiz!';

  @override
  String get pollsPageThankYouPro =>
      'Profesyonel özellik anketine oy verdiğiniz için teşekkür ederiz!';

  @override
  String get pollsPageError =>
      'Oyunuzu verirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.';

  @override
  String get pollsPageComingSoonFree =>
      'Yakında Ücretsiz Kullanıcılara Sunulacak (Oy verildiği gibi)';

  @override
  String get pollsPageComingSoonPro =>
      'Yakında Profesyonel Kullanıcılara Sunulacak (Oylamaya Göre)';

  @override
  String get permissionLocationTitle => 'Konum Erişimi';

  @override
  String get permissionCurrentLocationDescription =>
      'Mevcut konumunuzu göstermek için Mera Asistanı\'na cihazınızın konumunu okuma erişimine izin vermelisiniz. Bunu yapmak için cihaz ayarlarınızı açın.';

  @override
  String get permissionGpsTrailDescription =>
      'Doğru bir GPS izi oluşturmak için Mera Asistanı, izleme etkinken cihazınızın konumuna her zaman erişebilmelidir. Gerekli izni vermek için cihazınızın ayarlarını açın.';

  @override
  String get permissionOpenSettings => 'Ayarları Aç';

  @override
  String get permissionLocationNotificationDescription => 'GPS izi etkin';

  @override
  String get calendarPageTitle => 'Takvim';

  @override
  String get calendarPageTripLabel => 'Gezi';

  @override
  String gpsTrailListPageTitle(int numOfTrails) {
    return 'GPS İzleri ($numOfTrails)';
  }

  @override
  String get gpsTrailListPageSearchHint => 'GPS izlerinde ara';

  @override
  String get gpsTrailListPageEmptyListTitle => 'GPS İzi Yok';

  @override
  String get gpsTrailListPageEmptyListDescription =>
      'GPS izi başlatmak için haritadaki %s düğmesine dokunun.';

  @override
  String get gpsTrailListPageDeleteMessageSingular =>
      'Bu GPS izi 1 gezi ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String gpsTrailListPageDeleteMessage(int numOfTrips) {
    return 'Bu GPS izi $numOfTrips gezi ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String gpsTrailListPageNumberOfPoints(int numOfPoints) {
    return '$numOfPoints Nokta';
  }

  @override
  String get gpsTrailListPageInProgress => 'Devam Ediyor';

  @override
  String get saveGpsTrailPageEditTitle => 'GPS İzini Düzenle';

  @override
  String get tideFetcherErrorNoLocationFound =>
      'Getirme konumu gelgit bilgisi belirlemek için karada çok içeride.';

  @override
  String get csvPageTitle => 'CSV\'yi dışa aktar';

  @override
  String get csvPageAction => 'Dışa Aktar';

  @override
  String get csvPageDescription =>
      'Aşağıdaki her seçim için ayrı bir CSV dosyası oluşturulur.';

  @override
  String get csvPageImportWarning =>
      'Elektronik tablo yazılımına içe aktarırken, dışa aktarılan CSV dosyalarının dosya kaynağı Unicode\'dur (UTF-8) ve sınırlayıcı virgüldür.';

  @override
  String get csvPageBackupWarning =>
      'CSV dosyaları yedek değildir ve Mera Asistanı\'na aktarılamaz. Bunun yerine Diğer sayfasındaki Yedek ve Geri Yükle düğmelerini kullanın.';

  @override
  String get csvPageSuccess => 'Başarılı!';

  @override
  String get csvPageMustSelect =>
      'Lütfen yukarıdan en az bir dışa aktarma seçeneği seçin.';

  @override
  String get tripFieldStartDate => 'Başlangıç Tarihi';

  @override
  String get tripFieldEndDate => 'Bitiş Tarihi';

  @override
  String get tripFieldStartTime => 'Başlangıç Saati';

  @override
  String get tripFieldEndTime => 'Bitiş Saati';

  @override
  String get tripFieldPhotos => 'Fotoğraflar';

  @override
  String gearListPageTitle(int numOfGear) {
    return 'Ekipman ($numOfGear)';
  }

  @override
  String gearListPageDeleteMessage(String gear, int numOfCatches) {
    return '$gear, $numOfCatches av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String gearListPageDeleteMessageSingular(String gear) {
    return '$gear, 1 av ile ilişkilidir; silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get gearListPageSearchHint => 'Ekipmanda ara';

  @override
  String get gearListPageEmptyListTitle => 'Ekipman Yok';

  @override
  String get gearListPageEmptyListDescription =>
      'Henüz hiç ekipman eklemediniz. Başlamak için %s düğmesine dokunun.';

  @override
  String get gearSummaryEmpty =>
      'Günlüğünüze ekipman eklendiğinde, avlarının özeti burada gösterilir.';

  @override
  String get gearActionXFast => 'Çok Hızlı';

  @override
  String get gearActionFast => 'Hızlı';

  @override
  String get gearActionModerateFast => 'Orta Hızlı';

  @override
  String get gearActionModerate => 'Orta';

  @override
  String get gearActionSlow => 'Yavaş';

  @override
  String get gearPowerUltralight => 'Ultra Hafif';

  @override
  String get gearPowerLight => 'Hafif';

  @override
  String get gearPowerMediumLight => 'Orta Hafif';

  @override
  String get gearPowerMedium => 'Orta';

  @override
  String get gearPowerMediumHeavy => 'Orta Ağır';

  @override
  String get gearPowerHeavy => 'Ağır';

  @override
  String get gearPowerXHeavy => 'Çok Ağır';

  @override
  String get gearPowerXxHeavy => 'Çift Çok Ağır';

  @override
  String get gearPowerXxxHeavy => 'Üçlü Çok Ağır';

  @override
  String get gearFieldImage => 'Fotoğraf';

  @override
  String get gearFieldRodMakeModel => 'Olta Marka ve Model';

  @override
  String get gearFieldRodSerialNumber => 'Olta Seri Numarası';

  @override
  String get gearFieldRodLength => 'Olta Boyu';

  @override
  String get gearFieldRodAction => 'Olta Aksiyonu';

  @override
  String get gearFieldRodPower => 'Olta Gücü';

  @override
  String get gearFieldReelMakeModel => 'Makine Marka ve Model';

  @override
  String get gearFieldReelSerialNumber => 'Makine Seri Numarası';

  @override
  String get gearFieldReelSize => 'Makine Boyutu';

  @override
  String get gearFieldLineMakeModel => 'Misina Marka ve Model';

  @override
  String get gearFieldLineRating => 'Misina Dayanımı';

  @override
  String get gearFieldLineColor => 'Misina Rengi';

  @override
  String get gearFieldLeaderLength => 'Öncü Boyu';

  @override
  String get gearFieldLeaderRating => 'Öncü Dayanımı';

  @override
  String get gearFieldTippetLength => 'Tippet Boyu';

  @override
  String get gearFieldTippetRating => 'Tippet Dayanımı';

  @override
  String get gearFieldHookMakeModel => 'İğne Marka ve Model';

  @override
  String get gearFieldHookSize => 'İğne Boyutu';

  @override
  String get saveGearPageEditTitle => 'Ekipmanı Düzenle';

  @override
  String get saveGearPageNewTitle => 'Yeni Ekipman';

  @override
  String get saveGearPageNameExists => 'Ekipman adı zaten var';

  @override
  String gearPageSerialNumber(String serialNo) {
    return 'Seri No: $serialNo';
  }

  @override
  String gearPageSize(String size) {
    return 'Boyut: $size';
  }

  @override
  String gearPageLeader(String leader) {
    return 'Öncü: $leader';
  }

  @override
  String gearPageTippet(String tippet) {
    return 'Tippet: $tippet';
  }

  @override
  String get notificationPermissionPageDesc =>
      'Veri yedeklemesi herhangi bir nedenle (yeniden kimlik doğrulama gerekmesi dahil) başarısız olursa Mera Asistanı\'nın sizi bilgilendirmesine izin verin.';

  @override
  String get notificationErrorBackupTitle => 'Yedekleme Hatası';

  @override
  String get notificationErrorBackupBody =>
      'Eyvah! Verileriniz yedeklenirken bir sorun oluştu. Ayrıntılar için buraya dokunun.';

  @override
  String get notificationChannelNameBackup => 'Veri Yedekleme';

  @override
  String get speciesCounterPageTitle => 'Tür Sayacı';

  @override
  String get speciesCounterPageReset => 'Sıfırla';

  @override
  String get speciesCounterPageCreateTrip => 'Gezi Oluştur';

  @override
  String get speciesCounterPageAddToTrip => 'Geziye Ekle';

  @override
  String get speciesCounterPageSelect => 'Tür Seç';

  @override
  String speciesCounterPageTripUpdated(String trip) {
    return 'Tür sayıları $trip gezisine eklendi.';
  }

  @override
  String get speciesCounterPageGeneralTripName => 'gezi';

  @override
  String get locationDataFetcherErrorNoPermission =>
      'Verileri almak için izin gerekiyor. Lütfen Mera Asistanı konum iznini verin ve tekrar deneyin.';

  @override
  String get locationDataFetcherPermissionError =>
      'Konum izni istenirken bir hata oluştu. Mera Asistanı ekibine bilgi verildi ve rahatsızlıktan dolayı özür dileriz.';

  @override
  String get changeLogPageTitle => 'Yenilikler';

  @override
  String get changeLogPagePreviousVersion => 'Önceki Sürümünüz';

  @override
  String get changeLog_2022_1 =>
      'Balıkçı Günlüğü\'nin tamamen yeniden yazılması';

  @override
  String get changeLog_2022_2 => 'Taze ve modern bir görünüm ve his';

  @override
  String get changeLog_2022_3 =>
      'Tamamen yeni, kapsamlı ve ayrıntılı bir istatistik özelliği';

  @override
  String get changeLog_2022_4 =>
      'ay evreleri ve gelgit dahil ayrıntılı atmosfer ve hava durumu verileri';

  @override
  String get changeLog_2022_5 =>
      'Balıkçı Günlüğü Pro\'ye abone olarak Balıkçı Günlüğü\'den daha fazla yararlanın';

  @override
  String get changeLog_2022_6 =>
      'Ayrıca kullanıcıların talep ettiği daha birçok özellik';

  @override
  String get changeLog_210_1 =>
      'Daha Fazla > Özellik Anketleri\'nde artık bir sonraki adımda hangi özellikleri görmek istediğinize oy verebilirsiniz';

  @override
  String get changeLog_210_2 =>
      'Kişisel en iyi fotoğrafların köşelerinin yuvarlatılmaması sorunu düzeltildi';

  @override
  String get changeLog_210_3 =>
      'İstatistikler sayfasında av miktar değerlerinin sayılmaması sorunu düzeltildi';

  @override
  String get changeLog_210_4 =>
      'Otomatik av noktası toplama mesafesi artık Ayarlar\'da yapılandırılabilir';

  @override
  String get changeLog_212_1 =>
      'Eski verileri içe aktarırken oluşan kilitlenme düzeltildi';

  @override
  String get changeLog_212_2 =>
      'Karşılaştırma raporlarını düzenlerken oluşan kilitlenme düzeltildi';

  @override
  String get changeLog_212_3 =>
      'Bazı kullanıcılar için ön plana döndükten sonra haritanın görünmesi düzeltildi';

  @override
  String get changeLog_212_4 => 'Not giriş alanı karakter sınırı kaldırıldı';

  @override
  String get changeLog_213_1 =>
      'Veri geri yüklemenin bazen başarısız olmasına neden olan sorun düzeltildi';

  @override
  String get changeLog_213_2 =>
      'Eski veri geçişi sırasındaki kilitlenme düzeltildi';

  @override
  String get changeLog_213_3 => 'Performans iyileştirmeleri';

  @override
  String get changeLog_213_4 => 'Ücretsiz kullanıcılar artık reklam görmeyecek';

  @override
  String get changeLog_215_1 =>
      'Daha sorunsuz bir kullanıcı deneyimi sağlayan rapor hesaplamalarının verimliliği artırıldı';

  @override
  String get changeLog_216_1 =>
      'Balık tutma noktası koordinatları artık düzenlenebilir';

  @override
  String get changeLog_216_2 =>
      'Geliştirilmiş yedek ve geri yükle hata mesajları';

  @override
  String get changeLog_216_3 =>
      'av noktası \"Yol Tarifi\" düğmesinin bazen çalışmaması sorunu düzeltildi';

  @override
  String get changeLog_216_4 =>
      'Fotoğraf galerisinin bazen boş görünmesi sorunu düzeltildi';

  @override
  String get changeLog_216_5 => 'Birkaç çökme düzeltildi';

  @override
  String get changeLog_220_1 =>
      '\"Diğer\" sayfasına geziler ve avlar için takvim görünümü eklendi';

  @override
  String get changeLog_220_2 =>
      '\"İstatistikler\" sayfasında yemlerin görüntülenmesiyle ilgili birden fazla sorun düzeltildi';

  @override
  String get changeLog_220_3 =>
      'Fotoğraf verileri okunamaz hale geldiğinde oluşan çökme düzeltildi';

  @override
  String get changeLog_230_1 =>
      'Haritadaki %s düğmesine dokunarak etkinleştirilebilecek canlı GPS takibi ekleyin';

  @override
  String get changeLog_230_2 =>
      'Yerel ayarları buna izin veren ülkeler artık virgülleri ondalık nokta olarak kullanabilir';

  @override
  String get changeLog_230_3 =>
      'av eklenirken fotoğrafın zamanının ve konumunun her zaman kullanılmaması sorunu düzeltildi';

  @override
  String get changeLog_230_4 =>
      'İstatistikler sayfasında yanlış avların gösterilmesine neden olan bir hata düzeltildi';

  @override
  String get changeLog_230_5 => 'Küçük kullanıcı arayüzü hata düzeltmeleri';

  @override
  String get changeLog_232_1 =>
      'gezi başlangıç ​​ve bitiş zamanlarının ayarlanamaması sorunu düzeltildi';

  @override
  String get changeLog_233_1 =>
      '\"Alanları Yönet\" menüsünden gezi başlangıç ​​ve bitiş tarihlerinin seçilememesi sorunu düzeltildi';

  @override
  String get changeLog_233_2 => 'Bazı genel kararlılık iyileştirmeleri';

  @override
  String get changeLog_234_1 =>
      'Artık \"KAYDET\" butonuna basmadan bir sayfadan ayrılırken uyarılacaksınız';

  @override
  String get changeLog_234_2 =>
      'Atmosfer ve hava durumu verileri alınırken artık gezi\'ın manuel olarak ayarlanan başlangıç ​​zamanı kullanılıyor';

  @override
  String get changeLog_234_3 =>
      'av eklenirken fotoğrafların galeride görünmemesi sorunu düzeltildi';

  @override
  String get changeLog_234_4 =>
      'Haritanın her zaman mevcut konumunuzu getirememesi sorunu düzeltildi';

  @override
  String get changeLog_240_1 => 'Karanlık Mod için destek eklendi';

  @override
  String get changeLog_240_2 =>
      'gezi\'nin uzunluk istatistik döşemesindeki ondalık basamaklar kaldırıldı';

  @override
  String get changeLog_240_3 =>
      'İstatistik zaman aralığı seçimi artık uygulama başlatıldığında kaydediliyor';

  @override
  String get changeLog_240_4 => '\"Güneşli\" gökyüzü koşulu olarak eklendi';

  @override
  String get changeLog_240_5 => 'Not alanları artık boş satırlar içerebiliyor';

  @override
  String get changeLog_240_6 => 'Not alanları artık 4 satıra kısaltılmıyor';

  @override
  String get changeLog_241_1 =>
      'Atmosfer ve hava durumu verileri alınırken oluşan çökme düzeltildi';

  @override
  String get changeLog_241_2 =>
      'av eklerken nadir görülen bir çökme düzeltildi';

  @override
  String get changeLog_241_3 =>
      'av eklenirken av noktası\'nin sıfırlanması sorunu düzeltildi';

  @override
  String get changeLog_241_4 =>
      'Gezi eklerken, seçilen avlara göre mevcut alanları otomatik ayarlama seçeneği sunuluyor';

  @override
  String get changeLog_241_5 =>
      'Çeşitli genel kararlılık iyileştirmeleri ve kilitlenme düzeltmeleri';

  @override
  String get changeLog_243_1 =>
      'Yanlış getirilen atmosfer ve hava durumu verileri düzeltildi';

  @override
  String get changeLog_250_1 =>
      'Gelgit verileri artık WorldTides™ üzerinden getirilebilir';

  @override
  String get changeLog_250_2 => 'Günün \"Akşam\" saati eklendi';

  @override
  String get changeLog_250_3 =>
      'Başka bir noktaya çok yakın olması durumunda av noktası\'ın eklenememesi sorunu düzeltildi';

  @override
  String get changeLog_250_4 =>
      'Ayırıcı olarak virgül kullanan diller için ondalık değerlerin girilmesiyle ilgili sorun düzeltildi';

  @override
  String get changeLog_250_5 =>
      'Konumun fotoğraflardan okunamaması sorunu düzeltildi';

  @override
  String get changeLog_251_1 =>
      'ABD dışındaki yerel ayarların ölçüm birimlerini değiştirememesi sorunu düzeltildi';

  @override
  String get changeLog_252_1 =>
      'Otomatik yedek\'ler artık av, gezi ve yem değişikliklerinde tetikleniyor';

  @override
  String get changeLog_252_2 =>
      'gelgit yükseklikte yinelenen negatif işaret düzeltildi';

  @override
  String get changeLog_252_3 =>
      'Pro\'ya yükselttikten sonra özel raporlara dokunulamamasına neden olan sorun düzeltildi';

  @override
  String get changeLog_252_4 =>
      'İstatistik av listelerinde boş av uzunluk/ağırlık değerlerinin gösterilmesi düzeltildi';

  @override
  String get changeLog_260_1 =>
      'Profesyonel kullanıcılar artık Daha Fazla > CSV\'yi Dışa Aktar aracılığıyla verilerini bir e-tabloya aktarabilirler.';

  @override
  String get changeLog_260_2 =>
      'Tüm kullanıcılar artık ekipman ekleyebilir ve bunları avlara bağlayabilir.';

  @override
  String get changeLog_260_3 =>
      'Bir yem adının yem listesindeki değişken metin tarafından kesilmesi sorunu düzeltildi.';

  @override
  String get changeLog_260_4 =>
      'Otomatik olarak getirilen veriler artık bir av\'nin av noktası\'si değiştiğinde güncelleniyor.';

  @override
  String get changeLog_260_5 =>
      'Atmosfer ve hava durumu verileri artık geziler için otomatik getiriliyor.';

  @override
  String get changeLog_270_1 =>
      'Diğer sayfasına gerçek zamanlı yakalanan tür sayacı (Pro özelliği) eklendi.';

  @override
  String get changeLog_270_2 =>
      'av görüntülerken bir av kopyala düğmesi (Pro özelliği) eklendi.';

  @override
  String get changeLog_270_3 => 'yem varyantlara fotoğraf eklendi.';

  @override
  String get changeLog_270_4 => 'Gezilere su koşulları eklendi.';

  @override
  String get changeLog_270_5 => 'Başarısız yedek bildirimleri eklendi.';

  @override
  String get changeLog_270_6 =>
      'gelgit çizelgelerine alçak ve yüksek yükseklikler eklendi.';

  @override
  String get changeLog_270_7 =>
      'Rüzgar hızı birimi seçeneği olarak saniyede metre eklendi.';

  @override
  String get changeLog_270_8 =>
      'Raporların farklı zaman aralıkları için aynı verileri göstermesi sorunu düzeltildi.';

  @override
  String get changeLog_270_9 =>
      'Bazı cihazlarda CSV kaydetme konumunu seçememeniz sorunu düzeltildi.';

  @override
  String get changeLog_270_10 =>
      'Bazı cihazlarda av veya gezi paylaşılamamasına neden olan sorun düzeltildi.';

  @override
  String get changeLog_270_11 =>
      'Gezi Özet raporunun yanlış en iyi uzunluk ve ağırlık değerlerini göstermesi sorunu düzeltildi.';

  @override
  String get changeLog_270_12 =>
      'Bize geri bildirim göndermeye çalışırken oluşan hatalı ağ hatası düzeltildi.';

  @override
  String get changeLog_270_13 =>
      'av eklenirken artık balık tutma noktası atlanabiliyor.';

  @override
  String get changeLog_270_14 =>
      'Balık tutma noktası artık av\'den kaldırılabilir.';

  @override
  String get changeLog_270_15 =>
      'Dışa aktarılan CSV dosyaları artık enlem, boylam ve özel alanlar sütunlarını içeriyor.';

  @override
  String get changeLog_270_16 =>
      '\"Skunked\" damgası artık Birleşik Krallık\'taki kullanıcılar için \"Boş\" diyor.';

  @override
  String get changeLog_271_1 =>
      'Gelgit grafik artık y ekseni etiketlerini doğru birimde gösteriyor.';

  @override
  String get changeLog_271_2 =>
      'Uygulama güncellemesinden sonra bazı av fotoğrafların kaldırılması sorunu düzeltildi.';

  @override
  String get changeLog_272_1 =>
      'Harici bağlantıları açarken oluşan kilitlenme düzeltildi.';

  @override
  String get changeLog_273_1 => 'Av noktası ayrıntılarına av sayısı eklendi.';

  @override
  String get changeLog_273_2 =>
      'gelgit ayrıntılarına gelgit veri değeri eklendi.';

  @override
  String get changeLog_273_3 =>
      'Fotoğraflardaki güvenilmez yakınlaştırma düzeltildi.';

  @override
  String get changeLog_273_4 =>
      'Hava durumu verileri alınırken oluşan hata düzeltildi.';

  @override
  String get changeLog_273_5 => 'gelgit yükseklik değerleri düzeltildi.';

  @override
  String get changeLog_273_6 =>
      'GPS izleri ile başlayan kilitlenme düzeltildi.';

  @override
  String get changeLog_273_7 =>
      'İstatistik çubuğu grafiklerindeki metinlerin kesilmesi düzeltildi.';

  @override
  String get changeLog_274_1 =>
      'Bazı metin alanlarına metin ekleme sorunu düzeltildi.';

  @override
  String get changeLog_275_1 =>
      'av\'ın ağırlığından ondalık sayının kaldırılması düzeltildi.';

  @override
  String get changeLog_275_2 =>
      'Su sıcaklıklarının bazı hatalı yuvarlanması düzeltildi.';

  @override
  String get changeLog_275_3 =>
      'CSV dışa aktarımına \"içe aktarılamaz\" uyarısı eklendi.';

  @override
  String get changeLog_276_1 =>
      'Bazı bölgelerdeki sayı biçimlendirmesi düzeltildi.';

  @override
  String get changeLog_277_1 =>
      'Cihazın konumu kapatıldığında oluşan çökme düzeltildi.';

  @override
  String get changeLog_277_2 =>
      'İlk katılım sırasında nadir görülen çökme düzeltildi.';

  @override
  String get changeLog_277_3 =>
      'Norveç\'teki kullanıcılar için sabit sayı biçimlendirmesi.';

  @override
  String get changeLog_278_1 =>
      'Konum izni istendiğinde oluşan kilitlenme düzeltildi.';

  @override
  String get changeLog_278_2 =>
      'Belirli bölgelerdeki kullanıcılar için uygulamanın başlangıçta donması düzeltildi.';

  @override
  String get translationWarningPageTitle => 'Çeviriler';

  @override
  String get translationWarningPageDescription =>
      'Mera Asistanı\'ndaki metinler yapay zeka ile çevrilmiştir. Bir hata fark ederseniz veya bir şey mantıklı gelmezse Lütfen Diğer menüsünden Geri Bildirim Gönder\'e dokunarak bize ulaşın. Yardımınız her zaman değerlidir, teşekkürler!';

  @override
  String get proPageBackupWarning =>
      'Auto-yedek\'nin güvenilmez olduğu kanıtlandı. Biz araştırma yaparken bu özelliği kullanmanın riski size aittir. Daha fazla ayrıntı için Diğer menüsündeki Yedek ve Geri Yükle sayfalarını ziyaret edin.';

  @override
  String get changeLog_279_1 => 'Bazı kullanıcı arayüzü hataları düzeltildi.';

  @override
  String get changeLog_279_2 =>
      'Bulutun güvenilmezliğini yansıtacak bir uyarı eklendi yedek.';

  @override
  String get changeLog_279_3 => 'İspanyolca çeviriler eklendi.';

  @override
  String get changeLog_2710_1 =>
      'Kesme işareti kullanan bölgeler için büyük sayı biçimlendirmesi düzeltildi.';

  @override
  String get changeLog_2710_2 =>
      'Profesyonel sayfasındaki bazı metin hizalama sorunları düzeltildi.';

  @override
  String get changeLog_2711_1 =>
      'E-posta adresi olmadan geri bildirim gönderme hatası düzeltildi.';

  @override
  String get changeLog_2711_2 =>
      'Gezi kaydetme sayfasını kapatmadan gezi eklerken av eklenebilir.';

  @override
  String get changeLog_2711_3 =>
      'Eksik \"Son Av\'dan Beri\" ve \"Son Gezi\'dan Beri\" istatistik kutucukları düzeltildi.';

  @override
  String get feedbackPageSendData => 'Veri Gönder';

  @override
  String get feedbackPageSendDataDescription =>
      'Fotoğraflar hariç günlük verileriniz araştırmamıza yardımcı olmak için gönderilir.';

  @override
  String get changeLog_2712_1 =>
      'Hata raporlarına günlük verilerini dahil etme seçeneği eklendi.';

  @override
  String get changeLog_2712_2 =>
      'Özellik anketlerinde oy verirken yaşanan çökme sorunu düzeltildi.';

  @override
  String get changeLog_2712_3 =>
      'Av eklerken veya güncellerken oluşan kilitlenme düzeltildi.';

  @override
  String backupRestoreBackingUpData(String percent) {
    return 'Veriler yedekleniyor$percent...';
  }

  @override
  String get changeLog_2717_1 =>
      'İstatistikler/Takvim başlığının yanlış hizalanması sorunu düzeltildi.';

  @override
  String get changeLog_2717_2 =>
      'Işık modunda İstatistikler/Takvim başlığının yanlış renk olması sorunu düzeltildi.';

  @override
  String get changeLog_2717_3 =>
      'İstatistik raporlarının süresiz olarak yüklenebilmesi sorunu düzeltildi.';

  @override
  String get changeLog_2716_1 =>
      '\"Gezi Başına Avlar\" alanlarına girilen değerlerin 0\'a sıfırlanması sorunu düzeltildi.';

  @override
  String get changeLog_2715_1 =>
      'Haritayla etkileşimde bulunulurken nadir görülen bir çökme düzeltildi.';

  @override
  String get changeLog_2714_1 =>
      'Av eklerken fotoğraf konumlarının kullanılmaması sorunu düzeltildi.';

  @override
  String get changeLog_2713_1 =>
      'Yedekleme ve geri yükleme artık çok daha hızlı.';

  @override
  String get changeLog_2713_2 =>
      'Kişisel Rekorlar raporu artık balıkçı\'ye göre filtrelenebilir.';

  @override
  String get changeLog_2713_3 =>
      'Avlar artık isteğe bağlı olarak gezilere otomatik eklenebilir.';

  @override
  String get changeLog_2713_4 =>
      'Avların yanlış günde gösterilmesine neden olan raporlama sorunu düzeltildi.';
}
