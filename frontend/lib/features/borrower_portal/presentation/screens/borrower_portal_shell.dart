import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/state/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/kerdos_mark.dart';
import '../../../auth_gateway/presentation/widgets/language_selector_dropdown.dart';
import 'tabs/my_loan_tab.dart';
import 'tabs/my_group_tab.dart';
import 'tabs/declare_hardship_tab.dart';

class BorrowerPortalShell extends ConsumerWidget {
  const BorrowerPortalShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tabIndex = ref.watch(borrowerTabIndexProvider);
    final isWide = MediaQuery.of(context).size.width >= 900;

    final destinations = [
      (l10n.myLoanTab, Icons.account_balance_wallet_outlined),
      (l10n.myGroupTab, Icons.diversity_3_outlined),
      (l10n.declareHardshipTab, Icons.privacy_tip_outlined),
    ];

    const pages = [
      MyLoanTab(),
      MyGroupTab(),
      DeclareHardshipTab(),
    ];

    final body = IndexedStack(index: tabIndex, children: pages);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KerdosMark(size: 26),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConfig.productName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        height: 1.15,
                      ),
                ),
                Text(
                  l10n.borrowerPortalTitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.inkMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          const LanguageSelectorDropdown(dark: false),
          const SizedBox(width: 4),
          if (MediaQuery.sizeOf(context).width < 520)
            IconButton(
              tooltip: l10n.switchPortal,
              onPressed: () {
                ref.read(selectedPortalProvider.notifier).state =
                    PortalType.lender;
                context.go('/lender');
              },
              icon: const Icon(Icons.swap_horiz),
            )
          else
            TextButton.icon(
              onPressed: () {
                ref.read(selectedPortalProvider.notifier).state =
                    PortalType.lender;
                context.go('/lender');
              },
              icon: const Icon(Icons.swap_horiz),
              label: Text(l10n.switchPortal),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: tabIndex,
                  onDestinationSelected: (i) =>
                      ref.read(borrowerTabIndexProvider.notifier).state = i,
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations
                      .map(
                        (d) => NavigationRailDestination(
                          icon: Icon(d.$2),
                          label: Text(d.$1),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: tabIndex,
              onDestinationSelected: (i) =>
                  ref.read(borrowerTabIndexProvider.notifier).state = i,
              destinations: destinations
                  .map(
                    (d) => NavigationDestination(icon: Icon(d.$2), label: d.$1),
                  )
                  .toList(),
            ),
    );
  }
}