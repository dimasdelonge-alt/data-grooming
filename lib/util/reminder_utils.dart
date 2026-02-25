import '../data/entity/cat.dart';
import '../data/entity/booking.dart';
import 'date_utils.dart';
import 'whatsapp_utils.dart';

/// Send a booking reminder via WhatsApp.
void sendWhatsAppReminder(Cat cat, Booking booking) {
  final message =
      'Halo Kak ${cat.ownerName}, mengingatkan jadwal grooming untuk '
      '${cat.catName} pada ${formatDateTime(booking.bookingDate)}. '
      'Layanan: ${booking.serviceType}. Ditunggu ya!';
  WhatsAppUtils.openWhatsApp(cat.ownerPhone, message);
}

/// Send a marketing follow-up reminder via WhatsApp.
void sendMarketingReminder(
    Cat cat, String lastDateStr, int daysSince) {
  final message =
      'Halo Kak ${cat.ownerName}! 👋 Apa kabar? Cuma mau ngingetin nih, '
      'si ${cat.catName} terakhir grooming tanggal $lastDateStr '
      '($daysSince hari lalu). Wah, udah waktunya mandi lagi nih biar '
      'tetap sehat & ganteng! 😺 Mau dijadwalkan kapan kak?';
  WhatsAppUtils.openWhatsApp(cat.ownerPhone, message);
}
