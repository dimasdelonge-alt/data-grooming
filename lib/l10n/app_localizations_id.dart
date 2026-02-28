// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Data Groomer App';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Ubah';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get success => 'Berhasil';

  @override
  String get error => 'Galat';

  @override
  String get loading => 'Memuat...';

  @override
  String get search => 'Cari';

  @override
  String get settings => 'Pengaturan';

  @override
  String get account => 'Akun';

  @override
  String get recentActivity => 'Aktivitas Terbaru';

  @override
  String get catList => 'Daftar Kucing';

  @override
  String get businessNamePlaceholder => 'Nama Bisnis';

  @override
  String get goodMorning => 'Selamat Pagi';

  @override
  String get goodAfternoon => 'Selamat Siang';

  @override
  String get goodEvening => 'Selamat Sore';

  @override
  String get goodNight => 'Selamat Malam';

  @override
  String get netProfit => 'Laba Bersih';

  @override
  String get income => 'Pemasukan';

  @override
  String get expense => 'Pengeluaran';

  @override
  String get newSession => 'Sesi Baru';

  @override
  String get cats => 'Kucing';

  @override
  String get hotel => 'Hotel';

  @override
  String get booking => 'Booking';

  @override
  String get deposit => 'Deposit';

  @override
  String get services => 'Layanan';

  @override
  String get calendar => 'Kalender';

  @override
  String get activeSessions => 'Sesi Aktif';

  @override
  String get processingNow => 'Sedang diproses sekarang';

  @override
  String get seeAll => 'Lihat Semua';

  @override
  String get groomingSchedule => 'Jadwal Grooming';

  @override
  String get noReschedule => 'Tidak ada jadwal ulang';

  @override
  String get owner => 'Pemilik';

  @override
  String sessionsCountLabel(int count) {
    return '$count sesi';
  }

  @override
  String daysAgoLabel(int days) {
    return '$days hari lalu';
  }

  @override
  String get errEmptyShopIdPassword => 'Shop ID dan Password harus diisi';

  @override
  String get errShopIdNotFound => 'Shop ID tidak ditemukan';

  @override
  String errDeviceLimit(int count) {
    return 'Login ditolak: Limit perangkat tercapai ($count device).\\nSilakan upgrade ke PRO untuk akses lebih banyak.';
  }

  @override
  String get errWrongPassword => 'Password salah';

  @override
  String get errNetwork => 'Gagal terhubung ke server';

  @override
  String get errAllFieldsRequired => 'Semua field harus diisi';

  @override
  String get errInvalidShopId => 'Shop ID tidak boleh mengandung spasi atau /';

  @override
  String get errPasswordMinLength => 'Password minimal 6 karakter';

  @override
  String get errPasswordMismatch => 'Password tidak cocok';

  @override
  String errShopIdTaken(String shopId) {
    return 'Shop ID \"$shopId\" sudah dipakai, coba yang lain';
  }

  @override
  String errCreateAccount(String error) {
    return 'Gagal membuat akun: $error';
  }

  @override
  String msgForgotPwdWithId(String shopId) {
    return 'Halo, saya lupa password SmartGroomer. Shop ID saya: $shopId';
  }

  @override
  String get msgForgotPwd => 'Halo, saya lupa password SmartGroomer.';

  @override
  String get createAccount => 'Buat Akun Baru';

  @override
  String get signInToAccount => 'Masuk ke Akun';

  @override
  String get shopIdHint => 'cth: jeni_cathouse';

  @override
  String get password => 'Password';

  @override
  String get repeatPassword => 'Ulangi Password';

  @override
  String get register => 'Daftar';

  @override
  String get login => 'Masuk';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun? Masuk';

  @override
  String get dontHaveAccount => 'Belum punya akun? Buat Baru';

  @override
  String get forgotPasswordAdmin => 'Lupa Password? Hubungi Admin';

  @override
  String get accountAndBackup => 'Akun & Backup';

  @override
  String get shopSync => 'Sinkronisasi Toko';

  @override
  String get shopConnected => 'Toko Terhubung';

  @override
  String get connectShop => 'Hubungkan Toko';

  @override
  String shopIdValue(String shopId) {
    return 'ID: $shopId';
  }

  @override
  String get notConnectedToShop => 'Belum terhubung ke toko';

  @override
  String get subscriptionStatus => 'Status Langganan';

  @override
  String get cloudBackupRestore => 'Backup & Restore Cloud';

  @override
  String get connectShopFirstForCloud =>
      'Hubungkan ke Toko terlebih dahulu untuk menggunakan fitur Cloud Backup.';

  @override
  String get backupData => 'Backup Data';

  @override
  String get backupDataDesc => 'Upload semua data lokal ke Cloud';

  @override
  String get uploadDataNow => 'Upload data sekarang?';

  @override
  String get dataWillBeOverwrittenProceed =>
      'Data lokal akan ditimpa! Lanjutkan?';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get restoreDataDesc => 'Download dan timpa data lokal dari Cloud';

  @override
  String get localBackupRestore => 'Backup & Restore Lokal';

  @override
  String get offlineBackupZip => 'Backup Offline (ZIP)';

  @override
  String get offlineBackupZipDesc => 'Simpan database & foto ke file ZIP';

  @override
  String get offlineRestoreZip => 'Restore Offline (ZIP)';

  @override
  String get offlineRestoreZipDesc => 'Pulihkan data dari file ZIP';

  @override
  String get restoreOffline => 'Restore Offline';

  @override
  String get shopId => 'Shop ID';

  @override
  String get secretKey => 'Secret Key';

  @override
  String get createNew => 'Buat Baru';

  @override
  String get invalidIdOrKey =>
      'ID atau Key salah, atau periksa koneksi internet.';

  @override
  String get connect => 'Hubungkan';

  @override
  String get createNewShop => 'Buat Toko Baru';

  @override
  String get createNewShopDesc =>
      'ID dan Secret Key akan dibuat otomatis. Anda juga dapat menentukan ID sendiri (opsional). Data lokal saat ini akan di-upload ke cloud.';

  @override
  String get shopName => 'Nama Toko';

  @override
  String get customShopIdOptional => 'Custom Shop ID (Opsional)';

  @override
  String get customShopIdHint => 'Misal: JENICATHOUSE';

  @override
  String shopCreatedSuccess(String shopId) {
    return 'Toko berhasil dibuat! ID: $shopId';
  }

  @override
  String get shopCreatedFail => 'Gagal membuat toko. Periksa koneksi.';

  @override
  String get createAndUpload => 'Buat & Upload';

  @override
  String get restoreDataPrompt => 'Restore Data?';

  @override
  String get restoreDataPromptDesc =>
      'Berhasil terhubung. Apakah Anda ingin download & restore data dari cloud sekarang?';

  @override
  String get later => 'Nanti Saja';

  @override
  String get restoreSuccess => 'Restore berhasil! Data sedang diperbarui.';

  @override
  String get restoreFail =>
      'Restore gagal! Periksa koneksi atau Secret Key Anda.';

  @override
  String get yesRestore => 'Ya, Restore';

  @override
  String get disconnectShopPrompt => 'Putuskan Koneksi?';

  @override
  String get disconnectShopDesc =>
      'Fitur sinkronisasi dan backup cloud akan dinonaktifkan. Data lokal tetap aman.';

  @override
  String get shopConnectionDisconnected => 'Koneksi toko diputuskan';

  @override
  String get disconnect => 'Putuskan';

  @override
  String get yesProceed => 'Ya, Lanjutkan';

  @override
  String get hiddenForSecurity => '•••••••• (Tersembunyi demi keamanan)';

  @override
  String get checkingStatus => 'Mengecek status...';

  @override
  String statusValue(String plan) {
    return 'Status: $plan';
  }

  @override
  String get checkStatus => 'Cek Status';

  @override
  String validUntilValue(String date) {
    return 'Berlaku Sampai: $date';
  }

  @override
  String deviceLimitValue(int count) {
    return 'Limit Perangkat: $count';
  }

  @override
  String deviceIdValue(String deviceId) {
    return 'Device ID: $deviceId';
  }

  @override
  String upgradeToProWhatsapp(String shopId) {
    return 'Halo Admin, saya ingin upgrade aplikasi DataGrooming saya ke PRO. ID Toko: $shopId';
  }

  @override
  String get upgradeToPro => 'Tingkatkan ke PRO';

  @override
  String get planFree => 'GRATIS';

  @override
  String get home => 'Beranda';

  @override
  String get activity => 'Aktivitas';

  @override
  String get financial => 'Keuangan';

  @override
  String get quickAction => 'Aksi Cepat';

  @override
  String get hotelCheckIn => 'Check-in Hotel';

  @override
  String catListCount(int count) {
    return 'Daftar Kucing ($count)';
  }

  @override
  String get hideArchived => 'Sembunyikan Arsip';

  @override
  String get viewArchived => 'Lihat Terarsip';

  @override
  String get searchCatOrOwner => 'Cari Kucing / Owner';

  @override
  String get noCatsMatchSearch =>
      'Tidak ada kucing yang cocok dengan pencarian.';

  @override
  String get noCatDataYet => 'Belum ada data kucing.';

  @override
  String get tryAnotherKeyword => 'Coba kata kunci lain.';

  @override
  String get tapPlusToAddCat => 'Tap tombol + untuk menambah kucing.';

  @override
  String get dataLockedStarterLimit =>
      'Data ini terkunci (Limit Starter 15). Silakan upgrade ke PRO!';

  @override
  String get starterLimit15CatsReached =>
      'Batas Starter 15 kucing tercapai! Silakan upgrade ke PRO!';

  @override
  String get archiveCatPrompt => 'Arsipkan Kucing?';

  @override
  String archiveCatDesc(String catName) {
    return '\"$catName\" memiliki riwayat transaksi dan tidak bisa dihapus. Dengan mengarsipkan, data keuangan tetap aman namun kucing tidak akan muncul lagi di daftar dan pengingat.';
  }

  @override
  String get archive => 'Arsipkan';

  @override
  String catArchivedSuccess(String catName) {
    return '$catName telah diarsipkan';
  }

  @override
  String get unarchiveCatPrompt => 'Aktifkan Kembali?';

  @override
  String unarchiveCatDesc(String catName) {
    return 'Apakah Anda ingin memulihkan \"$catName\"? Kucing ini akan muncul kembali di daftar aktif.';
  }

  @override
  String get unarchive => 'Aktifkan';

  @override
  String catUnarchivedSuccess(String catName) {
    return '$catName telah diaktifkan kembali';
  }

  @override
  String get deleteFailedHasHistory =>
      'Hapus gagal: Kucing ini memiliki riwayat. Gunakan fitur Arsip.';

  @override
  String get deleteCatPrompt => 'Hapus Kucing?';

  @override
  String deleteCatDesc(String catName) {
    return 'Apakah Anda yakin ingin menghapus \"$catName\"? Semua riwayat grooming juga akan dihapus.';
  }

  @override
  String catDeletedSuccess(String catName) {
    return '$catName telah dihapus';
  }

  @override
  String get catNotFound => 'Kucing tidak ditemukan.';

  @override
  String groomingHistoryCount(int count) {
    return 'Riwayat Grooming ($count)';
  }

  @override
  String get noGroomingHistoryYet => 'Belum ada riwayat grooming.';

  @override
  String get information => 'Informasi';

  @override
  String get phone => 'Telepon';

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
  String get loyaltyCompleted => 'Loyalty Completed! 🎉';

  @override
  String groomingReportShare(
    String catName,
    String date,
    String cost,
    String notes,
  ) {
    return 'Grooming Report\nKucing: $catName\nTanggal: $date\nBiaya: $cost\nCatatan: $notes';
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
  String get catInfo => 'Info Kucing';

  @override
  String get catNameLabel => 'Nama Kucing';

  @override
  String get weightKg => 'Berat Badan (kg)';

  @override
  String get gender => 'Jenis Kelamin';

  @override
  String get male => 'Jantan';

  @override
  String get female => 'Betina';

  @override
  String get yesSterilized => 'Ya, sudah steril';

  @override
  String get notSterilizedYet => 'Belum steril';

  @override
  String get ownerInfo => 'Info Pemilik';

  @override
  String get ownerPhoneLabel => 'No. Telp Pemilik';

  @override
  String get warning => 'Peringatan';

  @override
  String get permanentWarningNote => 'Catatan Peringatan Permanen';

  @override
  String get warningNoteExample => 'Contoh: Galak, Jantung Lemah';

  @override
  String get limitReached15 => 'LIMIT TERCAPAI (15 Ekor)';

  @override
  String get freeVersionUpgradeToPro =>
      'Anda menggunakan versi Gratis. Silakan upgrade ke PRO untuk menambah data tanpa batas.';

  @override
  String get updateCat => 'Update Kucing';

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
    return 'Hanya bisa memilih session dari pemilik yang sama ($ownerName)';
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
    return 'Pilih Semua (owner $ownerName)';
  }

  @override
  String get printCombinedInvoiceBtn => 'Cetak Invoice Gabungan';

  @override
  String get sessionHistoryTitle => 'Riwayat Session';

  @override
  String get searchSession => 'Cari session...';

  @override
  String ownerOnlySessionWarning(String ownerName) {
    return 'Owner: $ownerName — hanya session dari owner ini yang bisa dipilih';
  }

  @override
  String get noSessionsYet => 'Belum ada session.';

  @override
  String get notFound => 'Tidak ditemukan.';

  @override
  String get tapPlusButtonInCatDetail => 'Tap tombol + di detail kucing.';

  @override
  String get sessionStarted => 'Sesi dimulai! Masuk antrian.';

  @override
  String get groomingCheckIn => 'Grooming Check-In';

  @override
  String get startNewSession => 'Mulai Sesi Baru';

  @override
  String get addNewCat => 'Tambah Kucing Baru';

  @override
  String get checkInStartQueue => 'Check In (Mulai Antrian)';

  @override
  String currentQueue(int count) {
    return 'Antrian Saat Ini ($count)';
  }

  @override
  String get noActiveQueue => 'Tidak ada antrian aktif.';

  @override
  String get unknownCat => 'Kucing Tidak Diketahui';

  @override
  String get setShopIdInSettings => 'Silakan atur Shop ID di Settings';

  @override
  String get trackingTokenNotAvailable =>
      'Error: Token tracking belum tersedia';

  @override
  String whatsappTrackingMessage(
    String ownerName,
    String catName,
    String link,
  ) {
    return 'Hai kak $ownerName 👋\n\nUntuk memantau proses grooming $catName sampai di tahap mana, bisa langsung dicek di link berikut ya:\n$link\n\nTerima kasih sudah mempercayakan kami! 🐱✨';
  }

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String ownerLabel(String ownerName) {
    return 'Owner: $ownerName';
  }

  @override
  String get add => 'Tambah';

  @override
  String get breed => 'Ras / Jenis';

  @override
  String get shareLink => 'Share Link';

  @override
  String get bookingGrooming => 'Booking Grooming';

  @override
  String get noBookingSchedule => 'Tidak ada jadwal booking.';

  @override
  String get addBooking => 'Tambah Booking';

  @override
  String get serviceType => 'Jenis Layanan';

  @override
  String get deleteSchedule => 'Hapus Jadwal';

  @override
  String get deleteScheduleConfirm => 'Hapus jadwal ini secara permanen?';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get cancelBooking => 'Batalkan';

  @override
  String get reschedule => 'Jadwalkan Ulang';

  @override
  String get dateLabel => 'Tanggal';

  @override
  String get serviceLabel => 'Layanan';

  @override
  String get whatsappReminder => 'WhatsApp Reminder';

  @override
  String get checkIn => 'Check-In';

  @override
  String bookingOn(String date) {
    return 'Booking pada $date';
  }

  @override
  String get shortMonday => 'Sen';

  @override
  String get shortTuesday => 'Sel';

  @override
  String get shortWednesday => 'Rab';

  @override
  String get shortThursday => 'Kam';

  @override
  String get shortFriday => 'Jum';

  @override
  String get shortSaturday => 'Sab';

  @override
  String get shortSunday => 'Min';

  @override
  String get noSchedule => 'Tidak ada jadwal.';

  @override
  String get editSession => 'Edit Session';

  @override
  String get sessionNotFound => 'Session tidak ditemukan.';

  @override
  String get deleteSession => 'Hapus Sesi';

  @override
  String get deleteSessionConfirm =>
      'Yakin hapus? Data tidak bisa dikembalikan.';

  @override
  String get status => 'Status';

  @override
  String get findings => 'Findings';

  @override
  String get treatments => 'Treatments';

  @override
  String get notes => 'Catatan';

  @override
  String get totalCost => 'Total Biaya';

  @override
  String get payFromDeposit => 'Bayar dari Deposit';

  @override
  String balanceStr(String balance) {
    return 'Saldo: $balance';
  }

  @override
  String balanceNotEnoughDeduct(String deductedAmount) {
    return 'Saldo kurang, akan dipotong $deductedAmount';
  }

  @override
  String get sessionDetail => 'Session Detail';

  @override
  String get printInvoice => 'Cetak Invoice';

  @override
  String get catDataNotFound => 'Data kucing tidak ditemukan';

  @override
  String get token => 'Token';

  @override
  String get groomerNotes => 'Catatan Groomer';

  @override
  String get unknown => 'Tidak Diketahui';

  @override
  String get monthJan => 'Januari';

  @override
  String get monthFeb => 'Februari';

  @override
  String get monthMar => 'Maret';

  @override
  String get monthApr => 'April';

  @override
  String get monthMay => 'Mei';

  @override
  String get monthJun => 'Juni';

  @override
  String get monthJul => 'Juli';

  @override
  String get monthAug => 'Agustus';

  @override
  String get monthSep => 'September';

  @override
  String get monthOct => 'Oktober';

  @override
  String get monthNov => 'November';

  @override
  String get monthDec => 'Desember';

  @override
  String get statusScheduled => 'Dipesan';

  @override
  String get statusCompleted => 'Selesai';

  @override
  String get statusConfirmed => 'Dikonfirmasi';

  @override
  String get statusCancelled => 'Dibatalkan';

  @override
  String get hotelKucing => 'Hotel Kucing';

  @override
  String get roomStatus => 'Status Kamar';

  @override
  String get billing => 'Biaya';

  @override
  String get history => 'Riwayat';

  @override
  String get noRooms => 'Belum ada kamar.';

  @override
  String get roomLockedStarterLimit =>
      'Kamar ini terkunci (Limit Starter 2). Silakan upgrade ke PRO!';

  @override
  String editBookingFor(String catName) {
    return 'Edit Booking: $catName';
  }

  @override
  String get checkInDate => 'Tanggal Masuk';

  @override
  String get checkOutDate => 'Tanggal Keluar';

  @override
  String get deleteBooking => 'Hapus Booking';

  @override
  String get deleteBookingConfirmTitle => 'Hapus Booking?';

  @override
  String get deleteBookingConfirmDesc => 'Tindakan ini tidak dapat dibatalkan.';

  @override
  String get viewBilling => 'Lihat Tagihan';

  @override
  String get noActiveBilling => 'Tidak ada tagihan aktif.';

  @override
  String get noBilling => 'Tidak ada tagihan.';

  @override
  String get noHistory => 'Belum ada riwayat.';

  @override
  String countCats(int count) {
    return '$count Kucing';
  }

  @override
  String get addRoom => 'Tambah Kamar';

  @override
  String get editRoom => 'Edit Kamar';

  @override
  String get roomName => 'Nama Kamar';

  @override
  String get pricePerNight => 'Harga per Malam';

  @override
  String get capacity => 'Kapasitas';

  @override
  String get overdue => 'TERLAMBAT!';

  @override
  String get occupied => 'Terisi';

  @override
  String get available => 'Kosong';

  @override
  String get locked => 'Terkunci';

  @override
  String get roomCat => 'Kamar/Kucing';

  @override
  String get paid => 'Lunas / Lebih Bayar';

  @override
  String get remainingBilling => 'Sisa Tagihan';

  @override
  String get now => 'Sekarang';

  @override
  String get running => 'Berjalan...';

  @override
  String get addOnCosts => 'Biaya Tambahan';

  @override
  String get manageAddOns => 'Kelola Add-on';

  @override
  String get downPayment => 'Uang Muka (DP):';

  @override
  String get totalCostEst => 'Total Biaya (Est):';

  @override
  String get invoiceDp => 'Invoice DP';

  @override
  String get checkOut => 'Check Out';

  @override
  String get noAddOns => 'Belum ada item tambahan.';

  @override
  String get updateTotalDp => 'Update Total DP';

  @override
  String get dpDistributeDesc =>
      'DP ini akan dibagi rata ke semua booking dalam grup ini.';

  @override
  String get totalDp => 'Total DP';

  @override
  String get confirmCheckout => 'Konfirmasi Check Out';

  @override
  String checkoutConfirmDesc(Object count, Object ownerName) {
    return 'Selesaikan $count booking untuk $ownerName?';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get selectCatRoom => 'Pilih Kucing/Kamar';

  @override
  String get itemNameExample => 'Nama Item (Contoh: Whiskas)';

  @override
  String get price => 'Harga';

  @override
  String get addItem => 'Tambah Item';

  @override
  String get customerDeposit => 'Deposit Pelanggan';

  @override
  String get topUp => 'Top Up';

  @override
  String get searchNamePhone => 'Cari Nama / No HP';

  @override
  String get noDepositData => 'Belum ada data deposit.';

  @override
  String get noName => 'Tanpa Nama';

  @override
  String get topUpBalance => 'Top Up Saldo';

  @override
  String get newDeposit => 'Deposit Baru';

  @override
  String get phoneId => 'No. HP (ID)';

  @override
  String get topUpAmount => 'Jumlah Top Up';

  @override
  String get notesOptional => 'Catatan (Opsional)';

  @override
  String historyPrefix(Object name) {
    return 'Riwayat: $name';
  }

  @override
  String currentBalanceValue(Object balance) {
    return 'Saldo Saat Ini: $balance';
  }

  @override
  String ownerPhoneValue(Object phone) {
    return 'HP: $phone';
  }

  @override
  String get shareHistoryStatement => 'Bagikan Riwayat (Rekening Koran)';

  @override
  String get noTransactions => 'Belum ada transaksi.';

  @override
  String get transTopUp => 'Top Up';

  @override
  String get transGroomingPayment => 'Bayar Grooming';

  @override
  String get transHotelPayment => 'Bayar Hotel';

  @override
  String get transAdjustment => 'Penyesuaian';

  @override
  String get transRefund => 'Refund';

  @override
  String get adjustBalance => 'Adjust Saldo';

  @override
  String get newBalance => 'Saldo Baru';

  @override
  String get adjustmentReason => 'Alasan (Opsional)';

  @override
  String get deleteDeposit => 'Hapus Deposit';

  @override
  String deleteDepositConfirm(Object name) {
    return 'Hapus deposit $name? Semua riwayat transaksi akan ikut terhapus. Data tidak bisa dikembalikan.';
  }

  @override
  String get topUpAgain => 'Top Up Lagi';

  @override
  String get close => 'Tutup';

  @override
  String sameOwnerOnly(Object owner) {
    return 'Hanya bisa memilih transaksi dari pemilik yang sama ($owner)';
  }

  @override
  String get financialReport => 'Laporan Keuangan';

  @override
  String get printReport => 'Cetak Laporan';

  @override
  String ownerSameHint(Object owner) {
    return 'Owner: $owner — hanya transaksi dari owner ini';
  }

  @override
  String get incomeDetailsHeader => 'Rincian Pemasukan';

  @override
  String get transactionHistoryHeader => 'Riwayat Transaksi';

  @override
  String get longPressCombineHint =>
      'Tekan lama untuk memilih & cetak invoice gabungan (1 owner)';

  @override
  String get groomingLabel => 'Grooming';

  @override
  String get hotelLabel => 'Hotel';

  @override
  String get addExpense => 'Tambah Pengeluaran';

  @override
  String get description => 'Keterangan';

  @override
  String get amountRp => 'Jumlah';

  @override
  String get generalCategory => 'Umum';

  @override
  String get deleteConfirmTitle => 'Hapus Data';

  @override
  String get deleteExpenseConfirm => 'Hapus pengeluaran ini?';

  @override
  String get roomDetail => 'Detail Kamar';

  @override
  String get roomNotFound => 'Kamar tidak ditemukan.';

  @override
  String capacityLabel(Object count) {
    return 'Kapasitas: $count';
  }

  @override
  String pricePerNightLabel(Object price) {
    return '$price / malam';
  }

  @override
  String get statusOccupied => 'Status: TERISI';

  @override
  String get statusAvailable => 'Status: KOSONG';

  @override
  String get checkInButton => 'Check In';

  @override
  String get checkOutButton => 'Check Out';

  @override
  String get checkInRoom => 'Check In (Masuk Kamar)';

  @override
  String get updatePrice => 'Update Harga';

  @override
  String get catNotRegistered => 'Kucing belum terdaftar?';

  @override
  String get cancelAdd => 'Batal Tambah';

  @override
  String get addNew => 'Tambah Baru';

  @override
  String get newCatData => 'Data Kucing Baru';

  @override
  String get ownerNameLabel => 'Nama Pemilik';

  @override
  String get catAddedSuccess => 'Kucing berhasil ditambahkan!';

  @override
  String get selectDate => 'Pilih Tanggal';

  @override
  String get confirmCheckOut => 'Konfirmasi Check Out';

  @override
  String get finishBookingConfirm =>
      'Selesaikan booking ini? Kamar akan menjadi kosong.';

  @override
  String get manageServices => 'Manajemen Layanan';

  @override
  String get noServices => 'Belum ada layanan.';

  @override
  String get tapPlusAddService => 'Tap tombol + untuk menambah layanan.';

  @override
  String get editService => 'Edit Layanan';

  @override
  String get addService => 'Tambah Layanan';

  @override
  String get serviceName => 'Nama Layanan';

  @override
  String get invalidPrice => 'Harga tidak valid';

  @override
  String get requiredField => 'Kolom ini wajib diisi';

  @override
  String get deleteService => 'Hapus Layanan';

  @override
  String deleteServiceConfirm(Object name) {
    return 'Hapus \"$name\" secara permanen?';
  }

  @override
  String get readImageFailed => 'Gagal baca file: bytes kosong (0 bytes)';

  @override
  String compressionFailed(Object error) {
    return 'Kompresi gagal: $error';
  }

  @override
  String get compressionResultEmpty => 'Hasil kompresi kosong (null/empty)';

  @override
  String get appearance => 'Tampilan';

  @override
  String get followSystem => 'Ikuti Sistem';

  @override
  String get lightMode => 'Mode Terang';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get language => 'Bahasa';

  @override
  String get shopBranding => 'Branding Toko';

  @override
  String get invoiceLogo => 'Logo Invoice';

  @override
  String get logoCustomizationDesc =>
      'Sesuaikan logo untuk struk/invoice Anda.';

  @override
  String get upgradeToProForLogo => 'Upgrade ke PRO untuk ganti logo.';

  @override
  String get proFeatureUpgradeRequired =>
      'Fitur khusus PRO! Silakan upgrade langganan.';

  @override
  String get businessInformation => 'Informasi Bisnis';

  @override
  String get businessName => 'Nama Bisnis';

  @override
  String get businessPhone => 'Nomor Telepon';

  @override
  String get invoiceHeaderHint => 'Untuk header struk/invoice';

  @override
  String get businessAddress => 'Alamat Bisnis';

  @override
  String get shopIdLowerHint => 'Gunakan huruf kecil, tanpa spasi';

  @override
  String get shopIdChangedSyncAccount =>
      'ID Toko berubah. Cek menu Akun untuk Sinkronisasi.';

  @override
  String get changesSaved => 'Perubahan Disimpan';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String get notificationSettings => 'Pengaturan Notifikasi';

  @override
  String get enableReminders => 'Aktifkan Pengingat';

  @override
  String get h1NotificationActive => 'Notifikasi H-1 aktif';

  @override
  String get notificationsDisabled => 'Notifikasi dimatikan';

  @override
  String get reminderTimeH1 => 'Waktu Pengingat (H-1)';

  @override
  String wibTimeLabel(Object time) {
    return 'Jam: $time WIB';
  }

  @override
  String get setReminderTime => 'Atur Waktu Pengingat';

  @override
  String get reminderTimeDesc =>
      'Notifikasi akan muncul 1 hari sebelum jadwal (H-1) pada jam yang ditentukan.';

  @override
  String get hour023 => 'Jam (0-23)';

  @override
  String get minute059 => 'Menit (0-59)';

  @override
  String get invalidNumber => 'Masukkan angka yang valid';

  @override
  String get hourLimit => 'Jam harus 0-23';

  @override
  String get minuteLimit => 'Menit harus 0-59';

  @override
  String get reminderTimeSaved => 'Waktu pengingat disimpan!';

  @override
  String get security => 'Keamanan';

  @override
  String get appLockPin => 'Kunci Aplikasi (PIN)';

  @override
  String get pinActive => 'PIN Aktif';

  @override
  String get lockDisabled => 'Kunci dimatikan';

  @override
  String get lockDisabledMsg => 'Kunci Aplikasi Dimatikan';

  @override
  String get biometricFingerprint => 'Biometrik (Sidik Jari)';

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Tidak Aktif';

  @override
  String get setNewPin6Digit => 'Atur PIN Baru (6 Digit)';

  @override
  String get newPin => 'PIN Baru';

  @override
  String get confirmPin => 'Konfirmasi PIN';

  @override
  String get pinMustBe6Digit => 'PIN harus 6 digit';

  @override
  String get pinMismatch => 'PIN tidak cocok';

  @override
  String get pinSuccessSet => 'PIN Berhasil Diatur!';

  @override
  String get aboutApp => 'Tentang Aplikasi';

  @override
  String get versionStable => 'Versi 13.0 (Stable)';

  @override
  String get thankYouUsingApp => 'Terima kasih telah menggunakan aplikasi ini.';

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
  String get statusPickupReady => 'Siap Jemput';

  @override
  String get statusDone => 'Selesai';

  @override
  String get deviceWebBrowser => 'Browser Web';

  @override
  String get deviceAndroid => 'Perangkat Android';

  @override
  String get deviceIosOther => 'Perangkat iOS/Lainnya';

  @override
  String get changePassword => 'Ubah Password';

  @override
  String get oldPassword => 'Password Lama';

  @override
  String get newPassword => 'Password Baru';

  @override
  String get confirmNewPassword => 'Konfirmasi Password Baru';

  @override
  String get passwordMinLength => 'Password minimal 6 karakter';

  @override
  String get passwordMismatch => 'Password baru tidak cocok';

  @override
  String get wrongOldPassword => 'Password lama salah';

  @override
  String get passwordChanged => 'Password berhasil diubah!';

  @override
  String get passwordChangeFailed => 'Gagal mengubah password';
}
