import 'package:url_launcher/url_launcher.dart';
import 'phone_number_utils.dart';

class WhatsAppUtils {
  /// Opens WhatsApp with the given phone number and pre-filled message.
  /// [phone] can be in various formats, will be normalized.
  static Future<void> openWhatsApp(String phone, String message) async {
    String cleanPhone = PhoneNumberUtils.formatForWhatsApp(phone);

    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
