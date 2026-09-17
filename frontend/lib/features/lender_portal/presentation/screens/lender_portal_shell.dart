import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/state/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/kerdos_mark.dart';
import '../../../auth_gateway/presentation/widgets/language_selector_dropdown.dart';
import 'tabs/group_input_tab.dart';
import 'tabs/field_triage_tab.dart';
import 'tabs/graph_simulation_tab.dart';
import 'tabs/portfolio_analytics_tab.dart';

class LenderPortalShell extends ConsumerWidget {
  const LenderPortalShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tabIndex = ref.watch(lenderTabIndexProvider);
    final isWide = MediaQuery.of(context).size.width >= 900;

    final tabParam = GoRouterState.of(context).uri.queryParameters['tab'];
    if (tabParam != null) {
      final parsed = int.tryParse(tabParam);
      if (parsed != null && parsed >= 0 && parsed <= 3 && parsed != tabIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ref.read(lenderTabIndexProvider) != parsed) {
            ref.read(lenderTabIndexProvider.notifier).state = parsed;
          }
        });
      }
    }

    void onTabSelected(int i) {
      ref.read(lenderTabIndexProvider.notifier).state = i;
      context.go('/lender?tab=$i');
    }

    final destinations = [
      ('Ingest & Input', Icons.input_rounded),
      (l10n.fieldTriageTab, Icons.groups_outlined),
      (l10n.graphSimulationTab, Icons.hub_outlined),
      (l10n.portfolioAnalyticsTab, Icons.insights_outlined),
    ];

    const pages = [
      GroupInputTab(),
      FieldTriageTab(),
      GraphSimulationTab(),
      PortfolioAnalyticsTab(),
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
                  l10n.lenderPortalTitle,
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
                    PortalType.borrower;
                context.go('/borrower');
              },
              icon: const Icon(Icons.swap_horiz),
            )
          else
            TextButton.icon(
              onPressed: () {
                ref.read(selectedPortalProvider.notifier).state =
                    PortalType.borrower;
                context.go('/borrower');
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
                  onDestinationSelected: onTabSelected,
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
              onDestinationSelected: onTabSelected,
              destinations: destinations
                  .map(
                    (d) => NavigationDestination(icon: Icon(d.$2), label: d.$1),
                  )
                  .toList(),
            ),
    );
  }
}