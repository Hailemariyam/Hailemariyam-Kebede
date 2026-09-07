/// User-facing copy, centralised for consistency and future localisation.
class AppStrings {
  AppStrings._();

  static const String appName = 'M-PESA';

  // Splash
  static const String splashTagline = 'from Safaricom';

  // Sign-in
  static const String signInTitle = 'Enter M-PESA PIN';
  static const String signInSubtitle =
      'Enter your 4-digit M-PESA PIN to securely access your account.';
  static const String pinFieldLabel = 'M-PESA PIN';
  static const String signInCta = 'Sign In';
  static const String forgotPin = 'Forgot PIN?';

  // Validation
  static const String pinRequired = 'Please enter your PIN';
  static const String pinLength = 'PIN must be exactly 4 digits';
  static const String pinDigitsOnly = 'PIN must contain digits only';

  // Home
  static const String balanceLabel = 'M-PESA balance';
  static const String recentActivity = 'Recent activity';
  static const String seeAll = 'See all';
  static const String signOut = 'Sign out';
  static const String signOutConfirmTitle = 'Sign out?';
  static const String signOutConfirmBody =
      'You will need your PIN to sign back in.';
  static const String cancel = 'Cancel';
}
