// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'See who\'s really carrying the group\'s risk.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get languageLabel => 'Language';

  @override
  String get lenderPortalTitle => 'Institutional Workspace';

  @override
  String get lenderPortalDescription => 'MFI Field Triage, Contagion Simulation & Portfolio Operations';

  @override
  String get borrowerPortalTitle => 'Member Portal';

  @override
  String get borrowerPortalDescription => 'Personal Loan Health, Group Milestones & Confidential Hardship';

  @override
  String get switchPortal => 'Switch portal';

  @override
  String get fieldTriageTab => 'Field Triage';

  @override
  String get graphSimulationTab => 'Graph & Simulation';

  @override
  String get portfolioAnalyticsTab => 'Portfolio Analytics';

  @override
  String get myLoanTab => 'My Loan';

  @override
  String get myGroupTab => 'My Group';

  @override
  String get declareHardshipTab => 'Declare Hardship';

  @override
  String get comingSoon => 'This view is being built.';
}
