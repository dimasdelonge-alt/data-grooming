// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Data Groomer App';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get catList => 'Cat List';

  @override
  String get businessNamePlaceholder => 'Business Name';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get goodNight => 'Good Night';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get newSession => 'New Session';

  @override
  String get cats => 'Cats';

  @override
  String get hotel => 'Hotel';

  @override
  String get booking => 'Booking';

  @override
  String get deposit => 'Deposit';

  @override
  String get services => 'Services';

  @override
  String get calendar => 'Calendar';

  @override
  String get activeSessions => 'Active Sessions';

  @override
  String get processingNow => 'Processing now';

  @override
  String get seeAll => 'See All';

  @override
  String get groomingSchedule => 'Grooming Schedule';

  @override
  String get noReschedule => 'No reschedule needed';

  @override
  String get owner => 'Owner';

  @override
  String sessionsCountLabel(int count) {
    return '$count sessions';
  }

  @override
  String daysAgoLabel(int days) {
    return '$days days ago';
  }

  @override
  String get errEmptyShopIdPassword => 'Shop ID and Password cannot be empty';

  @override
  String get errShopIdNotFound => 'Shop ID not found';

  @override
  String errDeviceLimit(int count) {
    return 'Login denied: Device limit reached ($count device).\\nPlease upgrade to PRO for more access.';
  }

  @override
  String get errWrongPassword => 'Wrong password';

  @override
  String get errNetwork => 'Failed to connect to server';

  @override
  String get errAllFieldsRequired => 'All fields are required';

  @override
  String get errInvalidShopId => 'Shop ID cannot contain spaces or /';

  @override
  String get errPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get errPasswordMismatch => 'Passwords do not match';

  @override
  String errShopIdTaken(String shopId) {
    return 'Shop ID \"$shopId\" is already taken, try another';
  }

  @override
  String errCreateAccount(String error) {
    return 'Failed to create account: $error';
  }

  @override
  String msgForgotPwdWithId(String shopId) {
    return 'Hello, I forgot my SmartGroomer password. My Shop ID is: $shopId';
  }

  @override
  String get msgForgotPwd => 'Hello, I forgot my SmartGroomer password.';

  @override
  String get createAccount => 'Create New Account';

  @override
  String get signInToAccount => 'Sign In to Account';

  @override
  String get shopIdHint => 'e.g. jeni_cathouse';

  @override
  String get password => 'Password';

  @override
  String get repeatPassword => 'Repeat Password';

  @override
  String get register => 'Register';

  @override
  String get login => 'Login';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Create New';

  @override
  String get forgotPasswordAdmin => 'Forgot Password? Contact Admin';

  @override
  String get accountAndBackup => 'Account & Backup';

  @override
  String get shopSync => 'Shop Synchronization';

  @override
  String get shopConnected => 'Shop Connected';

  @override
  String get connectShop => 'Connect Shop';

  @override
  String shopIdValue(String shopId) {
    return 'ID: $shopId';
  }

  @override
  String get notConnectedToShop => 'Not connected to a shop';

  @override
  String get subscriptionStatus => 'Subscription Status';

  @override
  String get cloudBackupRestore => 'Cloud Backup & Restore';

  @override
  String get connectShopFirstForCloud =>
      'Connect to a Shop first to use Cloud Backup features.';

  @override
  String get backupData => 'Backup Data';

  @override
  String get backupDataDesc => 'Upload all local data to Cloud';

  @override
  String get uploadDataNow => 'Upload data now?';

  @override
  String get dataWillBeOverwrittenProceed =>
      'Local data will be overwritten! Proceed?';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get restoreDataDesc => 'Download and overwrite local data from Cloud';

  @override
  String get localBackupRestore => 'Local Backup & Restore';

  @override
  String get offlineBackupZip => 'Offline Backup (ZIP)';

  @override
  String get offlineBackupZipDesc => 'Save database & photos to a ZIP file';

  @override
  String get offlineRestoreZip => 'Offline Restore (ZIP)';

  @override
  String get offlineRestoreZipDesc => 'Restore data from a ZIP file';

  @override
  String get restoreOffline => 'Restore Offline';

  @override
  String get shopId => 'Shop ID';

  @override
  String get secretKey => 'Secret Key';

  @override
  String get createNew => 'Create New';

  @override
  String get invalidIdOrKey =>
      'Invalid ID or Key, or check your internet connection.';

  @override
  String get connect => 'Connect';

  @override
  String get createNewShop => 'Create New Shop';

  @override
  String get createNewShopDesc =>
      'ID and Secret Key will be automatically generated. You can also specify your own ID (optional). Current local data will be uploaded to the cloud.';

  @override
  String get shopName => 'Shop Name';

  @override
  String get customShopIdOptional => 'Custom Shop ID (Optional)';

  @override
  String get customShopIdHint => 'e.g., JENICATHOUSE';

  @override
  String shopCreatedSuccess(String shopId) {
    return 'Shop created successfully! ID: $shopId';
  }

  @override
  String get shopCreatedFail => 'Failed to create shop. Check your connection.';

  @override
  String get createAndUpload => 'Create & Upload';

  @override
  String get restoreDataPrompt => 'Restore Data?';

  @override
  String get restoreDataPromptDesc =>
      'Connected successfully. Do you want to download & restore data from the cloud now?';

  @override
  String get later => 'Later';

  @override
  String get restoreSuccess => 'Restore successful! Data is being updated.';

  @override
  String get restoreFail =>
      'Restore failed! Check your connection or Secret Key.';

  @override
  String get yesRestore => 'Yes, Restore';

  @override
  String get disconnectShopPrompt => 'Disconnect Shop?';

  @override
  String get disconnectShopDesc =>
      'Cloud backup and sync features will be disabled. Local data remains safe.';

  @override
  String get shopConnectionDisconnected => 'Shop connection disconnected';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get yesProceed => 'Yes, Proceed';

  @override
  String get hiddenForSecurity => '•••••••• (Hidden for security)';

  @override
  String get checkingStatus => 'Checking status...';

  @override
  String statusValue(String plan) {
    return 'Status: $plan';
  }

  @override
  String get checkStatus => 'Check Status';

  @override
  String validUntilValue(String date) {
    return 'Valid Until: $date';
  }

  @override
  String deviceLimitValue(int count) {
    return 'Device Limit: $count';
  }

  @override
  String deviceIdValue(String deviceId) {
    return 'Device ID: $deviceId';
  }

  @override
  String upgradeToProWhatsapp(String shopId) {
    return 'Hello Admin, I want to upgrade my DataGrooming app to PRO. Shop ID: $shopId';
  }

  @override
  String get upgradeToPro => 'Upgrade to PRO';

  @override
  String get planFree => 'FREE';

  @override
  String get home => 'Home';

  @override
  String get activity => 'Activity';

  @override
  String get financial => 'Financial';

  @override
  String get quickAction => 'Quick Action';

  @override
  String get hotelCheckIn => 'Hotel Check-in';

  @override
  String catListCount(int count) {
    return 'Cat List ($count)';
  }

  @override
  String get hideArchived => 'Hide Archived';

  @override
  String get viewArchived => 'View Archived';

  @override
  String get searchCatOrOwner => 'Search Cat / Owner';

  @override
  String get noCatsMatchSearch => 'No cats match the search.';

  @override
  String get noCatDataYet => 'No cat data yet.';

  @override
  String get tryAnotherKeyword => 'Try another keyword.';

  @override
  String get tapPlusToAddCat => 'Tap the + button to add a cat.';

  @override
  String get dataLockedStarterLimit =>
      'This data is locked (Starter Limit 15). Please upgrade to PRO!';

  @override
  String get starterLimit15CatsReached =>
      'Starter limit of 15 cats reached! Please upgrade to PRO.';

  @override
  String get archiveCatPrompt => 'Archive Cat?';

  @override
  String archiveCatDesc(String catName) {
    return '\"$catName\" has transaction history and cannot be deleted. By archiving, financial data remains safe but the cat will no longer appear in lists and reminders.';
  }

  @override
  String get archive => 'Archive';

  @override
  String catArchivedSuccess(String catName) {
    return '$catName has been archived';
  }

  @override
  String get unarchiveCatPrompt => 'Reactivate?';

  @override
  String unarchiveCatDesc(String catName) {
    return 'Do you want to restore \"$catName\"? This cat will reappear in the active list.';
  }

  @override
  String get unarchive => 'Reactivate';

  @override
  String catUnarchivedSuccess(String catName) {
    return '$catName has been reactivated';
  }

  @override
  String get deleteFailedHasHistory =>
      'Delete failed: This cat has history. Use the Archive feature.';

  @override
  String get deleteCatPrompt => 'Delete Cat?';

  @override
  String deleteCatDesc(String catName) {
    return 'Are you sure you want to delete \"$catName\"? All grooming history will also be deleted.';
  }

  @override
  String catDeletedSuccess(String catName) {
    return '$catName has been deleted';
  }

  @override
  String get catNotFound => 'Cat not found.';

  @override
  String groomingHistoryCount(int count) {
    return 'Grooming History ($count)';
  }

  @override
  String get noGroomingHistoryYet => 'No grooming history yet.';

  @override
  String get information => 'Information';

  @override
  String get phone => 'Phone';

  @override
  String get furColor => 'Fur Color';

  @override
  String get eyeColor => 'Eye Color';

  @override
  String get weight => 'Weight';

  @override
  String get sterile => 'Sterile';

  @override
  String get isSterileYes => 'Sterilized';

  @override
  String get isSterileNo => 'Not Sterilized';

  @override
  String get loyaltyCompleted => 'Loyalty Completed! 🎉';

  @override
  String groomingReportShare(
    String catName,
    String date,
    String cost,
    String notes,
  ) {
    return 'Grooming Report\nCat: $catName\nDate: $date\nCost: $cost\nNotes: $notes';
  }

  @override
  String get chooseProfilePhoto => 'Choose Profile Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get editCat => 'Edit Cat';

  @override
  String get addCat => 'Add Cat';

  @override
  String get catInfo => 'Cat Info';

  @override
  String get catNameLabel => 'Cat Name';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get yesSterilized => 'Yes, sterilized';

  @override
  String get notSterilizedYet => 'Not sterilized yet';

  @override
  String get ownerInfo => 'Owner Info';

  @override
  String get ownerPhoneLabel => 'Owner Phone No.';

  @override
  String get warning => 'Warning';

  @override
  String get permanentWarningNote => 'Permanent Warning Note';

  @override
  String get warningNoteExample => 'Example: Aggressive, Weak Heart';

  @override
  String get limitReached15 => 'LIMIT REACHED (15 Cats)';

  @override
  String get freeVersionUpgradeToPro =>
      'You are using the Free version. Please upgrade to PRO to add unlimited data.';

  @override
  String get updateCat => 'Update Cat';

  @override
  String get saveCat => 'Save Cat';

  @override
  String fieldRequired(String field) {
    return '$field is required';
  }

  @override
  String enterField(String field) {
    return 'Enter $field';
  }

  @override
  String get ownerName => 'Owner Name';

  @override
  String get ownerNameRequired => 'Owner Name is required';

  @override
  String get searchOrEnterOwnerName => 'Search or enter owner name';

  @override
  String onlySelectSameOwnerSession(String ownerName) {
    return 'Can only select sessions from the same owner ($ownerName)';
  }

  @override
  String printFailed(String error) {
    return 'Failed to print: $error';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String selectAllOwner(String ownerName) {
    return 'Select All (owner $ownerName)';
  }

  @override
  String get printCombinedInvoiceBtn => 'Print Combined Invoice';

  @override
  String get sessionHistoryTitle => 'Session History';

  @override
  String get searchSession => 'Search session...';

  @override
  String ownerOnlySessionWarning(String ownerName) {
    return 'Owner: $ownerName — only sessions from this owner can be selected';
  }

  @override
  String get noSessionsYet => 'No sessions yet.';

  @override
  String get notFound => 'Not found.';

  @override
  String get tapPlusButtonInCatDetail => 'Tap the + button in cat details.';

  @override
  String get sessionStarted => 'Session started! Added to queue.';

  @override
  String get groomingCheckIn => 'Grooming Check-In';

  @override
  String get startNewSession => 'Start New Session';

  @override
  String get addNewCat => 'Add New Cat';

  @override
  String get checkInStartQueue => 'Check In (Start Queue)';

  @override
  String currentQueue(int count) {
    return 'Current Queue ($count)';
  }

  @override
  String get noActiveQueue => 'No active queue.';

  @override
  String get unknownCat => 'Unknown Cat';

  @override
  String get setShopIdInSettings => 'Please set Shop ID in Settings';

  @override
  String get trackingTokenNotAvailable => 'Error: Tracking token not available';

  @override
  String whatsappTrackingMessage(
    String ownerName,
    String catName,
    String link,
  ) {
    return 'Hi $ownerName 👋\n\nTo track $catName\'s grooming progress, you can check this link:\n$link\n\nThank you for trusting us! 🐱✨';
  }

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String ownerLabel(String ownerName) {
    return 'Owner: $ownerName';
  }

  @override
  String get add => 'Add';

  @override
  String get breed => 'Breed';

  @override
  String get shareLink => 'Share Link';

  @override
  String get bookingGrooming => 'Grooming Booking';

  @override
  String get noBookingSchedule => 'No booking schedule.';

  @override
  String get addBooking => 'Add Booking';

  @override
  String get serviceType => 'Service Type';

  @override
  String get deleteSchedule => 'Delete Schedule';

  @override
  String get deleteScheduleConfirm => 'Permanently delete this schedule?';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancelBooking => 'Cancel';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get dateLabel => 'Date';

  @override
  String get serviceLabel => 'Service';

  @override
  String get whatsappReminder => 'WhatsApp Reminder';

  @override
  String get checkIn => 'Check-In';

  @override
  String bookingOn(String date) {
    return 'Booking on $date';
  }

  @override
  String get shortMonday => 'Mon';

  @override
  String get shortTuesday => 'Tue';

  @override
  String get shortWednesday => 'Wed';

  @override
  String get shortThursday => 'Thu';

  @override
  String get shortFriday => 'Fri';

  @override
  String get shortSaturday => 'Sat';

  @override
  String get shortSunday => 'Sun';

  @override
  String get noSchedule => 'No schedule.';

  @override
  String get editSession => 'Edit Session';

  @override
  String get sessionNotFound => 'Session not found.';

  @override
  String get deleteSession => 'Delete Session';

  @override
  String get deleteSessionConfirm => 'Are you sure? Data cannot be restored.';

  @override
  String get status => 'Status';

  @override
  String get findings => 'Findings';

  @override
  String get treatments => 'Treatments';

  @override
  String get notes => 'Notes';

  @override
  String get totalCost => 'Total Cost';

  @override
  String get payFromDeposit => 'Pay from Deposit';

  @override
  String balanceStr(String balance) {
    return 'Balance: $balance';
  }

  @override
  String balanceNotEnoughDeduct(String deductedAmount) {
    return 'Insufficient balance, $deductedAmount will be deducted';
  }

  @override
  String get sessionDetail => 'Session Detail';

  @override
  String get printInvoice => 'Print Invoice';

  @override
  String get catDataNotFound => 'Cat data not found';

  @override
  String get token => 'Token';

  @override
  String get groomerNotes => 'Groomer Notes';

  @override
  String get unknown => 'Unknown';

  @override
  String get monthJan => 'January';

  @override
  String get monthFeb => 'February';

  @override
  String get monthMar => 'March';

  @override
  String get monthApr => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'June';

  @override
  String get monthJul => 'July';

  @override
  String get monthAug => 'August';

  @override
  String get monthSep => 'September';

  @override
  String get monthOct => 'October';

  @override
  String get monthNov => 'November';

  @override
  String get monthDec => 'December';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get hotelKucing => 'Cat Hotel';

  @override
  String get roomStatus => 'Room Status';

  @override
  String get billing => 'Billing';

  @override
  String get history => 'History';

  @override
  String get noRooms => 'No rooms yet.';

  @override
  String get roomLockedStarterLimit =>
      'This room is locked (Starter Limit 2). Please upgrade to PRO!';

  @override
  String editBookingFor(String catName) {
    return 'Edit Booking: $catName';
  }

  @override
  String get checkInDate => 'Check-in Date';

  @override
  String get checkOutDate => 'Check-out Date';

  @override
  String get deleteBooking => 'Delete Booking';

  @override
  String get deleteBookingConfirmTitle => 'Delete Booking?';

  @override
  String get deleteBookingConfirmDesc => 'This action cannot be undone.';

  @override
  String get viewBilling => 'View Billing';

  @override
  String get noActiveBilling => 'No active billing.';

  @override
  String get noBilling => 'No billing.';

  @override
  String get noHistory => 'No history yet.';

  @override
  String countCats(int count) {
    return '$count Cats';
  }

  @override
  String get addRoom => 'Add Room';

  @override
  String get editRoom => 'Edit Room';

  @override
  String get roomName => 'Room Name';

  @override
  String get pricePerNight => 'Price per Night';

  @override
  String get capacity => 'Capacity';

  @override
  String get overdue => 'OVERDUE!';

  @override
  String get occupied => 'Occupied';

  @override
  String get available => 'Available';

  @override
  String get locked => 'Locked';

  @override
  String get roomCat => 'Room/Cat';

  @override
  String get paid => 'Paid / Overpaid';

  @override
  String get remainingBilling => 'Remaining Billing';

  @override
  String get now => 'Now';

  @override
  String get running => 'Running...';

  @override
  String get addOnCosts => 'Additional Costs';

  @override
  String get manageAddOns => 'Manage Add-ons';

  @override
  String get downPayment => 'Down Payment (DP):';

  @override
  String get totalCostEst => 'Total Cost (Est):';

  @override
  String get invoiceDp => 'Invoice DP';

  @override
  String get checkOut => 'Check Out';

  @override
  String get noAddOns => 'No additional items.';

  @override
  String get updateTotalDp => 'Update Total DP';

  @override
  String get dpDistributeDesc =>
      'This DP will be distributed evenly to all bookings in this group.';

  @override
  String get totalDp => 'Total DP';

  @override
  String get confirmCheckout => 'Confirm Check Out';

  @override
  String checkoutConfirmDesc(Object count, Object ownerName) {
    return 'Complete $count booking(s) for $ownerName?';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get selectCatRoom => 'Select Cat/Room';

  @override
  String get itemNameExample => 'Item Name (Example: Whiskas)';

  @override
  String get price => 'Price';

  @override
  String get addItem => 'Add Item';

  @override
  String get customerDeposit => 'Customer Deposit';

  @override
  String get topUp => 'Top Up';

  @override
  String get searchNamePhone => 'Search Name / Phone';

  @override
  String get noDepositData => 'No deposit data found.';

  @override
  String get noName => 'No Name';

  @override
  String get topUpBalance => 'Top Up Balance';

  @override
  String get newDeposit => 'New Deposit';

  @override
  String get phoneId => 'Phone No. (ID)';

  @override
  String get topUpAmount => 'Top Up Amount';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String historyPrefix(Object name) {
    return 'History: $name';
  }

  @override
  String currentBalanceValue(Object balance) {
    return 'Current Balance: $balance';
  }

  @override
  String ownerPhoneValue(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String get shareHistoryStatement => 'Share History (Account Statement)';

  @override
  String get noTransactions => 'No transactions found.';

  @override
  String get transTopUp => 'Top Up';

  @override
  String get transGroomingPayment => 'Grooming Payment';

  @override
  String get transHotelPayment => 'Hotel Payment';

  @override
  String get transAdjustment => 'Adjustment';

  @override
  String get transRefund => 'Refund';

  @override
  String get adjustBalance => 'Adjust Balance';

  @override
  String get newBalance => 'New Balance';

  @override
  String get adjustmentReason => 'Reason (Optional)';

  @override
  String get deleteDeposit => 'Delete Deposit';

  @override
  String deleteDepositConfirm(Object name) {
    return 'Delete deposit for $name? All transaction history will be deleted. This action cannot be undone.';
  }

  @override
  String get topUpAgain => 'Top Up Again';

  @override
  String get close => 'Close';

  @override
  String sameOwnerOnly(Object owner) {
    return 'Can only select transactions from the same owner ($owner)';
  }

  @override
  String get financialReport => 'Financial Report';

  @override
  String get printReport => 'Print Report';

  @override
  String ownerSameHint(Object owner) {
    return 'Owner: $owner — only transactions from this owner';
  }

  @override
  String get incomeDetailsHeader => 'Income Details';

  @override
  String get transactionHistoryHeader => 'Transaction History';

  @override
  String get longPressCombineHint =>
      'Long press to select & print combined invoice (1 owner)';

  @override
  String get groomingLabel => 'Grooming';

  @override
  String get hotelLabel => 'Hotel';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get description => 'Description';

  @override
  String get amountRp => 'Amount';

  @override
  String get generalCategory => 'General';

  @override
  String get deleteConfirmTitle => 'Delete Data?';

  @override
  String get deleteExpenseConfirm =>
      'Are you sure you want to delete this expense?';

  @override
  String get roomDetail => 'Room Detail';

  @override
  String get roomNotFound => 'Room not found.';

  @override
  String capacityLabel(Object count) {
    return 'Capacity: $count';
  }

  @override
  String pricePerNightLabel(Object price) {
    return '$price / night';
  }

  @override
  String get statusOccupied => 'Status: OCCUPIED';

  @override
  String get statusAvailable => 'Status: AVAILABLE';

  @override
  String get checkInButton => 'Check In';

  @override
  String get checkOutButton => 'Check Out';

  @override
  String get checkInRoom => 'Check In (Enter Room)';

  @override
  String get updatePrice => 'Update Price';

  @override
  String get catNotRegistered => 'Cat not registered?';

  @override
  String get cancelAdd => 'Cancel Add';

  @override
  String get addNew => 'Add New';

  @override
  String get newCatData => 'New Cat Data';

  @override
  String get ownerNameLabel => 'Owner Name';

  @override
  String get catAddedSuccess => 'Cat added successfully!';

  @override
  String get selectDate => 'Select Date';

  @override
  String get confirmCheckOut => 'Confirm Check Out';

  @override
  String get finishBookingConfirm =>
      'Finish this booking? Room will become available.';

  @override
  String get manageServices => 'Manage Services';

  @override
  String get noServices => 'No services yet.';

  @override
  String get tapPlusAddService => 'Tap the + button to add a service.';

  @override
  String get editService => 'Edit Service';

  @override
  String get addService => 'Add Service';

  @override
  String get serviceName => 'Service Name';

  @override
  String get invalidPrice => 'Invalid price';

  @override
  String get requiredField => 'This field is required';

  @override
  String get deleteService => 'Delete Service';

  @override
  String deleteServiceConfirm(Object name) {
    return 'Permanently delete \"$name\"?';
  }

  @override
  String get readImageFailed => 'Failed to read file: bytes empty (0 bytes)';

  @override
  String compressionFailed(Object error) {
    return 'Compression failed: $error';
  }

  @override
  String get compressionResultEmpty => 'Compression result empty (null/empty)';

  @override
  String get appearance => 'Appearance';

  @override
  String get followSystem => 'Follow System';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get shopBranding => 'Shop Branding';

  @override
  String get invoiceLogo => 'Invoice Logo';

  @override
  String get logoCustomizationDesc =>
      'Customize the logo for your receipts/invoices.';

  @override
  String get upgradeToProForLogo => 'Upgrade to PRO to change the logo.';

  @override
  String get proFeatureUpgradeRequired =>
      'PRO feature! Please upgrade your subscription.';

  @override
  String get businessInformation => 'Business Information';

  @override
  String get businessName => 'Business Name';

  @override
  String get businessPhone => 'Business Phone';

  @override
  String get invoiceHeaderHint => 'Used for receipt/invoice header';

  @override
  String get businessAddress => 'Business Address';

  @override
  String get shopIdLowerHint => 'Use lowercase, no spaces';

  @override
  String get shopIdChangedSyncAccount =>
      'Shop ID changed. Check Account menu for synchronization.';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get enableReminders => 'Enable Reminders';

  @override
  String get h1NotificationActive => 'H-1 notification active';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get reminderTimeH1 => 'Reminder Time (H-1)';

  @override
  String wibTimeLabel(Object time) {
    return 'Time: $time WIB';
  }

  @override
  String get setReminderTime => 'Set Reminder Time';

  @override
  String get reminderTimeDesc =>
      'Notifications will appear 1 day before the schedule (H-1) at the specified time.';

  @override
  String get hour023 => 'Hour (0-23)';

  @override
  String get minute059 => 'Minute (0-59)';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get hourLimit => 'Hour must be 0-23';

  @override
  String get minuteLimit => 'Minute must be 0-59';

  @override
  String get reminderTimeSaved => 'Reminder time saved!';

  @override
  String get security => 'Security';

  @override
  String get appLockPin => 'App Lock (PIN)';

  @override
  String get pinActive => 'PIN Active';

  @override
  String get lockDisabled => 'Lock disabled';

  @override
  String get lockDisabledMsg => 'App Lock Disabled';

  @override
  String get biometricFingerprint => 'Biometric (Fingerprint)';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get setNewPin6Digit => 'Set New PIN (6 Digits)';

  @override
  String get newPin => 'New PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get pinMustBe6Digit => 'PIN must be 6 digits';

  @override
  String get pinMismatch => 'PIN mismatch';

  @override
  String get pinSuccessSet => 'PIN set successfully!';

  @override
  String get aboutApp => 'About App';

  @override
  String get versionStable => 'Version 13.0 (Stable)';

  @override
  String get thankYouUsingApp => 'Thank you for using the app.';

  @override
  String get loyaltyTracker => 'Loyalty Tracker';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get statusBathing => 'Bathing';

  @override
  String get statusDrying => 'Drying';

  @override
  String get statusFinishing => 'Finishing';

  @override
  String get statusPickupReady => 'Pickup Ready';

  @override
  String get statusDone => 'Done';

  @override
  String get deviceWebBrowser => 'Web Browser';

  @override
  String get deviceAndroid => 'Android Device';

  @override
  String get deviceIosOther => 'iOS/Other Device';

  @override
  String get changePassword => 'Change Password';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'New passwords do not match';

  @override
  String get wrongOldPassword => 'Old password is incorrect';

  @override
  String get passwordChanged => 'Password changed successfully!';

  @override
  String get passwordChangeFailed => 'Failed to change password';
}
