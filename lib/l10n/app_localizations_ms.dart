// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appName => 'Data Groomer App';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Padam';

  @override
  String get edit => 'Sunting';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get success => 'Berjaya';

  @override
  String get error => 'Ralat';

  @override
  String get loading => 'Memuatkan...';

  @override
  String get search => 'Cari';

  @override
  String get settings => 'Tetapan';

  @override
  String get account => 'Akaun';

  @override
  String get recentActivity => 'Aktiviti Terkini';

  @override
  String get catList => 'Senarai Kucing';

  @override
  String get businessNamePlaceholder => 'Nama Perniagaan';

  @override
  String get goodMorning => 'Selamat Pagi';

  @override
  String get goodAfternoon => 'Selamat Tengah Hari';

  @override
  String get goodEvening => 'Selamat Petang';

  @override
  String get goodNight => 'Selamat Malam';

  @override
  String get netProfit => 'Untung Bersih';

  @override
  String get income => 'Pendapatan';

  @override
  String get expense => 'Perbelanjaan';

  @override
  String get newSession => 'Sesi Baru';

  @override
  String get cats => 'Kucing';

  @override
  String get hotel => 'Hotel';

  @override
  String get booking => 'Tempahan';

  @override
  String get deposit => 'Deposit';

  @override
  String get services => 'Servis';

  @override
  String get calendar => 'Kalendar';

  @override
  String get activeSessions => 'Sesi Aktif';

  @override
  String get processingNow => 'Sedang diproses sekarang';

  @override
  String get seeAll => 'Lihat Semua';

  @override
  String get groomingSchedule => 'Jadual Grooming';

  @override
  String get noReschedule => 'Tiada jadual semula';

  @override
  String get owner => 'Pemilik';

  @override
  String sessionsCountLabel(int count) {
    return '$count sesi';
  }

  @override
  String daysAgoLabel(int days) {
    return '$days hari lepas';
  }

  @override
  String get errEmptyShopIdPassword => 'Shop ID dan Kata Laluan mesti diisi';

  @override
  String get errShopIdNotFound => 'Shop ID tidak dijumpai';

  @override
  String errDeviceLimit(int count) {
    return 'Log masuk ditolak: Had peranti dicapai ($count peranti).\\nSila naik taraf ke PRO untuk akses lebih.';
  }

  @override
  String get errWrongPassword => 'Kata laluan salah';

  @override
  String get errNetwork => 'Gagal menyambung ke pelayan';

  @override
  String get errAllFieldsRequired => 'Semua ruangan mesti diisi';

  @override
  String get errInvalidShopId =>
      'Shop ID tidak boleh mengandungi ruang kosong atau /';

  @override
  String get errPasswordMinLength => 'Kata laluan minimum 6 aksara';

  @override
  String get errPasswordMismatch => 'Kata laluan tidak sepadan';

  @override
  String errShopIdTaken(String shopId) {
    return 'Shop ID \"$shopId\" sudah digunakan, cuba yang lain';
  }

  @override
  String errCreateAccount(String error) {
    return 'Gagal mencipta akaun: $error';
  }

  @override
  String msgForgotPwdWithId(String shopId) {
    return 'Helo, saya terlupa kata laluan SmartGroomer. Shop ID saya: $shopId';
  }

  @override
  String get msgForgotPwd => 'Helo, saya terlupa kata laluan SmartGroomer.';

  @override
  String get createAccount => 'Cipta Akaun Baru';

  @override
  String get signInToAccount => 'Log Masuk Akaun';

  @override
  String get shopIdHint => 'cth: jeni_cathouse';

  @override
  String get password => 'Kata Laluan';

  @override
  String get repeatPassword => 'Ulangi Kata Laluan';

  @override
  String get register => 'Daftar';

  @override
  String get login => 'Log Masuk';

  @override
  String get alreadyHaveAccount => 'Sudah mempunyai akaun? Log Masuk';

  @override
  String get dontHaveAccount => 'Belum ada akaun? Cipta Baru';

  @override
  String get forgotPasswordAdmin => 'Lupa Kata Laluan? Hubungi Admin';

  @override
  String get accountAndBackup => 'Akaun & Sandaran';

  @override
  String get shopSync => 'Penyegerakan Kedai';

  @override
  String get shopConnected => 'Kedai Disambungkan';

  @override
  String get connectShop => 'Sambung Kedai';

  @override
  String shopIdValue(String shopId) {
    return 'ID: $shopId';
  }

  @override
  String get notConnectedToShop => 'Belum disambungkan ke kedai';

  @override
  String get subscriptionStatus => 'Status Langganan';

  @override
  String get cloudBackupRestore => 'Sandaran & Pemulihan Awan';

  @override
  String get connectShopFirstForCloud =>
      'Sambungkan ke Kedai dahulu untuk menggunakan ciri Sandaran Awan.';

  @override
  String get backupData => 'Sandarkan Data';

  @override
  String get backupDataDesc => 'Muat naik semua data tempatan ke Awan';

  @override
  String get uploadDataNow => 'Muat naik data sekarang?';

  @override
  String get dataWillBeOverwrittenProceed =>
      'Data tempatan akan ditimpa! Teruskan?';

  @override
  String get restoreData => 'Pulihkan Data';

  @override
  String get restoreDataDesc => 'Muat turun dan timpa data tempatan dari Awan';

  @override
  String get localBackupRestore => 'Sandaran & Pemulihan Tempatan';

  @override
  String get offlineBackupZip => 'Sandaran Luar Talian (ZIP)';

  @override
  String get offlineBackupZipDesc =>
      'Simpan pangkalan data & gambar ke fail ZIP';

  @override
  String get offlineRestoreZip => 'Pemulihan Luar Talian (ZIP)';

  @override
  String get offlineRestoreZipDesc => 'Pulihkan data dari fail ZIP';

  @override
  String get restoreOffline => 'Pulihkan Luar Talian';

  @override
  String get shopId => 'Shop ID';

  @override
  String get secretKey => 'Kunci Rahsia';

  @override
  String get createNew => 'Cipta Baru';

  @override
  String get invalidIdOrKey =>
      'ID atau Kunci salah, atau periksa sambungan internet anda.';

  @override
  String get connect => 'Sambung';

  @override
  String get createNewShop => 'Cipta Kedai Baru';

  @override
  String get createNewShopDesc =>
      'ID dan Kunci Rahsia akan dijana secara automatik. Anda juga boleh menetapkan ID sendiri (pilihan). Data tempatan semasa akan dimuat naik ke awan.';

  @override
  String get shopName => 'Nama Kedai';

  @override
  String get customShopIdOptional => 'ID Kedai Tersuai (Pilihan)';

  @override
  String get customShopIdHint => 'cth: JENICATHOUSE';

  @override
  String shopCreatedSuccess(String shopId) {
    return 'Kedai berjaya dicipta! ID: $shopId';
  }

  @override
  String get shopCreatedFail => 'Gagal mencipta kedai. Periksa sambungan anda.';

  @override
  String get createAndUpload => 'Cipta & Muat Naik';

  @override
  String get restoreDataPrompt => 'Pulihkan Data?';

  @override
  String get restoreDataPromptDesc =>
      'Berjaya disambungkan. Adakah anda ingin memuat turun & memulihkan data dari awan sekarang?';

  @override
  String get later => 'Nanti Saja';

  @override
  String get restoreSuccess => 'Pemulihan berjaya! Data sedang dikemas kini.';

  @override
  String get restoreFail =>
      'Pemulihan gagal! Periksa sambungan atau Kunci Rahsia anda.';

  @override
  String get yesRestore => 'Ya, Pulihkan';

  @override
  String get disconnectShopPrompt => 'Putuskan Hubungan Kedai?';

  @override
  String get disconnectShopDesc =>
      'Ciri sandaran awan dan penyegerakan akan dinyahaktifkan. Data tempatan kekal selamat.';

  @override
  String get shopConnectionDisconnected => 'Sambungan kedai diputuskan';

  @override
  String get disconnect => 'Putuskan Hubungan';

  @override
  String get yesProceed => 'Ya, Teruskan';

  @override
  String get hiddenForSecurity => '•••••••• (Tersembunyi untuk keselamatan)';

  @override
  String get checkingStatus => 'Menyemak status...';

  @override
  String statusValue(String plan) {
    return 'Status: $plan';
  }

  @override
  String get checkStatus => 'Semak Status';

  @override
  String validUntilValue(String date) {
    return 'Sah Sehingga: $date';
  }

  @override
  String deviceLimitValue(int count) {
    return 'Had Peranti: $count';
  }

  @override
  String deviceIdValue(String deviceId) {
    return 'ID Peranti: $deviceId';
  }

  @override
  String upgradeToProWhatsapp(String shopId) {
    return 'Helo Admin, saya ingin menaik taraf aplikasi DataGrooming saya ke PRO. ID Kedai: $shopId';
  }

  @override
  String get upgradeToPro => 'Naik Taraf ke PRO';

  @override
  String get planFree => 'PERCUMA';

  @override
  String get home => 'Laman Utama';

  @override
  String get activity => 'Aktiviti';

  @override
  String get financial => 'Kewangan';

  @override
  String get quickAction => 'Tindakan Pantas';

  @override
  String get hotelCheckIn => 'Daftar Masuk Hotel';

  @override
  String catListCount(int count) {
    return 'Senarai Kucing ($count)';
  }

  @override
  String get hideArchived => 'Sembunyikan Arkib';

  @override
  String get viewArchived => 'Lihat yang Diarkibkan';

  @override
  String get searchCatOrOwner => 'Cari Kucing / Pemilik';

  @override
  String get noCatsMatchSearch => 'Tiada kucing yang sepadan dengan carian.';

  @override
  String get noCatDataYet => 'Tiada data kucing lagi.';

  @override
  String get tryAnotherKeyword => 'Cuba kata kunci lain.';

  @override
  String get tapPlusToAddCat => 'Ketik butang + untuk menambah kucing.';

  @override
  String get dataLockedStarterLimit =>
      'Data ini dikunci (Had Starter 15). Sila naik taraf ke PRO!';

  @override
  String get starterLimit15CatsReached =>
      'Had Starter 15 kucing telah dicapai! Sila naik taraf ke PRO.';

  @override
  String get archiveCatPrompt => 'Arkibkan Kucing?';

  @override
  String archiveCatDesc(String catName) {
    return '\"$catName\" mempunyai sejarah transaksi dan tidak boleh dipadamkan. Dengan mengarkibkan, data kewangan kekal selamat tetapi kucing tidak akan muncul lagi dalam senarai dan peringatan.';
  }

  @override
  String get archive => 'Arkibkan';

  @override
  String catArchivedSuccess(String catName) {
    return '$catName telah diarkibkan';
  }

  @override
  String get unarchiveCatPrompt => 'Aktifkan Semula?';

  @override
  String unarchiveCatDesc(String catName) {
    return 'Adakah anda ingin memulihkan \"$catName\"? Kucing ini akan muncul kembali dalam senarai aktif.';
  }

  @override
  String get unarchive => 'Aktifkan';

  @override
  String catUnarchivedSuccess(String catName) {
    return '$catName telah diaktifkan semula';
  }

  @override
  String get deleteFailedHasHistory =>
      'Pemadaman gagal: Kucing ini mempunyai sejarah. Gunakan ciri Arkib.';

  @override
  String get deleteCatPrompt => 'Padam Kucing?';

  @override
  String deleteCatDesc(String catName) {
    return 'Adakah anda pasti ingin memadamkan \"$catName\"? Semua sejarah grooming juga akan dipadamkan.';
  }

  @override
  String catDeletedSuccess(String catName) {
    return '$catName telah dipadam';
  }

  @override
  String get catNotFound => 'Kucing tidak dijumpai.';

  @override
  String groomingHistoryCount(int count) {
    return 'Sejarah Grooming ($count)';
  }

  @override
  String get noGroomingHistoryYet => 'Tiada sejarah grooming lagi.';

  @override
  String get information => 'Maklumat';

  @override
  String get phone => 'Telefon';

  @override
  String get furColor => 'Warna Bulu';

  @override
  String get eyeColor => 'Warna Mata';

  @override
  String get weight => 'Berat';

  @override
  String get sterile => 'Steril';

  @override
  String get isSterileYes => 'Sudah Steril';

  @override
  String get isSterileNo => 'Belum Steril';

  @override
  String get loyaltyCompleted => 'Tugasan Kesetiaan Selesai! 🎉';

  @override
  String groomingReportShare(
    String catName,
    String date,
    String cost,
    String notes,
  ) {
    return 'Laporan Grooming\nKucing: $catName\nTarikh: $date\nKos: $cost\nNota: $notes';
  }

  @override
  String get chooseProfilePhoto => 'Pilih Foto Profil';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeri';

  @override
  String get editCat => 'Edit Kucing';

  @override
  String get addCat => 'Tambah Kucing';

  @override
  String get catInfo => 'Maklumat Kucing';

  @override
  String get catNameLabel => 'Nama Kucing';

  @override
  String get weightKg => 'Berat (kg)';

  @override
  String get gender => 'Jantina';

  @override
  String get male => 'Jantan';

  @override
  String get female => 'Betina';

  @override
  String get yesSterilized => 'Ya, sudah steril';

  @override
  String get notSterilizedYet => 'Belum steril';

  @override
  String get ownerInfo => 'Maklumat Pemilik';

  @override
  String get ownerPhoneLabel => 'No. Telp Pemilik';

  @override
  String get warning => 'Amaran';

  @override
  String get permanentWarningNote => 'Nota Amaran Kekal';

  @override
  String get warningNoteExample => 'Contoh: Agresif, Jantung Lemah';

  @override
  String get limitReached15 => 'HAD DICAPAI (15 Ekor)';

  @override
  String get freeVersionUpgradeToPro =>
      'Anda menggunakan versi Percuma. Sila naik taraf ke PRO untuk menambah data tanpa had.';

  @override
  String get updateCat => 'Kemas kini Kucing';

  @override
  String get saveCat => 'Simpan Kucing';

  @override
  String fieldRequired(String field) {
    return '$field wajib diisi';
  }

  @override
  String enterField(String field) {
    return 'Masukkan $field';
  }

  @override
  String get ownerName => 'Nama Pemilik';

  @override
  String get ownerNameRequired => 'Nama Pemilik wajib diisi';

  @override
  String get searchOrEnterOwnerName => 'Cari atau masukkan nama pemilik';

  @override
  String onlySelectSameOwnerSession(String ownerName) {
    return 'Hanya boleh pilih sesi daripada pemilik yang sama ($ownerName)';
  }

  @override
  String printFailed(String error) {
    return 'Gagal mencetak: $error';
  }

  @override
  String selectedCount(int count) {
    return '$count dipilih';
  }

  @override
  String selectAllOwner(String ownerName) {
    return 'Pilih Semua (pemilik $ownerName)';
  }

  @override
  String get printCombinedInvoiceBtn => 'Cetak Invois Gabungan';

  @override
  String get sessionHistoryTitle => 'Sejarah Sesi';

  @override
  String get searchSession => 'Cari sesi...';

  @override
  String ownerOnlySessionWarning(String ownerName) {
    return 'Pemilik: $ownerName — hanya sesi dari pemilik ini yang boleh dipilih';
  }

  @override
  String get noSessionsYet => 'Belum ada sesi.';

  @override
  String get notFound => 'Tidak dijumpai.';

  @override
  String get tapPlusButtonInCatDetail => 'Ketik butang + di butiran kucing.';

  @override
  String get sessionStarted => 'Sesi bermula! Masuk dalam barisan.';

  @override
  String get groomingCheckIn => 'Daftar Masuk Grooming';

  @override
  String get startNewSession => 'Mula Sesi Baru';

  @override
  String get addNewCat => 'Tambah Kucing Baru';

  @override
  String get checkInStartQueue => 'Daftar Masuk (Mula Barisan)';

  @override
  String currentQueue(int count) {
    return 'Barisan Semasa ($count)';
  }

  @override
  String get noActiveQueue => 'Tiada barisan aktif.';

  @override
  String get unknownCat => 'Kucing Tidak Diketahui';

  @override
  String get setShopIdInSettings => 'Sila tetapkan ID Kedai di Tetapan';

  @override
  String get trackingTokenNotAvailable =>
      'Ralat: Token penjejakan tidak tersedia';

  @override
  String whatsappTrackingMessage(
    String ownerName,
    String catName,
    String link,
  ) {
    return 'Hai $ownerName 👋\n\nUntuk memantau proses grooming $catName sehingga tahap mana, boleh terus disemak di pautan ini ya:\n$link\n\nTerima kasih kerana mempercayai kami! 🐱✨';
  }

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String ownerLabel(String ownerName) {
    return 'Pemilik: $ownerName';
  }

  @override
  String get add => 'Tambah';

  @override
  String get breed => 'Baka';

  @override
  String get shareLink => 'Kongsi Pautan';

  @override
  String get bookingGrooming => 'Tempahan Grooming';

  @override
  String get noBookingSchedule => 'Tiada jadual tempahan.';

  @override
  String get addBooking => 'Tambah Tempahan';

  @override
  String get serviceType => 'Jenis Perkhidmatan';

  @override
  String get deleteSchedule => 'Padam Jadual';

  @override
  String get deleteScheduleConfirm => 'Padam jadual ini secara kekal?';

  @override
  String get confirm => 'Sahkan';

  @override
  String get cancelBooking => 'Batalkan';

  @override
  String get reschedule => 'Jadualkan Semula';

  @override
  String get dateLabel => 'Tarikh';

  @override
  String get serviceLabel => 'Perkhidmatan';

  @override
  String get whatsappReminder => 'Peringatan WhatsApp';

  @override
  String get checkIn => 'Daftar Masuk';

  @override
  String bookingOn(String date) {
    return 'Tempahan pada $date';
  }

  @override
  String get shortMonday => 'Isn';

  @override
  String get shortTuesday => 'Sel';

  @override
  String get shortWednesday => 'Rab';

  @override
  String get shortThursday => 'Kha';

  @override
  String get shortFriday => 'Jum';

  @override
  String get shortSaturday => 'Sab';

  @override
  String get shortSunday => 'Aha';

  @override
  String get noSchedule => 'Tiada jadual.';

  @override
  String get editSession => 'Edit Sesi';

  @override
  String get sessionNotFound => 'Sesi tidak dijumpai.';

  @override
  String get deleteSession => 'Padam Sesi';

  @override
  String get deleteSessionConfirm =>
      'Pasti ingin padam? Data tidak boleh dipulihkan.';

  @override
  String get status => 'Status';

  @override
  String get findings => 'Penemuan';

  @override
  String get treatments => 'Rawatan';

  @override
  String get notes => 'Nota';

  @override
  String get totalCost => 'Jumlah Kos';

  @override
  String get payFromDeposit => 'Bayar dari Deposit';

  @override
  String balanceStr(String balance) {
    return 'Baki: $balance';
  }

  @override
  String balanceNotEnoughDeduct(String deductedAmount) {
    return 'Baki tidak mencukupi, $deductedAmount akan dipotong';
  }

  @override
  String get sessionDetail => 'Butiran Sesi';

  @override
  String get printInvoice => 'Cetak Invois';

  @override
  String get catDataNotFound => 'Data kucing tidak dijumpai';

  @override
  String get token => 'Token';

  @override
  String get groomerNotes => 'Nota Groomer';

  @override
  String get unknown => 'Tidak Diketahui';

  @override
  String get monthJan => 'Januari';

  @override
  String get monthFeb => 'Februari';

  @override
  String get monthMar => 'Mac';

  @override
  String get monthApr => 'April';

  @override
  String get monthMay => 'Mei';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Julai';

  @override
  String get monthAug => 'Ogos';

  @override
  String get monthSep => 'September';

  @override
  String get monthOct => 'Oktober';

  @override
  String get monthNov => 'November';

  @override
  String get monthDec => 'Disember';

  @override
  String get statusScheduled => 'Dijadualkan';

  @override
  String get statusCompleted => 'Selesai';

  @override
  String get statusConfirmed => 'Disahkan';

  @override
  String get statusCancelled => 'Dibatalkan';

  @override
  String get hotelKucing => 'Hotel Kucing';

  @override
  String get roomStatus => 'Status Bilik';

  @override
  String get billing => 'Pengebilan';

  @override
  String get history => 'Sejarah';

  @override
  String get noRooms => 'Tiada bilik lagi.';

  @override
  String get roomLockedStarterLimit =>
      'Bilik ini dikunci (Had Starter 2). Sila naik taraf ke PRO!';

  @override
  String editBookingFor(String catName) {
    return 'Sunting Tempahan: $catName';
  }

  @override
  String get checkInDate => 'Tarikh Daftar Masuk';

  @override
  String get checkOutDate => 'Tarikh Daftar Keluar';

  @override
  String get deleteBooking => 'Padam Tempahan';

  @override
  String get deleteBookingConfirmTitle => 'Padam Tempahan?';

  @override
  String get deleteBookingConfirmDesc => 'Tindakan ini tidak boleh dibatalkan.';

  @override
  String get viewBilling => 'Lihat Pengebilan';

  @override
  String get noActiveBilling => 'Tiada pengebilan aktif.';

  @override
  String get noBilling => 'Tiada pengebilan.';

  @override
  String get noHistory => 'Tiada sejarah lagi.';

  @override
  String countCats(int count) {
    return '$count Kucing';
  }

  @override
  String get addRoom => 'Tambah Bilik';

  @override
  String get editRoom => 'Sunting Bilik';

  @override
  String get roomName => 'Nama Bilik';

  @override
  String get pricePerNight => 'Harga semalam';

  @override
  String get capacity => 'Kapasiti';

  @override
  String get overdue => 'TERLEWAT!';

  @override
  String get occupied => 'Penghuni';

  @override
  String get available => 'Kosong';

  @override
  String get locked => 'Dikunci';

  @override
  String get roomCat => 'Bilik/Kucing';

  @override
  String get paid => 'Dibayar / Terlebih Bayar';

  @override
  String get remainingBilling => 'Baki Pengebilan';

  @override
  String get now => 'Sekarang';

  @override
  String get running => 'Berjalan...';

  @override
  String get addOnCosts => 'Kos Tambahan';

  @override
  String get manageAddOns => 'Urus Tambahan';

  @override
  String get downPayment => 'Bayaran Pendahuluan (DP):';

  @override
  String get totalCostEst => 'Jumlah Kos (Anggaran):';

  @override
  String get invoiceDp => 'Invois DP';

  @override
  String get checkOut => 'Daftar Keluar';

  @override
  String get noAddOns => 'Tiada item tambahan.';

  @override
  String get updateTotalDp => 'Kemas Kini Jumlah DP';

  @override
  String get dpDistributeDesc =>
      'DP ini akan dibahagikan sama rata kepada semua tempahan dalam kumpulan ini.';

  @override
  String get totalDp => 'Jumlah DP';

  @override
  String get confirmCheckout => 'Sahkan Daftar Keluar';

  @override
  String checkoutConfirmDesc(Object count, Object ownerName) {
    return 'Lengkapkan $count tempahan untuk $ownerName?';
  }

  @override
  String get totalLabel => 'Jumlah';

  @override
  String get selectCatRoom => 'Pilih Kucing/Bilik';

  @override
  String get itemNameExample => 'Nama Item (Contoh: Whiskas)';

  @override
  String get price => 'Harga';

  @override
  String get addItem => 'Tambah Item';

  @override
  String get customerDeposit => 'Deposit Pelanggan';

  @override
  String get topUp => 'Tambah Nilai';

  @override
  String get searchNamePhone => 'Cari Nama / No HP';

  @override
  String get noDepositData => 'Tiada data deposit.';

  @override
  String get noName => 'Tiada Nama';

  @override
  String get topUpBalance => 'Tambah Nilai Baki';

  @override
  String get newDeposit => 'Deposit Baru';

  @override
  String get phoneId => 'No. HP (ID)';

  @override
  String get topUpAmount => 'Jumlah Tambah Nilai';

  @override
  String get notesOptional => 'Nota (Pilihan)';

  @override
  String historyPrefix(Object name) {
    return 'Sejarah: $name';
  }

  @override
  String currentBalanceValue(Object balance) {
    return 'Baki Semasa: $balance';
  }

  @override
  String ownerPhoneValue(Object phone) {
    return 'HP: $phone';
  }

  @override
  String get shareHistoryStatement => 'Kongsi Sejarah (Penyata Akaun)';

  @override
  String get noTransactions => 'Tiada transaksi dijumpai.';

  @override
  String get transTopUp => 'Tambah Nilai';

  @override
  String get transGroomingPayment => 'Pembayaran Grooming';

  @override
  String get transHotelPayment => 'Pembayaran Hotel';

  @override
  String get transAdjustment => 'Penyelarasan';

  @override
  String get transRefund => 'Bayaran Balik';

  @override
  String get adjustBalance => 'Laras Baki';

  @override
  String get newBalance => 'Baki Baru';

  @override
  String get adjustmentReason => 'Sebab (Pilihan)';

  @override
  String get deleteDeposit => 'Padam Deposit';

  @override
  String deleteDepositConfirm(Object name) {
    return 'Padam deposit untuk $name? Semua sejarah transaksi akan dipadamkan. Tindakan ini tidak boleh diundur.';
  }

  @override
  String get topUpAgain => 'Tambah Nilai Lagi';

  @override
  String get close => 'Tutup';

  @override
  String sameOwnerOnly(Object owner) {
    return 'Hanya boleh pilih transaksi daripada pemilik yang sama ($owner)';
  }

  @override
  String get financialReport => 'Laporan Kewangan';

  @override
  String get printReport => 'Cetak Laporan';

  @override
  String ownerSameHint(Object owner) {
    return 'Pemilik: $owner — hanya transaksi daripada pemilik ini';
  }

  @override
  String get incomeDetailsHeader => 'Butiran Pendapatan';

  @override
  String get transactionHistoryHeader => 'Sejarah Transaksi';

  @override
  String get longPressCombineHint =>
      'Tekan lama untuk memilih & cetak invois gabungan (1 pemilik)';

  @override
  String get groomingLabel => 'Grooming';

  @override
  String get hotelLabel => 'Hotel';

  @override
  String get addExpense => 'Tambah Perbelanjaan';

  @override
  String get description => 'Keterangan';

  @override
  String get amountRp => 'Jumlah';

  @override
  String get generalCategory => 'Umum';

  @override
  String get deleteConfirmTitle => 'Padam Data';

  @override
  String get deleteExpenseConfirm => 'Padam perbelanjaan ini?';

  @override
  String get roomDetail => 'Butiran Bilik';

  @override
  String get roomNotFound => 'Bilik tidak dijumpai.';

  @override
  String capacityLabel(Object count) {
    return 'Kapasiti: $count';
  }

  @override
  String pricePerNightLabel(Object price) {
    return '$price / malam';
  }

  @override
  String get statusOccupied => 'Status: PENGHUNI';

  @override
  String get statusAvailable => 'Status: KOSONG';

  @override
  String get checkInButton => 'Daftar Masuk';

  @override
  String get checkOutButton => 'Daftar Keluar';

  @override
  String get checkInRoom => 'Daftar Masuk (Masuk Bilik)';

  @override
  String get updatePrice => 'Kemas Kini Harga';

  @override
  String get catNotRegistered => 'Kucing belum didaftarkan?';

  @override
  String get cancelAdd => 'Batal Tambah';

  @override
  String get addNew => 'Tambah Baru';

  @override
  String get newCatData => 'Data Kucing Baru';

  @override
  String get ownerNameLabel => 'Nama Pemilik';

  @override
  String get catAddedSuccess => 'Kucing berjaya ditambah!';

  @override
  String get selectDate => 'Pilih Tarikh';

  @override
  String get confirmCheckOut => 'Sahkan Daftar Keluar';

  @override
  String get finishBookingConfirm =>
      'Selesaikan tempahan ini? Bilik akan menjadi kosong.';

  @override
  String get manageServices => 'Pengurusan Perkhidmatan';

  @override
  String get noServices => 'Tiada perkhidmatan lagi.';

  @override
  String get tapPlusAddService => 'Ketik butang + untuk menambah perkhidmatan.';

  @override
  String get editService => 'Edit Perkhidmatan';

  @override
  String get addService => 'Tambah Perkhidmatan';

  @override
  String get serviceName => 'Nama Perkhidmatan';

  @override
  String get invalidPrice => 'Harga tidak sah';

  @override
  String get requiredField => 'Medan ini diperlukan';

  @override
  String get deleteService => 'Padam Perkhidmatan';

  @override
  String deleteServiceConfirm(Object name) {
    return 'Padam \"$name\" secara kekal?';
  }

  @override
  String get readImageFailed => 'Gagal membaca fail: bait kosong (0 bait)';

  @override
  String compressionFailed(Object error) {
    return 'Mampatan gagal: $error';
  }

  @override
  String get compressionResultEmpty => 'Hasil mampatan kosong (null/kosong)';

  @override
  String get appearance => 'Penampilan';

  @override
  String get followSystem => 'Ikut Sistem';

  @override
  String get lightMode => 'Mod Cerah';

  @override
  String get darkMode => 'Mod Gelap';

  @override
  String get language => 'Bahasa';

  @override
  String get shopBranding => 'Penjenamaan Kedai';

  @override
  String get invoiceLogo => 'Logo Invois';

  @override
  String get logoCustomizationDesc => 'Sesuaikan logo untuk resit/invois anda.';

  @override
  String get upgradeToProForLogo => 'Naik taraf ke PRO untuk tukar logo.';

  @override
  String get proFeatureUpgradeRequired =>
      'Ciri PRO! Sila naik taraf langganan anda.';

  @override
  String get businessInformation => 'Maklumat Perniagaan';

  @override
  String get businessName => 'Nama Perniagaan';

  @override
  String get businessPhone => 'Nombor Telefon';

  @override
  String get invoiceHeaderHint => 'Digunakan untuk pengepala resit/invois';

  @override
  String get businessAddress => 'Alamat Perniagaan';

  @override
  String get shopIdLowerHint => 'Gunakan huruf kecil, tanpa ruang';

  @override
  String get shopIdChangedSyncAccount =>
      'ID Kedai berubah. Semak menu Akaun untuk penyelarasan.';

  @override
  String get changesSaved => 'Perubahan disimpan';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String get notificationSettings => 'Tetapan Notifikasi';

  @override
  String get enableReminders => 'Aktifkan Peringatan';

  @override
  String get h1NotificationActive => 'Notifikasi H-1 aktif';

  @override
  String get notificationsDisabled => 'Notifikasi dimatikan';

  @override
  String get reminderTimeH1 => 'Waktu Peringatan (H-1)';

  @override
  String wibTimeLabel(Object time) {
    return 'Masa: $time WIB';
  }

  @override
  String get setReminderTime => 'Tetap Waktu Peringatan';

  @override
  String get reminderTimeDesc =>
      'Notifikasi akan muncul 1 hari sebelum jadual (H-1) pada masa yang ditetapkan.';

  @override
  String get hour023 => 'Jam (0-23)';

  @override
  String get minute059 => 'Minit (0-59)';

  @override
  String get invalidNumber => 'Masukkan nombor yang sah';

  @override
  String get hourLimit => 'Jam mestilah 0-23';

  @override
  String get minuteLimit => 'Minit mestilah 0-59';

  @override
  String get reminderTimeSaved => 'Waktu peringatan disimpan!';

  @override
  String get security => 'Keselamatan';

  @override
  String get appLockPin => 'Kunci Aplikasi (PIN)';

  @override
  String get pinActive => 'PIN Aktif';

  @override
  String get lockDisabled => 'Kunci dimatikan';

  @override
  String get lockDisabledMsg => 'Kunci Aplikasi Dimatikan';

  @override
  String get biometricFingerprint => 'Biometrik (Cap Jari)';

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Tidak Aktif';

  @override
  String get setNewPin6Digit => 'Tetap PIN Baru (6 Digit)';

  @override
  String get newPin => 'PIN Baru';

  @override
  String get confirmPin => 'Sahkan PIN';

  @override
  String get pinMustBe6Digit => 'PIN mestilah 6 digit';

  @override
  String get pinMismatch => 'PIN tidak sepadan';

  @override
  String get pinSuccessSet => 'PIN Berhasil Ditetapkan!';

  @override
  String get aboutApp => 'Tentang Aplikasi';

  @override
  String get versionStable => 'Versi 13.0 (Stabil)';

  @override
  String get thankYouUsingApp =>
      'Terima kasih kerana menggunakan aplikasi ini.';

  @override
  String get loyaltyTracker => 'Loyalty Tracker';

  @override
  String get statusWaiting => 'Menunggu';

  @override
  String get statusBathing => 'Mandi';

  @override
  String get statusDrying => 'Pengeringan';

  @override
  String get statusFinishing => 'Finishing';

  @override
  String get statusPickupReady => 'Sedia Jemput';

  @override
  String get statusDone => 'Selesai';

  @override
  String get deviceWebBrowser => 'Pelayar Web';

  @override
  String get deviceAndroid => 'Peranti Android';

  @override
  String get deviceIosOther => 'Peranti iOS/Lain-lain';

  @override
  String get changePassword => 'Tukar Kata Laluan';

  @override
  String get oldPassword => 'Kata Laluan Lama';

  @override
  String get newPassword => 'Kata Laluan Baru';

  @override
  String get confirmNewPassword => 'Sahkan Kata Laluan Baru';

  @override
  String get passwordMinLength =>
      'Kata laluan mestilah sekurang-kurangnya 6 aksara';

  @override
  String get passwordMismatch => 'Kata laluan baru tidak sepadan';

  @override
  String get wrongOldPassword => 'Kata laluan lama tidak betul';

  @override
  String get passwordChanged => 'Kata laluan berjaya ditukar!';

  @override
  String get passwordChangeFailed => 'Gagal menukar kata laluan';
}
