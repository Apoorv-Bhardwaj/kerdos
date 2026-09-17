import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kerdos/core/config/app_config.dart';
import 'package:kerdos/core/state/app_providers.dart';
import 'package:kerdos/core/theme/app_colors.dart';
import 'package:kerdos/core/theme/app_typography.dart';
import 'package:kerdos/shared/widgets/kerdos_mark.dart';
import '../widgets/animated_network_intro.dart';
import '../widgets/language_selector_dropdown.dart';

/// Executive Entry & Authentication Gateway for Kerdos.
/// Features a full-screen pulsating network mesh background beneath a frosted
/// glass finish card, high-contrast light-mode workspace role selector,
/// credentials input, Sign In, and Guest Demo Access.
class EntryGatewayScreen extends ConsumerStatefulWidget {
  const EntryGatewayScreen({super.key});

  @override
  ConsumerState<EntryGatewayScreen> createState() => _EntryGatewayScreenState();
}

class _EntryGatewayScreenState extends ConsumerState<EntryGatewayScreen> {
  PortalType _selectedRole = PortalType.lender;
  final TextEditingController _idController = TextEditingController(text: 'officer@kerdos-mfi.org');
  final TextEditingController _pinController = TextEditingController(text: '884210');
  bool _obscurePin = true;

  @override
  void dispose() {
    _idController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _onRoleChanged(PortalType role) {
    setState(() {
      _selectedRole = role;
      if (role == PortalType.lender) {
        _idController.text = 'officer@kerdos-mfi.org';
      } else {
        _idController.text = 'B0058';
      }
    });
  }

  void _launchWorkspace({bool isGuest = false}) {
    ref.read(selectedPortalProvider.notifier).state = _selectedRole;
    if (_selectedRole == PortalType.lender) {
      context.go('/lender');
    } else {
      context.go('/borrower');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final strings = _LandingPageStrings.of(currentLocale.languageCode);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: Stack(
        children: [
          // 1. Full-screen pulsating network mesh (ambient constellation & hubs)
          const Positioned.fill(
            child: AnimatedNetworkIntro(isFullScreen: true),
          ),

          // 2. Foreground interactive UI over the glowing network
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top utility row: language selector in light mode (high contrast solid pill)
                      const Align(
                        alignment: Alignment.topRight,
                        child: LanguageSelectorDropdown(dark: false),
                      ),
                      const SizedBox(height: 14),

                      // Frosted Glass Finish Auth Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.95),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0E1E16).withValues(alpha: 0.08),
                                  blurRadius: 32,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color: AppColors.ledger.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Brand identity lockup
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const KerdosMark(size: 32, color: AppColors.ledger),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppConfig.productName,
                                      style: AppTypography.textTheme(AppColors.ink).displayLarge?.copyWith(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  strings.tagline,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.textTheme(AppColors.inkMuted).bodyMedium?.copyWith(
                                        color: const Color(0xFF374151),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                ),
                                const SizedBox(height: 22),
                                const Divider(color: Color(0xFFE5E7EB), height: 1),
                                const SizedBox(height: 20),

                                // Workspace Role Selector Tabs
                                Text(
                                  strings.selectWorkspace,
                                  style: AppTypography.textTheme(AppColors.ink).labelLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        letterSpacing: 0.2,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _RoleTab(
                                        title: strings.institutionalTitle,
                                        subtitle: strings.institutionalSubtitle,
                                        isSelected: _selectedRole == PortalType.lender,
                                        icon: Icons.account_balance_outlined,
                                        onTap: () => _onRoleChanged(PortalType.lender),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _RoleTab(
                                        title: strings.memberTitle,
                                        subtitle: strings.memberSubtitle,
                                        isSelected: _selectedRole == PortalType.borrower,
                                        icon: Icons.diversity_3_outlined,
                                        onTap: () => _onRoleChanged(PortalType.borrower),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Identifier Field
                                Text(
                                  _selectedRole == PortalType.lender ? strings.workEmailOrStaffId : strings.borrowerMemberId,
                                  style: AppTypography.textTheme(AppColors.inkMuted).labelSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _idController,
                                  style: AppTypography.textTheme(AppColors.ink).bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.95),
                                    prefixIcon: Icon(
                                      _selectedRole == PortalType.lender ? Icons.badge_outlined : Icons.person_outline,
                                      color: AppColors.ledger,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFD1DCD5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFD1DCD5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.ledger, width: 1.8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // PIN / Password Field
                                Text(
                                  strings.securityPin,
                                  style: AppTypography.textTheme(AppColors.inkMuted).labelSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _pinController,
                                  obscureText: _obscurePin,
                                  style: AppTypography.textTheme(AppColors.ink).bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.95),
                                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.ledger, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: const Color(0xFF5A6E64),
                                        size: 18,
                                      ),
                                      onPressed: () => setState(() => _obscurePin = !_obscurePin),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFD1DCD5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFD1DCD5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.ledger, width: 1.8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // Primary Sign In Button
                                FilledButton.icon(
                                  onPressed: () => _launchWorkspace(isGuest: false),
                                  icon: const Icon(Icons.login_rounded, size: 18),
                                  label: Text(
                                    _selectedRole == PortalType.lender
                                        ? strings.signInInstitutional
                                        : strings.signInMember,
                                    style: AppTypography.textTheme(Colors.white).labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.ledger,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Prominent Continue as Guest Button
                                OutlinedButton.icon(
                                  onPressed: () => _launchWorkspace(isGuest: true),
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.ledger),
                                  label: Text(
                                    strings.continueAsGuest,
                                    style: AppTypography.textTheme(AppColors.ledger).labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.ledger,
                                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                                    side: const BorderSide(color: AppColors.ledger, width: 1.4),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Team attribution footnote
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: strings.madeWith),
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.5),
                                child: Icon(
                                  Icons.favorite_rounded,
                                  color: Color(0xFFE11D48),
                                  size: 14,
                                ),
                              ),
                            ),
                            TextSpan(text: strings.teamAttribution),
                          ],
                        ),
                        style: AppTypography.textTheme(AppColors.inkMuted).labelSmall?.copyWith(
                              fontSize: 11.5,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingPageStrings {
  final String tagline;
  final String selectWorkspace;
  final String institutionalTitle;
  final String institutionalSubtitle;
  final String memberTitle;
  final String memberSubtitle;
  final String workEmailOrStaffId;
  final String borrowerMemberId;
  final String securityPin;
  final String signInInstitutional;
  final String signInMember;
  final String continueAsGuest;
  final String madeWith;
  final String teamAttribution;

  const _LandingPageStrings({
    required this.tagline,
    required this.selectWorkspace,
    required this.institutionalTitle,
    required this.institutionalSubtitle,
    required this.memberTitle,
    required this.memberSubtitle,
    required this.workEmailOrStaffId,
    required this.borrowerMemberId,
    required this.securityPin,
    required this.signInInstitutional,
    required this.signInMember,
    required this.continueAsGuest,
    required this.madeWith,
    required this.teamAttribution,
  });

  static const Map<String, _LandingPageStrings> _translations = {
    'en': _LandingPageStrings(
      tagline: 'Microfinance Financial Contagion & Joint-Liability Risk Platform',
      selectWorkspace: 'Select Workspace',
      institutionalTitle: 'Institutional Workspace',
      institutionalSubtitle: 'MFI Field Triage & Risk',
      memberTitle: 'Member Portal',
      memberSubtitle: 'Borrower & Group Circle',
      workEmailOrStaffId: 'Work Email / Staff ID',
      borrowerMemberId: 'Borrower Member ID',
      securityPin: 'Security PIN / Access Key',
      signInInstitutional: 'Sign In to Institutional Workspace',
      signInMember: 'Sign In to Member Portal',
      continueAsGuest: 'Continue as Guest (Demo Mode)',
      madeWith: 'Made with ',
      teamAttribution: ' by Team Daemon for M# 2026',
    ),
    'hi': _LandingPageStrings(
      tagline: 'सूक्ष्म वित्त वित्तीय संक्रमण एवं संयुक्त देयता जोखिम मंच',
      selectWorkspace: 'कार्यक्षेत्र चुनें',
      institutionalTitle: 'संस्थागत कार्यक्षेत्र',
      institutionalSubtitle: 'एमएफआई फील्ड ट्रायज व जोखिम',
      memberTitle: 'सदस्य पोर्टल',
      memberSubtitle: 'ऋणग्राही एवं समूह मंडल',
      workEmailOrStaffId: 'कार्य ईमेल / स्टाफ आईडी',
      borrowerMemberId: 'ऋणग्राही सदस्य आईडी',
      securityPin: 'सुरक्षा पिन / एक्सेस कुंजी',
      signInInstitutional: 'संस्थागत कार्यक्षेत्र में साइन इन करें',
      signInMember: 'सदस्य पोर्टल में साइन इन करें',
      continueAsGuest: 'अतिथि के रूप में जारी रखें (डेमो मोड)',
      madeWith: 'द्वारा निर्मित ',
      teamAttribution: ' टीम डेमॉन द्वारा M# 2026 हेतु',
    ),
    'ta': _LandingPageStrings(
      tagline: 'நுண்நிதி நிதி தொற்று மற்றும் கூட்டுப் பொறுப்பு இடர் தளம்',
      selectWorkspace: 'பணியிடத்தைத் தேர்ந்தெடுக்கவும்',
      institutionalTitle: 'நிறுவன பணியிடம்',
      institutionalSubtitle: 'எம்.எஃப்.ஐ கள இடர் மேலாண்மை',
      memberTitle: 'உறுப்பினர் தளம்',
      memberSubtitle: 'கடன் வாங்குபவர் மற்றும் குழு வட்டம்',
      workEmailOrStaffId: 'பணி மின்னஞ்சல் / பணியாளர் ஐடி',
      borrowerMemberId: 'கடன் வாங்குபவர் உறுப்பினர் ஐடி',
      securityPin: 'பாதுகாப்பு பின் / அணுகல் விசை',
      signInInstitutional: 'நிறுவன பணியிடத்தில் உள்நுழைக',
      signInMember: 'உறுப்பினர் தளத்தில் உள்நுழைக',
      continueAsGuest: 'விருந்தினராக தொடரவும் (டெமோ முறை)',
      madeWith: 'உருவாக்கப்பட்டது ',
      teamAttribution: ' டீம் டீமான் மூலம் M# 2026 க்காக',
    ),
    'te': _LandingPageStrings(
      tagline: 'మైక్రోఫైనాన్స్ ఆర్థిక సంక్రమణ మరియు ఉమ్మడి బాధ్యత రిస్క్ ప్లాట్‌ఫారమ్',
      selectWorkspace: 'వర్క్‌స్పేస్‌ను ఎంచుకోండి',
      institutionalTitle: 'సంస్థాగత వర్క్‌స్పేస్',
      institutionalSubtitle: 'ఎంఎఫ్ఐ ఫీల్డ్ ట్రయాజ్ & రిస్క్',
      memberTitle: 'సభ్యుల పోర్టల్',
      memberSubtitle: 'రుణగ్రహీత & సమూహ సర్కిల్',
      workEmailOrStaffId: 'కార్యాలయ ఇమెయిల్ / స్టాఫ్ ఐడి',
      borrowerMemberId: 'రుణగ్రహీత సభ్యుని ఐడి',
      securityPin: 'సెక్యూరిటీ పిన్ / యాక్సెస్ కీ',
      signInInstitutional: 'సంస్థాగత వర్క్‌స్పేస్‌కు సైన్ ఇన్ చేయండి',
      signInMember: 'సభ్యుల పోర్టల్‌కు సైన్ ఇన్ చేయండి',
      continueAsGuest: 'గెస్ట్‌గా కొనసాగండి (డెమో మోడ్)',
      madeWith: 'రూపొందించబడింది ',
      teamAttribution: ' టీమ్ డెమోన్ ద్వారా M# 2026 కోసం',
    ),
    'kn': _LandingPageStrings(
      tagline: 'ಸೂಕ್ಷ್ಮ ಹಣಕಾಸು ಹಣಕಾಸಿನ ಸಾಂಕ್ರಾಮಿಕ ಮತ್ತು ಜಂಟಿ ಹೊಣೆಗಾರಿಕೆ ಅಪಾಯದ ವೇದಿಕೆ',
      selectWorkspace: 'ಕಾರ್ಯಸ್ಥಳವನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      institutionalTitle: 'ಸಾಂಸ್ಥಿಕ ಕಾರ್ಯಸ್ಥಳ',
      institutionalSubtitle: 'ಎಂಎಫ್‌ಐ ಫೀಲ್ಡ್ ಟ್ರಯಾಜ್ ಮತ್ತು ರಿಸ್ಕ್',
      memberTitle: 'ಸದಸ್ಯರ ಪೋರ್ಟಲ್',
      memberSubtitle: 'ಸಾಲಗಾರ ಮತ್ತು ಗುಂಪು ವೃತ್ತ',
      workEmailOrStaffId: 'ಕೆಲಸದ ಇಮೇಲ್ / ಸಿಬ್ಬಂದಿ ಐಡಿ',
      borrowerMemberId: 'ಸಾಲಗಾರ ಸದಸ್ಯರ ಐಡಿ',
      securityPin: 'ಭದ್ರತಾ ಪಿನ್ / ಪ್ರವೇಶ ಕೀ',
      signInInstitutional: 'ಸಾಂಸ್ಥಿಕ ಕಾರ್ಯಸ್ಥಳಕ್ಕೆ ಸೈನ್ ಇನ್ ಮಾಡಿ',
      signInMember: 'ಸದಸ್ಯರ ಪೋರ್ಟಲ್‌ಗೆ ಸೈನ್ ಇನ್ ಮಾಡಿ',
      continueAsGuest: 'ಅತಿಥಿಯಾಗಿ ಮುಂದುವರಿಯಿರಿ (ಡೆಮೊ ಮೋಡ್)',
      madeWith: 'ರಚಿಸಲಾಗಿದೆ ',
      teamAttribution: ' ಟೀಮ್ ಡೀಮನ್ ಅವರಿಂದ M# 2026 ಗಾಗಿ',
    ),
    'bn': _LandingPageStrings(
      tagline: 'ক্ষুদ্রঋণ আর্থিক সংক্রামণ এবং যৌথ দায়বদ্ধতা ঝুঁকি প্ল্যাটফর্ম',
      selectWorkspace: 'ওয়ার্কস্পেস নির্বাচন করুন',
      institutionalTitle: 'প্রাতিষ্ঠানিক ওয়ার্কস্পেস',
      institutionalSubtitle: 'এমএফআই ফিল্ড ট্রায়াজ ও ঝুঁকি',
      memberTitle: 'সদস্য পোর্টাল',
      memberSubtitle: 'ঋণগ্রহীতা এবং দলীয় বৃত্ত',
      workEmailOrStaffId: 'কাজের ইমেল / স্টাফ আইডি',
      borrowerMemberId: 'ঋণগ্রহীতা সদস্য আইডি',
      securityPin: 'সুরক্ষা পিন / অ্যাক্সেস কী',
      signInInstitutional: 'প্রাতিষ্ঠানিক ওয়ার্কস্পেসে সাইন ইন করুন',
      signInMember: 'সদস্য পোর্টালে সাইন ইন করুন',
      continueAsGuest: 'অতিথি হিসেবে এগিয়ে যান (ডেমো মোড)',
      madeWith: 'তৈরি করা হয়েছে ',
      teamAttribution: ' টিম ডেমন দ্বারা M# 2026 এর জন্য',
    ),
  };

  static _LandingPageStrings of(String languageCode) {
    return _translations[languageCode] ?? _translations['en']!;
  }
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF5EE) : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.ledger : const Color(0xFFD9E2DC),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.ledger.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? AppColors.ledger : const Color(0xFF5A6E64),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      style: AppTypography.textTheme(AppColors.ink).labelMedium?.copyWith(
                            color: isSelected ? AppColors.ink : const Color(0xFF16201B),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 12.0,
                            letterSpacing: -0.2,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle,
                maxLines: 1,
                style: AppTypography.textTheme(AppColors.inkMuted).labelSmall?.copyWith(
                      color: isSelected ? const Color(0xFF1B6B44) : const Color(0xFF5A6E64),
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}