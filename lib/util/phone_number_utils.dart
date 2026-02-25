class PhoneNumberUtils {
  /// Normalizes a phone number by removing all non-numeric characters.
  /// If the number starts with '0', it's kept as is for saving, 
  /// but can be further processed for specific uses.
  static String normalize(String phone) {
    // Remove all non-numeric characters except maybe a leading '+' which we'll handle
    String clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    
    // If it starts with '+62', we might want to keep it or convert to '08' for internal consistency
    // But usually '08' is preferred in Indonesia for local display, 
    // while '62' is needed for WhatsApp.
    
    if (clean.startsWith('+62')) {
      clean = '0${clean.substring(3)}';
    } else if (clean.startsWith('62')) {
      clean = '0${clean.substring(2)}';
    }
    
    return clean;
  }

  /// Formats a phone number for WhatsApp API (starting with 62).
  static String formatForWhatsApp(String phone) {
    // First normalize to remove spaces, dashes, etc.
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // If it starts with '0', replace with '62'
    if (clean.startsWith('0')) {
      return '62${clean.substring(1)}';
    }
    
    // If it already starts with '62', return as is
    if (clean.startsWith('62')) {
      return clean;
    }
    
    // Default fallback (though we expect 08 or 62)
    return clean;
  }
}
