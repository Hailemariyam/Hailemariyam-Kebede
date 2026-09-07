/// User-facing copy, centralised for consistency and future localisation.
class AppStrings {
  AppStrings._();

  static const String appName = 'M-PESA';

  // Splash
  static const String splashTagline = 'from Safaricom';

  // Sign-in
  static const String signInTitle = 'Enter Your M-PESA PIN';
  static const String signInSubtitle =
      'Enter your 4-digit M-PESA PIN to securely access your account.';
  static const String welcomeBack = 'Welcome back';
  static const String pinFieldLabel = 'M-PESA PIN';
  static const String signInCta = 'Continue';
  static const String forgotPin = 'Forgot PIN';
  static const String contactUs = 'Contact us';
  static const String termsAndConditions = 'Terms & Conditions';

  // Placeholder identity shown before the API returns the real user.
  static const String placeholderName = 'Hailemariyam Kebede';
  static const String placeholderPhone = '+251700000000';

  // Validation
  static const String pinRequired = 'Please enter your PIN';
  static const String pinLength = 'PIN must be exactly 4 digits';
  static const String pinDigitsOnly = 'PIN must contain digits only';

  // Home
  static const String mainBalance = 'Main Balance';
  static const String addMoney = 'Add Money';
  static const String rewardBalance = 'Reward Balance';
  static const String exitBalance = 'Exit Balance';
  static const String hiddenAmount = '••••••••';
  static const String hiddenShort = '••••';
  static const String services = 'Services';
  static const String transactions = 'Transactions';
  static const String seeAll = 'See all';
  static const String signOut = 'Sign out';
  static const String signOutConfirmTitle = 'Sign out?';
  static const String signOutConfirmBody =
      'You will need your PIN to sign back in.';
  static const String cancel = 'Cancel';

  // Service tiles
  static const String merchantPayment = 'Merchant payment';
  static const String billPayment = 'Bill payment';
  static const String creditAndSaving = 'Credit & Saving';
  static const String transferMoney = 'Transfer money';
  static const String airtimePackage = 'Airtime/Package';
  static const String moreServices = 'More services';
}
