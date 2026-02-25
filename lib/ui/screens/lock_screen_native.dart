import 'package:local_auth/local_auth.dart';

/// Native biometric authentication using local_auth.
Future<bool> authenticate() async {
  final auth = LocalAuthentication();
  final canCheck = await auth.canCheckBiometrics;
  final isSupported = await auth.isDeviceSupported();
  
  if (!canCheck || !isSupported) return false;
  
  return await auth.authenticate(
    localizedReason: 'Gunakan sidik jari untuk masuk',
    options: const AuthenticationOptions(
      stickyAuth: true,
      biometricOnly: true,
    ),
  );
}
