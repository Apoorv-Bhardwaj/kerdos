import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/app_providers.dart';

const Map<String, String> _localeNames = {
  'en': 'English',
  'hi': 'हिन्दी',
  'ta': 'தமிழ்',
  'te': 'తెలుగు',
  'kn': 'ಕನ್ನಡ',
  'bn': 'বাংলা',
};

/// Language switcher shown in the entry gateway and every portal's app
/// bar. Reads from and writes to [localeProvider] so every screen picks
/// up the change immediately.
class LanguageSelectorDropdown extends ConsumerWidget {
  const LanguageSelectorDropdown({super.key, this.dark = true});

  final bool dark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final foreground = dark ? Colors.white : const Color(0xFF0E1E16);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF161F1C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFF0D6E48).withValues(alpha: 0.3),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.4 : 0.10),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: dark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAF5EE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.translate_rounded,
              size: 14,
              color: dark ? Colors.white70 : const Color(0xFF0D6E48),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: locale.languageCode,
              dropdownColor: dark ? const Color(0xFF161F1C) : Colors.white,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                size: 20,
                color: dark ? Colors.white70 : const Color(0xFF0D6E48),
              ),
              style: TextStyle(
                color: foreground,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              items: _localeNames.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (code) {
                if (code == null) return;
                ref.read(localeProvider.notifier).state = Locale(code);
              },
            ),
          ),
        ],
      ),
    );
  }
}