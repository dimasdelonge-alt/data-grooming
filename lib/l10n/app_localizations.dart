import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ms.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('ms'),
  ];

  /// Nama aplikasi
  ///
  /// In id, this message translates to:
  /// **'Data Groomer App'**
  String get appName;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get edit;

  /// No description provided for @yes.
  ///
  /// In id, this message translates to:
  /// **'Ya'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get no;

  /// No description provided for @success.
  ///
  /// In id, this message translates to:
  /// **'Berhasil'**
  String get success;

  /// No description provided for @error.
  ///
  /// In id, this message translates to:
  /// **'Galat'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get loading;

  /// No description provided for @search.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get account;

  /// No description provided for @recentActivity.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas Terbaru'**
  String get recentActivity;

  /// No description provided for @catList.
  ///
  /// In id, this message translates to:
  /// **'Daftar Kucing'**
  String get catList;

  /// No description provided for @businessNamePlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Nama Bisnis'**
  String get businessNamePlaceholder;

  /// No description provided for @goodMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat Pagi'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat Siang'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In id, this message translates to:
  /// **'Selamat Sore'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat Malam'**
  String get goodNight;

  /// No description provided for @netProfit.
  ///
  /// In id, this message translates to:
  /// **'Laba Bersih'**
  String get netProfit;

  /// No description provided for @income.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get expense;

  /// No description provided for @newSession.
  ///
  /// In id, this message translates to:
  /// **'Sesi Baru'**
  String get newSession;

  /// No description provided for @cats.
  ///
  /// In id, this message translates to:
  /// **'Kucing'**
  String get cats;

  /// No description provided for @hotel.
  ///
  /// In id, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// No description provided for @booking.
  ///
  /// In id, this message translates to:
  /// **'Booking'**
  String get booking;

  /// No description provided for @deposit.
  ///
  /// In id, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @services.
  ///
  /// In id, this message translates to:
  /// **'Layanan'**
  String get services;

  /// No description provided for @calendar.
  ///
  /// In id, this message translates to:
  /// **'Kalender'**
  String get calendar;

  /// No description provided for @activeSessions.
  ///
  /// In id, this message translates to:
  /// **'Sesi Aktif'**
  String get activeSessions;

  /// No description provided for @processingNow.
  ///
  /// In id, this message translates to:
  /// **'Sedang diproses sekarang'**
  String get processingNow;

  /// No description provided for @seeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua'**
  String get seeAll;

  /// No description provided for @groomingSchedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Grooming'**
  String get groomingSchedule;

  /// No description provided for @noReschedule.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada jadwal ulang'**
  String get noReschedule;

  /// No description provided for @owner.
  ///
  /// In id, this message translates to:
  /// **'Pemilik'**
  String get owner;

  /// No description provided for @sessionsCountLabel.
  ///
  /// In id, this message translates to:
  /// **'{count} sesi'**
  String sessionsCountLabel(int count);

  /// No description provided for @daysAgoLabel.
  ///
  /// In id, this message translates to:
  /// **'{days} hari lalu'**
  String daysAgoLabel(int days);

  /// No description provided for @errEmptyShopIdPassword.
  ///
  /// In id, this message translates to:
  /// **'Shop ID dan Password harus diisi'**
  String get errEmptyShopIdPassword;

  /// No description provided for @errShopIdNotFound.
  ///
  /// In id, this message translates to:
  /// **'Shop ID tidak ditemukan'**
  String get errShopIdNotFound;

  /// No description provided for @errDeviceLimit.
  ///
  /// In id, this message translates to:
  /// **'Login ditolak: Limit perangkat tercapai ({count} device).\\nSilakan upgrade ke PRO untuk akses lebih banyak.'**
  String errDeviceLimit(int count);

  /// No description provided for @errWrongPassword.
  ///
  /// In id, this message translates to:
  /// **'Password salah'**
  String get errWrongPassword;

  /// No description provided for @errNetwork.
  ///
  /// In id, this message translates to:
  /// **'Gagal terhubung ke server'**
  String get errNetwork;

  /// No description provided for @errAllFieldsRequired.
  ///
  /// In id, this message translates to:
  /// **'Semua field harus diisi'**
  String get errAllFieldsRequired;

  /// No description provided for @errInvalidShopId.
  ///
  /// In id, this message translates to:
  /// **'Shop ID tidak boleh mengandung spasi atau /'**
  String get errInvalidShopId;

  /// No description provided for @errPasswordMinLength.
  ///
  /// In id, this message translates to:
  /// **'Password minimal 6 karakter'**
  String get errPasswordMinLength;

  /// No description provided for @errPasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Password tidak cocok'**
  String get errPasswordMismatch;

  /// No description provided for @errShopIdTaken.
  ///
  /// In id, this message translates to:
  /// **'Shop ID \"{shopId}\" sudah dipakai, coba yang lain'**
  String errShopIdTaken(String shopId);

  /// No description provided for @errCreateAccount.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat akun: {error}'**
  String errCreateAccount(String error);

  /// No description provided for @msgForgotPwdWithId.
  ///
  /// In id, this message translates to:
  /// **'Halo, saya lupa password SmartGroomer. Shop ID saya: {shopId}'**
  String msgForgotPwdWithId(String shopId);

  /// No description provided for @msgForgotPwd.
  ///
  /// In id, this message translates to:
  /// **'Halo, saya lupa password SmartGroomer.'**
  String get msgForgotPwd;

  /// No description provided for @createAccount.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun Baru'**
  String get createAccount;

  /// No description provided for @signInToAccount.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke Akun'**
  String get signInToAccount;

  /// No description provided for @shopIdHint.
  ///
  /// In id, this message translates to:
  /// **'cth: jeni_cathouse'**
  String get shopIdHint;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @repeatPassword.
  ///
  /// In id, this message translates to:
  /// **'Ulangi Password'**
  String get repeatPassword;

  /// No description provided for @register.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get register;

  /// No description provided for @login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun? Masuk'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun? Buat Baru'**
  String get dontHaveAccount;

  /// No description provided for @forgotPasswordAdmin.
  ///
  /// In id, this message translates to:
  /// **'Lupa Password? Hubungi Admin'**
  String get forgotPasswordAdmin;

  /// No description provided for @accountAndBackup.
  ///
  /// In id, this message translates to:
  /// **'Akun & Backup'**
  String get accountAndBackup;

  /// No description provided for @shopSync.
  ///
  /// In id, this message translates to:
  /// **'Sinkronisasi Toko'**
  String get shopSync;

  /// No description provided for @shopConnected.
  ///
  /// In id, this message translates to:
  /// **'Toko Terhubung'**
  String get shopConnected;

  /// No description provided for @connectShop.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan Toko'**
  String get connectShop;

  /// No description provided for @shopIdValue.
  ///
  /// In id, this message translates to:
  /// **'ID: {shopId}'**
  String shopIdValue(String shopId);

  /// No description provided for @notConnectedToShop.
  ///
  /// In id, this message translates to:
  /// **'Belum terhubung ke toko'**
  String get notConnectedToShop;

  /// No description provided for @subscriptionStatus.
  ///
  /// In id, this message translates to:
  /// **'Status Langganan'**
  String get subscriptionStatus;

  /// No description provided for @cloudBackupRestore.
  ///
  /// In id, this message translates to:
  /// **'Backup & Restore Cloud'**
  String get cloudBackupRestore;

  /// No description provided for @connectShopFirstForCloud.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan ke Toko terlebih dahulu untuk menggunakan fitur Cloud Backup.'**
  String get connectShopFirstForCloud;

  /// No description provided for @backupData.
  ///
  /// In id, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @backupDataDesc.
  ///
  /// In id, this message translates to:
  /// **'Upload semua data lokal ke Cloud'**
  String get backupDataDesc;

  /// No description provided for @uploadDataNow.
  ///
  /// In id, this message translates to:
  /// **'Upload data sekarang?'**
  String get uploadDataNow;

  /// No description provided for @dataWillBeOverwrittenProceed.
  ///
  /// In id, this message translates to:
  /// **'Data lokal akan ditimpa! Lanjutkan?'**
  String get dataWillBeOverwrittenProceed;

  /// No description provided for @restoreData.
  ///
  /// In id, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @restoreDataDesc.
  ///
  /// In id, this message translates to:
  /// **'Download dan timpa data lokal dari Cloud'**
  String get restoreDataDesc;

  /// No description provided for @localBackupRestore.
  ///
  /// In id, this message translates to:
  /// **'Backup & Restore Lokal'**
  String get localBackupRestore;

  /// No description provided for @offlineBackupZip.
  ///
  /// In id, this message translates to:
  /// **'Backup Offline (ZIP)'**
  String get offlineBackupZip;

  /// No description provided for @offlineBackupZipDesc.
  ///
  /// In id, this message translates to:
  /// **'Simpan database & foto ke file ZIP'**
  String get offlineBackupZipDesc;

  /// No description provided for @offlineRestoreZip.
  ///
  /// In id, this message translates to:
  /// **'Restore Offline (ZIP)'**
  String get offlineRestoreZip;

  /// No description provided for @offlineRestoreZipDesc.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan data dari file ZIP'**
  String get offlineRestoreZipDesc;

  /// No description provided for @restoreOffline.
  ///
  /// In id, this message translates to:
  /// **'Restore Offline'**
  String get restoreOffline;

  /// No description provided for @shopId.
  ///
  /// In id, this message translates to:
  /// **'Shop ID'**
  String get shopId;

  /// No description provided for @secretKey.
  ///
  /// In id, this message translates to:
  /// **'Secret Key'**
  String get secretKey;

  /// No description provided for @createNew.
  ///
  /// In id, this message translates to:
  /// **'Buat Baru'**
  String get createNew;

  /// No description provided for @invalidIdOrKey.
  ///
  /// In id, this message translates to:
  /// **'ID atau Key salah, atau periksa koneksi internet.'**
  String get invalidIdOrKey;

  /// No description provided for @connect.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan'**
  String get connect;

  /// No description provided for @createNewShop.
  ///
  /// In id, this message translates to:
  /// **'Buat Toko Baru'**
  String get createNewShop;

  /// No description provided for @createNewShopDesc.
  ///
  /// In id, this message translates to:
  /// **'ID dan Secret Key akan dibuat otomatis. Anda juga dapat menentukan ID sendiri (opsional). Data lokal saat ini akan di-upload ke cloud.'**
  String get createNewShopDesc;

  /// No description provided for @shopName.
  ///
  /// In id, this message translates to:
  /// **'Nama Toko'**
  String get shopName;

  /// No description provided for @customShopIdOptional.
  ///
  /// In id, this message translates to:
  /// **'Custom Shop ID (Opsional)'**
  String get customShopIdOptional;

  /// No description provided for @customShopIdHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: JENICATHOUSE'**
  String get customShopIdHint;

  /// No description provided for @shopCreatedSuccess.
  ///
  /// In id, this message translates to:
  /// **'Toko berhasil dibuat! ID: {shopId}'**
  String shopCreatedSuccess(String shopId);

  /// No description provided for @shopCreatedFail.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat toko. Periksa koneksi.'**
  String get shopCreatedFail;

  /// No description provided for @createAndUpload.
  ///
  /// In id, this message translates to:
  /// **'Buat & Upload'**
  String get createAndUpload;

  /// No description provided for @restoreDataPrompt.
  ///
  /// In id, this message translates to:
  /// **'Restore Data?'**
  String get restoreDataPrompt;

  /// No description provided for @restoreDataPromptDesc.
  ///
  /// In id, this message translates to:
  /// **'Berhasil terhubung. Apakah Anda ingin download & restore data dari cloud sekarang?'**
  String get restoreDataPromptDesc;

  /// No description provided for @later.
  ///
  /// In id, this message translates to:
  /// **'Nanti Saja'**
  String get later;

  /// No description provided for @restoreSuccess.
  ///
  /// In id, this message translates to:
  /// **'Restore berhasil! Data sedang diperbarui.'**
  String get restoreSuccess;

  /// No description provided for @restoreFail.
  ///
  /// In id, this message translates to:
  /// **'Restore gagal! Periksa koneksi atau Secret Key Anda.'**
  String get restoreFail;

  /// No description provided for @yesRestore.
  ///
  /// In id, this message translates to:
  /// **'Ya, Restore'**
  String get yesRestore;

  /// No description provided for @disconnectShopPrompt.
  ///
  /// In id, this message translates to:
  /// **'Putuskan Koneksi?'**
  String get disconnectShopPrompt;

  /// No description provided for @disconnectShopDesc.
  ///
  /// In id, this message translates to:
  /// **'Fitur sinkronisasi dan backup cloud akan dinonaktifkan. Data lokal tetap aman.'**
  String get disconnectShopDesc;

  /// No description provided for @shopConnectionDisconnected.
  ///
  /// In id, this message translates to:
  /// **'Koneksi toko diputuskan'**
  String get shopConnectionDisconnected;

  /// No description provided for @disconnect.
  ///
  /// In id, this message translates to:
  /// **'Putuskan'**
  String get disconnect;

  /// No description provided for @yesProceed.
  ///
  /// In id, this message translates to:
  /// **'Ya, Lanjutkan'**
  String get yesProceed;

  /// No description provided for @hiddenForSecurity.
  ///
  /// In id, this message translates to:
  /// **'•••••••• (Tersembunyi demi keamanan)'**
  String get hiddenForSecurity;

  /// No description provided for @checkingStatus.
  ///
  /// In id, this message translates to:
  /// **'Mengecek status...'**
  String get checkingStatus;

  /// No description provided for @statusValue.
  ///
  /// In id, this message translates to:
  /// **'Status: {plan}'**
  String statusValue(String plan);

  /// No description provided for @checkStatus.
  ///
  /// In id, this message translates to:
  /// **'Cek Status'**
  String get checkStatus;

  /// No description provided for @validUntilValue.
  ///
  /// In id, this message translates to:
  /// **'Berlaku Sampai: {date}'**
  String validUntilValue(String date);

  /// No description provided for @deviceLimitValue.
  ///
  /// In id, this message translates to:
  /// **'Limit Perangkat: {count}'**
  String deviceLimitValue(int count);

  /// No description provided for @deviceIdValue.
  ///
  /// In id, this message translates to:
  /// **'Device ID: {deviceId}'**
  String deviceIdValue(String deviceId);

  /// No description provided for @upgradeToProWhatsapp.
  ///
  /// In id, this message translates to:
  /// **'Halo Admin, saya ingin upgrade aplikasi DataGrooming saya ke PRO. ID Toko: {shopId}'**
  String upgradeToProWhatsapp(String shopId);

  /// No description provided for @upgradeToPro.
  ///
  /// In id, this message translates to:
  /// **'Tingkatkan ke PRO'**
  String get upgradeToPro;

  /// No description provided for @planFree.
  ///
  /// In id, this message translates to:
  /// **'GRATIS'**
  String get planFree;

  /// No description provided for @home.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get home;

  /// No description provided for @activity.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas'**
  String get activity;

  /// No description provided for @financial.
  ///
  /// In id, this message translates to:
  /// **'Keuangan'**
  String get financial;

  /// No description provided for @quickAction.
  ///
  /// In id, this message translates to:
  /// **'Aksi Cepat'**
  String get quickAction;

  /// No description provided for @hotelCheckIn.
  ///
  /// In id, this message translates to:
  /// **'Check-in Hotel'**
  String get hotelCheckIn;

  /// No description provided for @catListCount.
  ///
  /// In id, this message translates to:
  /// **'Daftar Kucing ({count})'**
  String catListCount(int count);

  /// No description provided for @hideArchived.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan Arsip'**
  String get hideArchived;

  /// No description provided for @viewArchived.
  ///
  /// In id, this message translates to:
  /// **'Lihat Terarsip'**
  String get viewArchived;

  /// No description provided for @searchCatOrOwner.
  ///
  /// In id, this message translates to:
  /// **'Cari Kucing / Owner'**
  String get searchCatOrOwner;

  /// No description provided for @noCatsMatchSearch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kucing yang cocok dengan pencarian.'**
  String get noCatsMatchSearch;

  /// No description provided for @noCatDataYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data kucing.'**
  String get noCatDataYet;

  /// No description provided for @tryAnotherKeyword.
  ///
  /// In id, this message translates to:
  /// **'Coba kata kunci lain.'**
  String get tryAnotherKeyword;

  /// No description provided for @tapPlusToAddCat.
  ///
  /// In id, this message translates to:
  /// **'Tap tombol + untuk menambah kucing.'**
  String get tapPlusToAddCat;

  /// No description provided for @dataLockedStarterLimit.
  ///
  /// In id, this message translates to:
  /// **'Data ini terkunci (Limit Starter 15). Silakan upgrade ke PRO!'**
  String get dataLockedStarterLimit;

  /// No description provided for @starterLimit15CatsReached.
  ///
  /// In id, this message translates to:
  /// **'Batas Starter 15 kucing tercapai! Silakan upgrade ke PRO!'**
  String get starterLimit15CatsReached;

  /// No description provided for @archiveCatPrompt.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan Kucing?'**
  String get archiveCatPrompt;

  /// No description provided for @archiveCatDesc.
  ///
  /// In id, this message translates to:
  /// **'\"{catName}\" memiliki riwayat transaksi dan tidak bisa dihapus. Dengan mengarsipkan, data keuangan tetap aman namun kucing tidak akan muncul lagi di daftar dan pengingat.'**
  String archiveCatDesc(String catName);

  /// No description provided for @archive.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan'**
  String get archive;

  /// No description provided for @catArchivedSuccess.
  ///
  /// In id, this message translates to:
  /// **'{catName} telah diarsipkan'**
  String catArchivedSuccess(String catName);

  /// No description provided for @unarchiveCatPrompt.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Kembali?'**
  String get unarchiveCatPrompt;

  /// No description provided for @unarchiveCatDesc.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda ingin memulihkan \"{catName}\"? Kucing ini akan muncul kembali di daftar aktif.'**
  String unarchiveCatDesc(String catName);

  /// No description provided for @unarchive.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan'**
  String get unarchive;

  /// No description provided for @catUnarchivedSuccess.
  ///
  /// In id, this message translates to:
  /// **'{catName} telah diaktifkan kembali'**
  String catUnarchivedSuccess(String catName);

  /// No description provided for @deleteFailedHasHistory.
  ///
  /// In id, this message translates to:
  /// **'Hapus gagal: Kucing ini memiliki riwayat. Gunakan fitur Arsip.'**
  String get deleteFailedHasHistory;

  /// No description provided for @deleteCatPrompt.
  ///
  /// In id, this message translates to:
  /// **'Hapus Kucing?'**
  String get deleteCatPrompt;

  /// No description provided for @deleteCatDesc.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus \"{catName}\"? Semua riwayat grooming juga akan dihapus.'**
  String deleteCatDesc(String catName);

  /// No description provided for @catDeletedSuccess.
  ///
  /// In id, this message translates to:
  /// **'{catName} telah dihapus'**
  String catDeletedSuccess(String catName);

  /// No description provided for @catNotFound.
  ///
  /// In id, this message translates to:
  /// **'Kucing tidak ditemukan.'**
  String get catNotFound;

  /// No description provided for @groomingHistoryCount.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Grooming ({count})'**
  String groomingHistoryCount(int count);

  /// No description provided for @noGroomingHistoryYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat grooming.'**
  String get noGroomingHistoryYet;

  /// No description provided for @information.
  ///
  /// In id, this message translates to:
  /// **'Informasi'**
  String get information;

  /// No description provided for @phone.
  ///
  /// In id, this message translates to:
  /// **'Telepon'**
  String get phone;

  /// No description provided for @furColor.
  ///
  /// In id, this message translates to:
  /// **'Warna Bulu'**
  String get furColor;

  /// No description provided for @eyeColor.
  ///
  /// In id, this message translates to:
  /// **'Warna Mata'**
  String get eyeColor;

  /// No description provided for @weight.
  ///
  /// In id, this message translates to:
  /// **'Berat'**
  String get weight;

  /// No description provided for @sterile.
  ///
  /// In id, this message translates to:
  /// **'Steril'**
  String get sterile;

  /// No description provided for @isSterileYes.
  ///
  /// In id, this message translates to:
  /// **'Sudah Steril'**
  String get isSterileYes;

  /// No description provided for @isSterileNo.
  ///
  /// In id, this message translates to:
  /// **'Belum Steril'**
  String get isSterileNo;

  /// No description provided for @loyaltyCompleted.
  ///
  /// In id, this message translates to:
  /// **'Loyalty Completed! 🎉'**
  String get loyaltyCompleted;

  /// No description provided for @groomingReportShare.
  ///
  /// In id, this message translates to:
  /// **'Grooming Report\nKucing: {catName}\nTanggal: {date}\nBiaya: {cost}\nCatatan: {notes}'**
  String groomingReportShare(
    String catName,
    String date,
    String cost,
    String notes,
  );

  /// No description provided for @chooseProfilePhoto.
  ///
  /// In id, this message translates to:
  /// **'Pilih Foto Profil'**
  String get chooseProfilePhoto;

  /// No description provided for @camera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri'**
  String get gallery;

  /// No description provided for @editCat.
  ///
  /// In id, this message translates to:
  /// **'Edit Kucing'**
  String get editCat;

  /// No description provided for @addCat.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kucing'**
  String get addCat;

  /// No description provided for @catInfo.
  ///
  /// In id, this message translates to:
  /// **'Info Kucing'**
  String get catInfo;

  /// No description provided for @catNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Kucing'**
  String get catNameLabel;

  /// No description provided for @weightKg.
  ///
  /// In id, this message translates to:
  /// **'Berat Badan (kg)'**
  String get weightKg;

  /// No description provided for @gender.
  ///
  /// In id, this message translates to:
  /// **'Jenis Kelamin'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In id, this message translates to:
  /// **'Jantan'**
  String get male;

  /// No description provided for @female.
  ///
  /// In id, this message translates to:
  /// **'Betina'**
  String get female;

  /// No description provided for @yesSterilized.
  ///
  /// In id, this message translates to:
  /// **'Ya, sudah steril'**
  String get yesSterilized;

  /// No description provided for @notSterilizedYet.
  ///
  /// In id, this message translates to:
  /// **'Belum steril'**
  String get notSterilizedYet;

  /// No description provided for @ownerInfo.
  ///
  /// In id, this message translates to:
  /// **'Info Pemilik'**
  String get ownerInfo;

  /// No description provided for @ownerPhoneLabel.
  ///
  /// In id, this message translates to:
  /// **'No. Telp Pemilik'**
  String get ownerPhoneLabel;

  /// No description provided for @warning.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get warning;

  /// No description provided for @permanentWarningNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan Peringatan Permanen'**
  String get permanentWarningNote;

  /// No description provided for @warningNoteExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Galak, Jantung Lemah'**
  String get warningNoteExample;

  /// No description provided for @limitReached15.
  ///
  /// In id, this message translates to:
  /// **'LIMIT TERCAPAI (15 Ekor)'**
  String get limitReached15;

  /// No description provided for @freeVersionUpgradeToPro.
  ///
  /// In id, this message translates to:
  /// **'Anda menggunakan versi Gratis. Silakan upgrade ke PRO untuk menambah data tanpa batas.'**
  String get freeVersionUpgradeToPro;

  /// No description provided for @updateCat.
  ///
  /// In id, this message translates to:
  /// **'Update Kucing'**
  String get updateCat;

  /// No description provided for @saveCat.
  ///
  /// In id, this message translates to:
  /// **'Simpan Kucing'**
  String get saveCat;

  /// No description provided for @fieldRequired.
  ///
  /// In id, this message translates to:
  /// **'{field} wajib diisi'**
  String fieldRequired(String field);

  /// No description provided for @enterField.
  ///
  /// In id, this message translates to:
  /// **'Masukkan {field}'**
  String enterField(String field);

  /// No description provided for @ownerName.
  ///
  /// In id, this message translates to:
  /// **'Nama Pemilik'**
  String get ownerName;

  /// No description provided for @ownerNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama Pemilik wajib diisi'**
  String get ownerNameRequired;

  /// No description provided for @searchOrEnterOwnerName.
  ///
  /// In id, this message translates to:
  /// **'Cari atau masukkan nama pemilik'**
  String get searchOrEnterOwnerName;

  /// No description provided for @onlySelectSameOwnerSession.
  ///
  /// In id, this message translates to:
  /// **'Hanya bisa memilih session dari pemilik yang sama ({ownerName})'**
  String onlySelectSameOwnerSession(String ownerName);

  /// No description provided for @printFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mencetak: {error}'**
  String printFailed(String error);

  /// No description provided for @selectedCount.
  ///
  /// In id, this message translates to:
  /// **'{count} dipilih'**
  String selectedCount(int count);

  /// No description provided for @selectAllOwner.
  ///
  /// In id, this message translates to:
  /// **'Pilih Semua (owner {ownerName})'**
  String selectAllOwner(String ownerName);

  /// No description provided for @printCombinedInvoiceBtn.
  ///
  /// In id, this message translates to:
  /// **'Cetak Invoice Gabungan'**
  String get printCombinedInvoiceBtn;

  /// No description provided for @sessionHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Session'**
  String get sessionHistoryTitle;

  /// No description provided for @searchSession.
  ///
  /// In id, this message translates to:
  /// **'Cari session...'**
  String get searchSession;

  /// No description provided for @ownerOnlySessionWarning.
  ///
  /// In id, this message translates to:
  /// **'Owner: {ownerName} — hanya session dari owner ini yang bisa dipilih'**
  String ownerOnlySessionWarning(String ownerName);

  /// No description provided for @noSessionsYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada session.'**
  String get noSessionsYet;

  /// No description provided for @notFound.
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan.'**
  String get notFound;

  /// No description provided for @tapPlusButtonInCatDetail.
  ///
  /// In id, this message translates to:
  /// **'Tap tombol + di detail kucing.'**
  String get tapPlusButtonInCatDetail;

  /// No description provided for @sessionStarted.
  ///
  /// In id, this message translates to:
  /// **'Sesi dimulai! Masuk antrian.'**
  String get sessionStarted;

  /// No description provided for @groomingCheckIn.
  ///
  /// In id, this message translates to:
  /// **'Grooming Check-In'**
  String get groomingCheckIn;

  /// No description provided for @startNewSession.
  ///
  /// In id, this message translates to:
  /// **'Mulai Sesi Baru'**
  String get startNewSession;

  /// No description provided for @addNewCat.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kucing Baru'**
  String get addNewCat;

  /// No description provided for @checkInStartQueue.
  ///
  /// In id, this message translates to:
  /// **'Check In (Mulai Antrian)'**
  String get checkInStartQueue;

  /// No description provided for @currentQueue.
  ///
  /// In id, this message translates to:
  /// **'Antrian Saat Ini ({count})'**
  String currentQueue(int count);

  /// No description provided for @noActiveQueue.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada antrian aktif.'**
  String get noActiveQueue;

  /// No description provided for @unknownCat.
  ///
  /// In id, this message translates to:
  /// **'Kucing Tidak Diketahui'**
  String get unknownCat;

  /// No description provided for @setShopIdInSettings.
  ///
  /// In id, this message translates to:
  /// **'Silakan atur Shop ID di Settings'**
  String get setShopIdInSettings;

  /// No description provided for @trackingTokenNotAvailable.
  ///
  /// In id, this message translates to:
  /// **'Error: Token tracking belum tersedia'**
  String get trackingTokenNotAvailable;

  /// No description provided for @whatsappTrackingMessage.
  ///
  /// In id, this message translates to:
  /// **'Hai kak {ownerName} 👋\n\nUntuk memantau proses grooming {catName} sampai di tahap mana, bisa langsung dicek di link berikut ya:\n{link}\n\nTerima kasih sudah mempercayakan kami! 🐱✨'**
  String whatsappTrackingMessage(String ownerName, String catName, String link);

  /// No description provided for @whatsapp.
  ///
  /// In id, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @ownerLabel.
  ///
  /// In id, this message translates to:
  /// **'Owner: {ownerName}'**
  String ownerLabel(String ownerName);

  /// No description provided for @add.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get add;

  /// No description provided for @breed.
  ///
  /// In id, this message translates to:
  /// **'Ras / Jenis'**
  String get breed;

  /// No description provided for @shareLink.
  ///
  /// In id, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @bookingGrooming.
  ///
  /// In id, this message translates to:
  /// **'Booking Grooming'**
  String get bookingGrooming;

  /// No description provided for @noBookingSchedule.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada jadwal booking.'**
  String get noBookingSchedule;

  /// No description provided for @addBooking.
  ///
  /// In id, this message translates to:
  /// **'Tambah Booking'**
  String get addBooking;

  /// No description provided for @serviceType.
  ///
  /// In id, this message translates to:
  /// **'Jenis Layanan'**
  String get serviceType;

  /// No description provided for @deleteSchedule.
  ///
  /// In id, this message translates to:
  /// **'Hapus Jadwal'**
  String get deleteSchedule;

  /// No description provided for @deleteScheduleConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus jadwal ini secara permanen?'**
  String get deleteScheduleConfirm;

  /// No description provided for @confirm.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi'**
  String get confirm;

  /// No description provided for @cancelBooking.
  ///
  /// In id, this message translates to:
  /// **'Batalkan'**
  String get cancelBooking;

  /// No description provided for @reschedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwalkan Ulang'**
  String get reschedule;

  /// No description provided for @dateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get dateLabel;

  /// No description provided for @serviceLabel.
  ///
  /// In id, this message translates to:
  /// **'Layanan'**
  String get serviceLabel;

  /// No description provided for @whatsappReminder.
  ///
  /// In id, this message translates to:
  /// **'WhatsApp Reminder'**
  String get whatsappReminder;

  /// No description provided for @checkIn.
  ///
  /// In id, this message translates to:
  /// **'Check-In'**
  String get checkIn;

  /// No description provided for @bookingOn.
  ///
  /// In id, this message translates to:
  /// **'Booking pada {date}'**
  String bookingOn(String date);

  /// No description provided for @shortMonday.
  ///
  /// In id, this message translates to:
  /// **'Sen'**
  String get shortMonday;

  /// No description provided for @shortTuesday.
  ///
  /// In id, this message translates to:
  /// **'Sel'**
  String get shortTuesday;

  /// No description provided for @shortWednesday.
  ///
  /// In id, this message translates to:
  /// **'Rab'**
  String get shortWednesday;

  /// No description provided for @shortThursday.
  ///
  /// In id, this message translates to:
  /// **'Kam'**
  String get shortThursday;

  /// No description provided for @shortFriday.
  ///
  /// In id, this message translates to:
  /// **'Jum'**
  String get shortFriday;

  /// No description provided for @shortSaturday.
  ///
  /// In id, this message translates to:
  /// **'Sab'**
  String get shortSaturday;

  /// No description provided for @shortSunday.
  ///
  /// In id, this message translates to:
  /// **'Min'**
  String get shortSunday;

  /// No description provided for @noSchedule.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada jadwal.'**
  String get noSchedule;

  /// No description provided for @editSession.
  ///
  /// In id, this message translates to:
  /// **'Edit Session'**
  String get editSession;

  /// No description provided for @sessionNotFound.
  ///
  /// In id, this message translates to:
  /// **'Session tidak ditemukan.'**
  String get sessionNotFound;

  /// No description provided for @deleteSession.
  ///
  /// In id, this message translates to:
  /// **'Hapus Sesi'**
  String get deleteSession;

  /// No description provided for @deleteSessionConfirm.
  ///
  /// In id, this message translates to:
  /// **'Yakin hapus? Data tidak bisa dikembalikan.'**
  String get deleteSessionConfirm;

  /// No description provided for @status.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @findings.
  ///
  /// In id, this message translates to:
  /// **'Findings'**
  String get findings;

  /// No description provided for @treatments.
  ///
  /// In id, this message translates to:
  /// **'Treatments'**
  String get treatments;

  /// No description provided for @notes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get notes;

  /// No description provided for @totalCost.
  ///
  /// In id, this message translates to:
  /// **'Total Biaya'**
  String get totalCost;

  /// No description provided for @payFromDeposit.
  ///
  /// In id, this message translates to:
  /// **'Bayar dari Deposit'**
  String get payFromDeposit;

  /// No description provided for @balanceStr.
  ///
  /// In id, this message translates to:
  /// **'Saldo: {balance}'**
  String balanceStr(String balance);

  /// No description provided for @balanceNotEnoughDeduct.
  ///
  /// In id, this message translates to:
  /// **'Saldo kurang, akan dipotong {deductedAmount}'**
  String balanceNotEnoughDeduct(String deductedAmount);

  /// No description provided for @sessionDetail.
  ///
  /// In id, this message translates to:
  /// **'Session Detail'**
  String get sessionDetail;

  /// No description provided for @printInvoice.
  ///
  /// In id, this message translates to:
  /// **'Cetak Invoice'**
  String get printInvoice;

  /// No description provided for @catDataNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data kucing tidak ditemukan'**
  String get catDataNotFound;

  /// No description provided for @token.
  ///
  /// In id, this message translates to:
  /// **'Token'**
  String get token;

  /// No description provided for @groomerNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan Groomer'**
  String get groomerNotes;

  /// No description provided for @unknown.
  ///
  /// In id, this message translates to:
  /// **'Tidak Diketahui'**
  String get unknown;

  /// No description provided for @monthJan.
  ///
  /// In id, this message translates to:
  /// **'Januari'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In id, this message translates to:
  /// **'Februari'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In id, this message translates to:
  /// **'Maret'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In id, this message translates to:
  /// **'April'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In id, this message translates to:
  /// **'Mei'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In id, this message translates to:
  /// **'Juni'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In id, this message translates to:
  /// **'Juli'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In id, this message translates to:
  /// **'Agustus'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In id, this message translates to:
  /// **'September'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In id, this message translates to:
  /// **'Oktober'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In id, this message translates to:
  /// **'November'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In id, this message translates to:
  /// **'Desember'**
  String get monthDec;

  /// No description provided for @statusScheduled.
  ///
  /// In id, this message translates to:
  /// **'Dipesan'**
  String get statusScheduled;

  /// No description provided for @statusCompleted.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get statusCompleted;

  /// No description provided for @statusConfirmed.
  ///
  /// In id, this message translates to:
  /// **'Dikonfirmasi'**
  String get statusConfirmed;

  /// No description provided for @statusCancelled.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan'**
  String get statusCancelled;

  /// No description provided for @hotelKucing.
  ///
  /// In id, this message translates to:
  /// **'Hotel Kucing'**
  String get hotelKucing;

  /// No description provided for @roomStatus.
  ///
  /// In id, this message translates to:
  /// **'Status Kamar'**
  String get roomStatus;

  /// No description provided for @billing.
  ///
  /// In id, this message translates to:
  /// **'Biaya'**
  String get billing;

  /// No description provided for @history.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get history;

  /// No description provided for @noRooms.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kamar.'**
  String get noRooms;

  /// No description provided for @roomLockedStarterLimit.
  ///
  /// In id, this message translates to:
  /// **'Kamar ini terkunci (Limit Starter 2). Silakan upgrade ke PRO!'**
  String get roomLockedStarterLimit;

  /// No description provided for @editBookingFor.
  ///
  /// In id, this message translates to:
  /// **'Edit Booking: {catName}'**
  String editBookingFor(String catName);

  /// No description provided for @checkInDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Masuk'**
  String get checkInDate;

  /// No description provided for @checkOutDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Keluar'**
  String get checkOutDate;

  /// No description provided for @deleteBooking.
  ///
  /// In id, this message translates to:
  /// **'Hapus Booking'**
  String get deleteBooking;

  /// No description provided for @deleteBookingConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Booking?'**
  String get deleteBookingConfirmTitle;

  /// No description provided for @deleteBookingConfirmDesc.
  ///
  /// In id, this message translates to:
  /// **'Tindakan ini tidak dapat dibatalkan.'**
  String get deleteBookingConfirmDesc;

  /// No description provided for @viewBilling.
  ///
  /// In id, this message translates to:
  /// **'Lihat Tagihan'**
  String get viewBilling;

  /// No description provided for @noActiveBilling.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tagihan aktif.'**
  String get noActiveBilling;

  /// No description provided for @noBilling.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tagihan.'**
  String get noBilling;

  /// No description provided for @noHistory.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat.'**
  String get noHistory;

  /// No description provided for @countCats.
  ///
  /// In id, this message translates to:
  /// **'{count} Kucing'**
  String countCats(int count);

  /// No description provided for @addRoom.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kamar'**
  String get addRoom;

  /// No description provided for @editRoom.
  ///
  /// In id, this message translates to:
  /// **'Edit Kamar'**
  String get editRoom;

  /// No description provided for @roomName.
  ///
  /// In id, this message translates to:
  /// **'Nama Kamar'**
  String get roomName;

  /// No description provided for @pricePerNight.
  ///
  /// In id, this message translates to:
  /// **'Harga per Malam'**
  String get pricePerNight;

  /// No description provided for @capacity.
  ///
  /// In id, this message translates to:
  /// **'Kapasitas'**
  String get capacity;

  /// No description provided for @overdue.
  ///
  /// In id, this message translates to:
  /// **'TERLAMBAT!'**
  String get overdue;

  /// No description provided for @occupied.
  ///
  /// In id, this message translates to:
  /// **'Terisi'**
  String get occupied;

  /// No description provided for @available.
  ///
  /// In id, this message translates to:
  /// **'Kosong'**
  String get available;

  /// No description provided for @locked.
  ///
  /// In id, this message translates to:
  /// **'Terkunci'**
  String get locked;

  /// No description provided for @roomCat.
  ///
  /// In id, this message translates to:
  /// **'Kamar/Kucing'**
  String get roomCat;

  /// No description provided for @paid.
  ///
  /// In id, this message translates to:
  /// **'Lunas / Lebih Bayar'**
  String get paid;

  /// No description provided for @remainingBilling.
  ///
  /// In id, this message translates to:
  /// **'Sisa Tagihan'**
  String get remainingBilling;

  /// No description provided for @now.
  ///
  /// In id, this message translates to:
  /// **'Sekarang'**
  String get now;

  /// No description provided for @running.
  ///
  /// In id, this message translates to:
  /// **'Berjalan...'**
  String get running;

  /// No description provided for @addOnCosts.
  ///
  /// In id, this message translates to:
  /// **'Biaya Tambahan'**
  String get addOnCosts;

  /// No description provided for @manageAddOns.
  ///
  /// In id, this message translates to:
  /// **'Kelola Add-on'**
  String get manageAddOns;

  /// No description provided for @downPayment.
  ///
  /// In id, this message translates to:
  /// **'Uang Muka (DP):'**
  String get downPayment;

  /// No description provided for @totalCostEst.
  ///
  /// In id, this message translates to:
  /// **'Total Biaya (Est):'**
  String get totalCostEst;

  /// No description provided for @invoiceDp.
  ///
  /// In id, this message translates to:
  /// **'Invoice DP'**
  String get invoiceDp;

  /// No description provided for @checkOut.
  ///
  /// In id, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @noAddOns.
  ///
  /// In id, this message translates to:
  /// **'Belum ada item tambahan.'**
  String get noAddOns;

  /// No description provided for @updateTotalDp.
  ///
  /// In id, this message translates to:
  /// **'Update Total DP'**
  String get updateTotalDp;

  /// No description provided for @dpDistributeDesc.
  ///
  /// In id, this message translates to:
  /// **'DP ini akan dibagi rata ke semua booking dalam grup ini.'**
  String get dpDistributeDesc;

  /// No description provided for @totalDp.
  ///
  /// In id, this message translates to:
  /// **'Total DP'**
  String get totalDp;

  /// No description provided for @confirmCheckout.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Check Out'**
  String get confirmCheckout;

  /// No description provided for @checkoutConfirmDesc.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan {count} booking untuk {ownerName}?'**
  String checkoutConfirmDesc(Object count, Object ownerName);

  /// No description provided for @totalLabel.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @selectCatRoom.
  ///
  /// In id, this message translates to:
  /// **'Pilih Kucing/Kamar'**
  String get selectCatRoom;

  /// No description provided for @itemNameExample.
  ///
  /// In id, this message translates to:
  /// **'Nama Item (Contoh: Whiskas)'**
  String get itemNameExample;

  /// No description provided for @price.
  ///
  /// In id, this message translates to:
  /// **'Harga'**
  String get price;

  /// No description provided for @addItem.
  ///
  /// In id, this message translates to:
  /// **'Tambah Item'**
  String get addItem;

  /// No description provided for @customerDeposit.
  ///
  /// In id, this message translates to:
  /// **'Deposit Pelanggan'**
  String get customerDeposit;

  /// No description provided for @topUp.
  ///
  /// In id, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @searchNamePhone.
  ///
  /// In id, this message translates to:
  /// **'Cari Nama / No HP'**
  String get searchNamePhone;

  /// No description provided for @noDepositData.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data deposit.'**
  String get noDepositData;

  /// No description provided for @noName.
  ///
  /// In id, this message translates to:
  /// **'Tanpa Nama'**
  String get noName;

  /// No description provided for @topUpBalance.
  ///
  /// In id, this message translates to:
  /// **'Top Up Saldo'**
  String get topUpBalance;

  /// No description provided for @newDeposit.
  ///
  /// In id, this message translates to:
  /// **'Deposit Baru'**
  String get newDeposit;

  /// No description provided for @phoneId.
  ///
  /// In id, this message translates to:
  /// **'No. HP (ID)'**
  String get phoneId;

  /// No description provided for @topUpAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah Top Up'**
  String get topUpAmount;

  /// No description provided for @notesOptional.
  ///
  /// In id, this message translates to:
  /// **'Catatan (Opsional)'**
  String get notesOptional;

  /// No description provided for @historyPrefix.
  ///
  /// In id, this message translates to:
  /// **'Riwayat: {name}'**
  String historyPrefix(Object name);

  /// No description provided for @currentBalanceValue.
  ///
  /// In id, this message translates to:
  /// **'Saldo Saat Ini: {balance}'**
  String currentBalanceValue(Object balance);

  /// No description provided for @ownerPhoneValue.
  ///
  /// In id, this message translates to:
  /// **'HP: {phone}'**
  String ownerPhoneValue(Object phone);

  /// No description provided for @shareHistoryStatement.
  ///
  /// In id, this message translates to:
  /// **'Bagikan Riwayat (Rekening Koran)'**
  String get shareHistoryStatement;

  /// No description provided for @noTransactions.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi.'**
  String get noTransactions;

  /// No description provided for @transTopUp.
  ///
  /// In id, this message translates to:
  /// **'Top Up'**
  String get transTopUp;

  /// No description provided for @transGroomingPayment.
  ///
  /// In id, this message translates to:
  /// **'Bayar Grooming'**
  String get transGroomingPayment;

  /// No description provided for @transHotelPayment.
  ///
  /// In id, this message translates to:
  /// **'Bayar Hotel'**
  String get transHotelPayment;

  /// No description provided for @transAdjustment.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian'**
  String get transAdjustment;

  /// No description provided for @transRefund.
  ///
  /// In id, this message translates to:
  /// **'Refund'**
  String get transRefund;

  /// No description provided for @adjustBalance.
  ///
  /// In id, this message translates to:
  /// **'Adjust Saldo'**
  String get adjustBalance;

  /// No description provided for @newBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Baru'**
  String get newBalance;

  /// No description provided for @adjustmentReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan (Opsional)'**
  String get adjustmentReason;

  /// No description provided for @deleteDeposit.
  ///
  /// In id, this message translates to:
  /// **'Hapus Deposit'**
  String get deleteDeposit;

  /// No description provided for @deleteDepositConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus deposit {name}? Semua riwayat transaksi akan ikut terhapus. Data tidak bisa dikembalikan.'**
  String deleteDepositConfirm(Object name);

  /// No description provided for @topUpAgain.
  ///
  /// In id, this message translates to:
  /// **'Top Up Lagi'**
  String get topUpAgain;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @sameOwnerOnly.
  ///
  /// In id, this message translates to:
  /// **'Hanya bisa memilih transaksi dari pemilik yang sama ({owner})'**
  String sameOwnerOnly(Object owner);

  /// No description provided for @financialReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan Keuangan'**
  String get financialReport;

  /// No description provided for @printReport.
  ///
  /// In id, this message translates to:
  /// **'Cetak Laporan'**
  String get printReport;

  /// No description provided for @ownerSameHint.
  ///
  /// In id, this message translates to:
  /// **'Owner: {owner} — hanya transaksi dari owner ini'**
  String ownerSameHint(Object owner);

  /// No description provided for @incomeDetailsHeader.
  ///
  /// In id, this message translates to:
  /// **'Rincian Pemasukan'**
  String get incomeDetailsHeader;

  /// No description provided for @transactionHistoryHeader.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Transaksi'**
  String get transactionHistoryHeader;

  /// No description provided for @longPressCombineHint.
  ///
  /// In id, this message translates to:
  /// **'Tekan lama untuk memilih & cetak invoice gabungan (1 owner)'**
  String get longPressCombineHint;

  /// No description provided for @groomingLabel.
  ///
  /// In id, this message translates to:
  /// **'Grooming'**
  String get groomingLabel;

  /// No description provided for @hotelLabel.
  ///
  /// In id, this message translates to:
  /// **'Hotel'**
  String get hotelLabel;

  /// No description provided for @addExpense.
  ///
  /// In id, this message translates to:
  /// **'Tambah Pengeluaran'**
  String get addExpense;

  /// No description provided for @description.
  ///
  /// In id, this message translates to:
  /// **'Keterangan'**
  String get description;

  /// No description provided for @amountRp.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get amountRp;

  /// No description provided for @generalCategory.
  ///
  /// In id, this message translates to:
  /// **'Umum'**
  String get generalCategory;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Data'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteExpenseConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus pengeluaran ini?'**
  String get deleteExpenseConfirm;

  /// No description provided for @roomDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Kamar'**
  String get roomDetail;

  /// No description provided for @roomNotFound.
  ///
  /// In id, this message translates to:
  /// **'Kamar tidak ditemukan.'**
  String get roomNotFound;

  /// No description provided for @capacityLabel.
  ///
  /// In id, this message translates to:
  /// **'Kapasitas: {count}'**
  String capacityLabel(Object count);

  /// No description provided for @pricePerNightLabel.
  ///
  /// In id, this message translates to:
  /// **'{price} / malam'**
  String pricePerNightLabel(Object price);

  /// No description provided for @statusOccupied.
  ///
  /// In id, this message translates to:
  /// **'Status: TERISI'**
  String get statusOccupied;

  /// No description provided for @statusAvailable.
  ///
  /// In id, this message translates to:
  /// **'Status: KOSONG'**
  String get statusAvailable;

  /// No description provided for @checkInButton.
  ///
  /// In id, this message translates to:
  /// **'Check In'**
  String get checkInButton;

  /// No description provided for @checkOutButton.
  ///
  /// In id, this message translates to:
  /// **'Check Out'**
  String get checkOutButton;

  /// No description provided for @checkInRoom.
  ///
  /// In id, this message translates to:
  /// **'Check In (Masuk Kamar)'**
  String get checkInRoom;

  /// No description provided for @updatePrice.
  ///
  /// In id, this message translates to:
  /// **'Update Harga'**
  String get updatePrice;

  /// No description provided for @catNotRegistered.
  ///
  /// In id, this message translates to:
  /// **'Kucing belum terdaftar?'**
  String get catNotRegistered;

  /// No description provided for @cancelAdd.
  ///
  /// In id, this message translates to:
  /// **'Batal Tambah'**
  String get cancelAdd;

  /// No description provided for @addNew.
  ///
  /// In id, this message translates to:
  /// **'Tambah Baru'**
  String get addNew;

  /// No description provided for @newCatData.
  ///
  /// In id, this message translates to:
  /// **'Data Kucing Baru'**
  String get newCatData;

  /// No description provided for @ownerNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Pemilik'**
  String get ownerNameLabel;

  /// No description provided for @catAddedSuccess.
  ///
  /// In id, this message translates to:
  /// **'Kucing berhasil ditambahkan!'**
  String get catAddedSuccess;

  /// No description provided for @selectDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih Tanggal'**
  String get selectDate;

  /// No description provided for @confirmCheckOut.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Check Out'**
  String get confirmCheckOut;

  /// No description provided for @finishBookingConfirm.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan booking ini? Kamar akan menjadi kosong.'**
  String get finishBookingConfirm;

  /// No description provided for @manageServices.
  ///
  /// In id, this message translates to:
  /// **'Manajemen Layanan'**
  String get manageServices;

  /// No description provided for @noServices.
  ///
  /// In id, this message translates to:
  /// **'Belum ada layanan.'**
  String get noServices;

  /// No description provided for @tapPlusAddService.
  ///
  /// In id, this message translates to:
  /// **'Tap tombol + untuk menambah layanan.'**
  String get tapPlusAddService;

  /// No description provided for @editService.
  ///
  /// In id, this message translates to:
  /// **'Edit Layanan'**
  String get editService;

  /// No description provided for @addService.
  ///
  /// In id, this message translates to:
  /// **'Tambah Layanan'**
  String get addService;

  /// No description provided for @serviceName.
  ///
  /// In id, this message translates to:
  /// **'Nama Layanan'**
  String get serviceName;

  /// No description provided for @invalidPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga tidak valid'**
  String get invalidPrice;

  /// No description provided for @requiredField.
  ///
  /// In id, this message translates to:
  /// **'Kolom ini wajib diisi'**
  String get requiredField;

  /// No description provided for @deleteService.
  ///
  /// In id, this message translates to:
  /// **'Hapus Layanan'**
  String get deleteService;

  /// No description provided for @deleteServiceConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus \"{name}\" secara permanen?'**
  String deleteServiceConfirm(Object name);

  /// No description provided for @readImageFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal baca file: bytes kosong (0 bytes)'**
  String get readImageFailed;

  /// No description provided for @compressionFailed.
  ///
  /// In id, this message translates to:
  /// **'Kompresi gagal: {error}'**
  String compressionFailed(Object error);

  /// No description provided for @compressionResultEmpty.
  ///
  /// In id, this message translates to:
  /// **'Hasil kompresi kosong (null/empty)'**
  String get compressionResultEmpty;

  /// No description provided for @appearance.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get appearance;

  /// No description provided for @followSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti Sistem'**
  String get followSystem;

  /// No description provided for @lightMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Terang'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @shopBranding.
  ///
  /// In id, this message translates to:
  /// **'Branding Toko'**
  String get shopBranding;

  /// No description provided for @invoiceLogo.
  ///
  /// In id, this message translates to:
  /// **'Logo Invoice'**
  String get invoiceLogo;

  /// No description provided for @logoCustomizationDesc.
  ///
  /// In id, this message translates to:
  /// **'Sesuaikan logo untuk struk/invoice Anda.'**
  String get logoCustomizationDesc;

  /// No description provided for @upgradeToProForLogo.
  ///
  /// In id, this message translates to:
  /// **'Upgrade ke PRO untuk ganti logo.'**
  String get upgradeToProForLogo;

  /// No description provided for @proFeatureUpgradeRequired.
  ///
  /// In id, this message translates to:
  /// **'Fitur khusus PRO! Silakan upgrade langganan.'**
  String get proFeatureUpgradeRequired;

  /// No description provided for @businessInformation.
  ///
  /// In id, this message translates to:
  /// **'Informasi Bisnis'**
  String get businessInformation;

  /// No description provided for @businessName.
  ///
  /// In id, this message translates to:
  /// **'Nama Bisnis'**
  String get businessName;

  /// No description provided for @businessPhone.
  ///
  /// In id, this message translates to:
  /// **'Nomor Telepon'**
  String get businessPhone;

  /// No description provided for @invoiceHeaderHint.
  ///
  /// In id, this message translates to:
  /// **'Untuk header struk/invoice'**
  String get invoiceHeaderHint;

  /// No description provided for @businessAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat Bisnis'**
  String get businessAddress;

  /// No description provided for @shopIdLowerHint.
  ///
  /// In id, this message translates to:
  /// **'Gunakan huruf kecil, tanpa spasi'**
  String get shopIdLowerHint;

  /// No description provided for @shopIdChangedSyncAccount.
  ///
  /// In id, this message translates to:
  /// **'ID Toko berubah. Cek menu Akun untuk Sinkronisasi.'**
  String get shopIdChangedSyncAccount;

  /// No description provided for @changesSaved.
  ///
  /// In id, this message translates to:
  /// **'Perubahan Disimpan'**
  String get changesSaved;

  /// No description provided for @saveChanges.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get saveChanges;

  /// No description provided for @notificationSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Notifikasi'**
  String get notificationSettings;

  /// No description provided for @enableReminders.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Pengingat'**
  String get enableReminders;

  /// No description provided for @h1NotificationActive.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi H-1 aktif'**
  String get h1NotificationActive;

  /// No description provided for @notificationsDisabled.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi dimatikan'**
  String get notificationsDisabled;

  /// No description provided for @reminderTimeH1.
  ///
  /// In id, this message translates to:
  /// **'Waktu Pengingat (H-1)'**
  String get reminderTimeH1;

  /// No description provided for @wibTimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jam: {time} WIB'**
  String wibTimeLabel(Object time);

  /// No description provided for @setReminderTime.
  ///
  /// In id, this message translates to:
  /// **'Atur Waktu Pengingat'**
  String get setReminderTime;

  /// No description provided for @reminderTimeDesc.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi akan muncul 1 hari sebelum jadwal (H-1) pada jam yang ditentukan.'**
  String get reminderTimeDesc;

  /// No description provided for @hour023.
  ///
  /// In id, this message translates to:
  /// **'Jam (0-23)'**
  String get hour023;

  /// No description provided for @minute059.
  ///
  /// In id, this message translates to:
  /// **'Menit (0-59)'**
  String get minute059;

  /// No description provided for @invalidNumber.
  ///
  /// In id, this message translates to:
  /// **'Masukkan angka yang valid'**
  String get invalidNumber;

  /// No description provided for @hourLimit.
  ///
  /// In id, this message translates to:
  /// **'Jam harus 0-23'**
  String get hourLimit;

  /// No description provided for @minuteLimit.
  ///
  /// In id, this message translates to:
  /// **'Menit harus 0-59'**
  String get minuteLimit;

  /// No description provided for @reminderTimeSaved.
  ///
  /// In id, this message translates to:
  /// **'Waktu pengingat disimpan!'**
  String get reminderTimeSaved;

  /// No description provided for @security.
  ///
  /// In id, this message translates to:
  /// **'Keamanan'**
  String get security;

  /// No description provided for @appLockPin.
  ///
  /// In id, this message translates to:
  /// **'Kunci Aplikasi (PIN)'**
  String get appLockPin;

  /// No description provided for @pinActive.
  ///
  /// In id, this message translates to:
  /// **'PIN Aktif'**
  String get pinActive;

  /// No description provided for @lockDisabled.
  ///
  /// In id, this message translates to:
  /// **'Kunci dimatikan'**
  String get lockDisabled;

  /// No description provided for @lockDisabledMsg.
  ///
  /// In id, this message translates to:
  /// **'Kunci Aplikasi Dimatikan'**
  String get lockDisabledMsg;

  /// No description provided for @biometricFingerprint.
  ///
  /// In id, this message translates to:
  /// **'Biometrik (Sidik Jari)'**
  String get biometricFingerprint;

  /// No description provided for @active.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In id, this message translates to:
  /// **'Tidak Aktif'**
  String get inactive;

  /// No description provided for @setNewPin6Digit.
  ///
  /// In id, this message translates to:
  /// **'Atur PIN Baru (6 Digit)'**
  String get setNewPin6Digit;

  /// No description provided for @newPin.
  ///
  /// In id, this message translates to:
  /// **'PIN Baru'**
  String get newPin;

  /// No description provided for @confirmPin.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi PIN'**
  String get confirmPin;

  /// No description provided for @pinMustBe6Digit.
  ///
  /// In id, this message translates to:
  /// **'PIN harus 6 digit'**
  String get pinMustBe6Digit;

  /// No description provided for @pinMismatch.
  ///
  /// In id, this message translates to:
  /// **'PIN tidak cocok'**
  String get pinMismatch;

  /// No description provided for @pinSuccessSet.
  ///
  /// In id, this message translates to:
  /// **'PIN Berhasil Diatur!'**
  String get pinSuccessSet;

  /// No description provided for @aboutApp.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get aboutApp;

  /// No description provided for @versionStable.
  ///
  /// In id, this message translates to:
  /// **'Versi 13.0 (Stable)'**
  String get versionStable;

  /// No description provided for @thankYouUsingApp.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih telah menggunakan aplikasi ini.'**
  String get thankYouUsingApp;

  /// No description provided for @loyaltyTracker.
  ///
  /// In id, this message translates to:
  /// **'Loyalty Tracker'**
  String get loyaltyTracker;

  /// No description provided for @statusWaiting.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get statusWaiting;

  /// No description provided for @statusBathing.
  ///
  /// In id, this message translates to:
  /// **'Mandi'**
  String get statusBathing;

  /// No description provided for @statusDrying.
  ///
  /// In id, this message translates to:
  /// **'Pengeringan'**
  String get statusDrying;

  /// No description provided for @statusFinishing.
  ///
  /// In id, this message translates to:
  /// **'Finishing'**
  String get statusFinishing;

  /// No description provided for @statusPickupReady.
  ///
  /// In id, this message translates to:
  /// **'Siap Jemput'**
  String get statusPickupReady;

  /// No description provided for @statusDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get statusDone;

  /// No description provided for @deviceWebBrowser.
  ///
  /// In id, this message translates to:
  /// **'Browser Web'**
  String get deviceWebBrowser;

  /// No description provided for @deviceAndroid.
  ///
  /// In id, this message translates to:
  /// **'Perangkat Android'**
  String get deviceAndroid;

  /// No description provided for @deviceIosOther.
  ///
  /// In id, this message translates to:
  /// **'Perangkat iOS/Lainnya'**
  String get deviceIosOther;

  /// No description provided for @changePassword.
  ///
  /// In id, this message translates to:
  /// **'Ubah Password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In id, this message translates to:
  /// **'Password Lama'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In id, this message translates to:
  /// **'Password Baru'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Password Baru'**
  String get confirmNewPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In id, this message translates to:
  /// **'Password minimal 6 karakter'**
  String get passwordMinLength;

  /// No description provided for @passwordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Password baru tidak cocok'**
  String get passwordMismatch;

  /// No description provided for @wrongOldPassword.
  ///
  /// In id, this message translates to:
  /// **'Password lama salah'**
  String get wrongOldPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In id, this message translates to:
  /// **'Password berhasil diubah!'**
  String get passwordChanged;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengubah password'**
  String get passwordChangeFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'ms':
      return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
