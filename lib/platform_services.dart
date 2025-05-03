// platform_services.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

/// Helper class to handle platform detection
class PlatformServices {
  /// Check if the app is running on the web
  static bool get isWeb => kIsWeb;

  /// Check if the app is running on a mobile device (Android or iOS)
  static bool get isMobile {
    if (kIsWeb) return false;
    try {
      return io.Platform.isAndroid || io.Platform.isIOS;
    } catch (e) {
      // Handle cases where Platform is not available
      return false;
    }
  }

  /// Check if the app is running on desktop (Windows, macOS, Linux)
  static bool get isDesktop {
    if (kIsWeb) return false;
    try {
      return io.Platform.isWindows ||
          io.Platform.isMacOS ||
          io.Platform.isLinux;
    } catch (e) {
      // Handle cases where Platform is not available
      return false;
    }
  }

  /// Get a string representation of the current platform
  static String get platformName {
    if (kIsWeb) return 'Web';
    try {
      if (io.Platform.isAndroid) return 'Android';
      if (io.Platform.isIOS) return 'iOS';
      if (io.Platform.isWindows) return 'Windows';
      if (io.Platform.isMacOS) return 'macOS';
      if (io.Platform.isLinux) return 'Linux';
      if (io.Platform.isFuchsia) return 'Fuchsia';
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }
}