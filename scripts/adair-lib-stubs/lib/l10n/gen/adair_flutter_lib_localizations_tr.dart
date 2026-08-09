// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'adair_flutter_lib_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AdairFlutterLibLocalizationsTr extends AdairFlutterLibLocalizations {
  AdairFlutterLibLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get add => 'Ekle';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get ok => 'Tamam';

  @override
  String get error => 'Hata';

  @override
  String get warning => 'Uyarı';

  @override
  String get continueString => 'Devam';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String yearsFormat(int numOfYears) {
    return '${numOfYears}y';
  }

  @override
  String daysFormat(int numOfDays) {
    return '${numOfDays}g';
  }

  @override
  String hoursFormat(int numOfHours) {
    return '${numOfHours}s';
  }

  @override
  String minutesFormat(int numOfMinutes) {
    return '${numOfMinutes}dk';
  }

  @override
  String secondsFormat(int numOfSeconds) {
    return '${numOfSeconds}sn';
  }

  @override
  String dateTimeFormat(String date, String time) {
    return '$date saat $time';
  }

  @override
  String dateRangeFormat(String from, String to) {
    return '$from – $to';
  }

  @override
  String get now => 'Şimdi';

  @override
  String get durationAllDates => 'Tüm tarihler';

  @override
  String get durationToday => 'Bugün';

  @override
  String get durationYesterday => 'Dün';

  @override
  String get durationThisWeek => 'Bu hafta';

  @override
  String get durationThisMonth => 'Bu ay';

  @override
  String get durationThisYear => 'Bu yıl';

  @override
  String get durationLastWeek => 'Geçen hafta';

  @override
  String get durationLastMonth => 'Geçen ay';

  @override
  String get durationLastYear => 'Geçen yıl';

  @override
  String get durationLast7Days => 'Son 7 gün';

  @override
  String get durationLast14Days => 'Son 14 gün';

  @override
  String get durationLast30Days => 'Son 30 gün';

  @override
  String get durationLast60Days => 'Son 60 gün';

  @override
  String get durationLast12Months => 'Son 12 ay';

  @override
  String get durationCustom => 'Özel';

  @override
  String proPageUpgradeTitle(String appName) {
    return '$appName sürümüne yükselt';
  }

  @override
  String get proPageProTitle => 'Pro';

  @override
  String proPageYearlyTitle(String price) {
    return '$price/yıl';
  }

  @override
  String proPageYearlyTrial(int numOfDays) {
    return '+$numOfDays gün ücretsiz';
  }

  @override
  String get proPageYearlySubtext => 'Yıllık faturalandırılır';

  @override
  String proPageMonthlyTitle(String price) {
    return '$price/ay';
  }

  @override
  String proPageMonthlyTrial(int numOfDays) {
    return '+$numOfDays gün ücretsiz';
  }

  @override
  String get proPageMonthlySubtext => 'Aylık faturalandırılır';

  @override
  String get proPageFetchError =>
      'Abonelik seçenekleri getirilemiyor. Cihazınızın internete bağlı olduğundan emin olun ve yeniden deneyin.';

  @override
  String get proPageUpgradeSuccess => 'Tebrikler, artık Pro kullanıcısısınız!';

  @override
  String get proPageRestoreQuestion => 'Pro\'ya başka bir cihazda mı abone oldunuz?';

  @override
  String get proPageRestoreAction => 'Geri yükle.';

  @override
  String get proPageRestoreNoneFoundAppStore =>
      'Önceki satın alma bulunamadı. Lütfen orijinal satın almayı yaptığınız aynı Apple Kimliği ile oturum açtığınızdan emin olun.';

  @override
  String get proPageRestoreNoneFoundGooglePlay =>
      'Önceki satın alma bulunamadı. Lütfen orijinal satın almayı yaptığınız aynı Google hesabıyla oturum açtığınızdan emin olun.';

  @override
  String get proPageRestoreError =>
      'Beklenmeyen bir hata oluştu. Cihazınızın internete bağlı olduğundan emin olun ve yeniden deneyin.';

  @override
  String get proPageDisclosureApple =>
      'İstediğiniz zaman iptal edin. Faturalandırma ücretsiz deneme süresi bittikten sonra başlar. Ücretsiz deneme yalnızca yeni aboneler için geçerlidir. Abonelikler, mevcut abonelik döneminin bitiminden en az 24 saat önce iptal edilmedikçe otomatik olarak yenilenir. Tüm abonelikler App Store üzerinden yönetilebilir. Bir abonelik satın alındığında ücretsiz denemenin kullanılmayan kısmı kaybedilir.';

  @override
  String get proPageDisclosureAndroid =>
      'İstediğiniz zaman iptal edin. Faturalandırma ücretsiz deneme süresi bittikten sonra başlar. Ücretsiz deneme yalnızca yeni aboneler için geçerlidir. Abonelikler, mevcut abonelik döneminin bitiminden en az 24 saat önce iptal edilmedikçe otomatik olarak yenilenir. Tüm abonelikler Google Play Store üzerinden yönetilebilir. Bir abonelik satın alındığında ücretsiz denemenin kullanılmayan kısmı kaybedilir.';

  @override
  String get dateFormatMonth => 'MMM';

  @override
  String get dateFormatMonthDay => 'd MMM';

  @override
  String get dateFormatMonthDayYear => 'd MMM yyyy';

  @override
  String get dateFormatMonthDayYearFull => 'd MMMM yyyy';

  @override
  String get dateFormatMonthFull => 'MMMM';

  @override
  String get dateFormatMonthYearFull => 'MMMM yyyy';

  @override
  String get dateFormatWeekDay => 'E';

  @override
  String get dateFormatWeekDayFull => 'EEEE';

  @override
  String get no => 'Hayır';

  @override
  String get yes => 'Evet';

  @override
  String get proChipButtonLabel => 'Pro';

  @override
  String get notificationPermissionPageTitle => 'Bildirim';

  @override
  String get setPermissionButton => 'İzni Ayarla';

  @override
  String get signInPageEmailLabel => 'E-posta';

  @override
  String get signInPagePasswordLabel => 'Şifre';

  @override
  String get signInPageSignInButton => 'Oturum Aç';

  @override
  String landingPageInitError(Object appName) {
    return 'Eyvah! Başlatma sırasında bir şeyler ters gitti. $appName ekibi bilgilendirildi; rahatsızlık için özür dileriz.';
  }

  @override
  String get by => 'tarafından';

  @override
  String get signInPageErrorInvalidEmail => 'Geçersiz e-posta adresi biçimi.';

  @override
  String get signInPageErrorNetworkFailed => 'Lütfen ağ bağlantınızı kontrol edip yeniden deneyin.';

  @override
  String get signInPageErrorOperationNotAllowed => 'Bu uygulama için e-posta ve şifre ile oturum açma devre dışı.';

  @override
  String get signInPageErrorTokenExpired => 'Kimlik doğrulama süresi doldu. Lütfen yeniden deneyin.';

  @override
  String get signInPageErrorTooManyRequests =>
      'Oturum açma geçici olarak sınırlandı. Lütfen daha sonra yeniden deneyin.';

  @override
  String get signInPageErrorUserDisabled => 'Kullanıcı devre dışı bırakıldı.';

  @override
  String get signInPageErrorUserNotFound => 'Bu e-posta adresiyle kullanıcı bulunamadı.';

  @override
  String get signInPageErrorInvalidCredentials => 'E-posta ve şifre kombinasyonu yanlış.';

  @override
  String get signInPageErrorGeneric => 'Oturum açılırken bir hata oluştu. Lütfen yeniden deneyin.';

  @override
  String get inputNameLabel => 'Ad';

  @override
  String get inputDescriptionLabel => 'Açıklama';

  @override
  String get inputEmailLabel => 'E-posta';

  @override
  String get inputGenericRequired => 'Zorunlu';

  @override
  String get inputInvalidNumber => 'Geçersiz sayı girişi';

  @override
  String get inputInvalidEmail => 'Geçersiz e-posta biçimi';

  @override
  String inputUnknownError(Object code) {
    return 'Bilinmeyen hata ($code).';
  }

  @override
  String get signInPageResetPasswordButton => 'Şifreyi Sıfırla';

  @override
  String get signInPageResetPasswordDialogTitle => 'Şifreyi Sıfırla';

  @override
  String get signInPageResetPasswordDialogMessage =>
      'E-posta adresinizi girin, size şifre sıfırlama talimatlarını gönderelim.';

  @override
  String get signInPageResetPasswordDialogAction => 'Sıfırla';

  @override
  String get signInPageResetPasswordConfirmation =>
      'Bu e-posta adresi için bir hesap varsa kısa süre içinde bir şifre sıfırlama bağlantısı alırsınız. Gelmezse spam veya istenmeyen klasörünüzü kontrol edin.';

  @override
  String get version => 'Sürüm';
}
