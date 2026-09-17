import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kerdos/core/network/api_service.dart';
import 'package:kerdos/core/network/models.dart';
import 'package:kerdos/core/state/app_providers.dart';
import 'package:kerdos/core/theme/app_colors.dart';
import 'package:kerdos/core/theme/app_typography.dart';
import '../../widgets/ai_overview_card.dart';

/// Field Triage Tab for Frontline Loan Officers and Risk Managers.
/// Highlights the core differentiator: aggregate group repayment vs. hidden individual distress.
class FieldTriageTab extends ConsumerStatefulWidget {
  const FieldTriageTab({super.key});

  @override
  ConsumerState<FieldTriageTab> createState() => _FieldTriageTabState();
}

class _FieldTriageTabState extends ConsumerState<FieldTriageTab> {
  String _selectedUrgency = 'all'; // 'all', 'urgent', 'watchlist'
  bool _isLoading = true;
  List<GroupTriageItem> _allGroups = [];
  List<GroupTriageItem> _groups = [];

  int get _countAll => _allGroups.length;
  int get _countUrgent => _allGroups.where((g) => g.urgency == 'urgent').length;
  int get _countWatchlist => _allGroups.where((g) => g.urgency == 'watchlist').length;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final api = ref.read(apiServiceProvider);
    final all = await api.getTriageGroups();
    if (mounted) {
      setState(() {
        _allGroups = all;
        _applyFilter();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedUrgency == 'urgent') {
      _groups = _allGroups.where((g) => g.urgency == 'urgent').toList();
    } else if (_selectedUrgency == 'watchlist') {
      _groups = _allGroups.where((g) => g.urgency == 'watchlist').toList();
    } else {
      _groups = List.from(_allGroups);
    }
  }

  void _onUrgencyChanged(String urgency) {
    if (_selectedUrgency == urgency) return;
    setState(() {
      _selectedUrgency = urgency;
      _applyFilter();
    });
  }

  void _showOverrideDialog(GroupTriageItem group) {
    final officerController = TextEditingController(text: 'OFFICER_01');
    final notesController = TextEditingController();
    String reasonCategory = 'Seasonal harvest delay';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.paperRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.hairline),
          ),
          title: Text(
            'Log Field Officer Override',
            style: AppTypography.textTheme(AppColors.ink).titleMedium,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record ground truth field context for Group ${group.groupId} (Borrower ${group.drowningMemberId}).',
                  style: AppTypography.textTheme(AppColors.inkMuted).bodyMedium,
                ),
                const SizedBox(height: 16),
                Text('Officer Staff ID', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                const SizedBox(height: 4),
                TextField(
                  controller: officerController,
                  style: AppTypography.textTheme(AppColors.ink).bodyMedium,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Override Reason Category', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: reasonCategory,
                  style: AppTypography.textTheme(AppColors.ink).bodyMedium,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Seasonal harvest delay', child: Text('Seasonal harvest delay')),
                    DropdownMenuItem(value: 'Temporary family medical setback', child: Text('Temporary family medical setback')),
                    DropdownMenuItem(value: 'False positive / Peer dispute resolved', child: Text('False positive / Peer dispute resolved')),
                    DropdownMenuItem(value: 'Other field mitigating context', child: Text('Other field mitigating context')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => reasonCategory = val);
                  },
                ),
                const SizedBox(height: 12),
                Text('Field Justification Notes', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                const SizedBox(height: 4),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  style: AppTypography.textTheme(AppColors.ink).bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'Enter specific field findings from the weekly visit...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: AppTypography.textTheme(AppColors.inkMuted).labelMedium),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final api = ref.read(apiServiceProvider);
                final success = await api.submitOverride(
                  officerId: officerController.text,
                  groupId: group.groupId,
                  borrowerId: group.drowningMemberId,
                  reasonCategory: reasonCategory,
                  fieldNotes: notesController.text,
                );
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Human override logged successfully in audit trail for ${group.drowningMemberId}.',
                        style: AppTypography.textTheme(Colors.white).bodyMedium,
                      ),
                      backgroundColor: AppColors.ledgerDark,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.ledger),
              child: Text('Submit Override', style: AppTypography.textTheme(Colors.white).labelMedium),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(triageRefreshTriggerProvider, (previous, next) {
      if (previous != next) {
        _loadData();
      }
    });

    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.ledger))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // 1. AI Overview Card with dynamic animated typewriter synthesis
              AiOverviewCard(selectedUrgency: _selectedUrgency),
              const SizedBox(height: 24),

              // 2. Active JLG Group Triage Queue Header
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    'Active JLG Group Triage Queue',
                    style: AppTypography.textTheme(AppColors.ink).titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(lenderTabIndexProvider.notifier).state = 0;
                      context.go('/lender?tab=0');
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 14),
                    label: const Text('Ingest Group Profile', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Filter Urgency choices placed directly above the triage queue
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text('Filter Urgency:', style: AppTypography.textTheme(AppColors.ink).labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    _FilterChip(
                      label: 'All Circles',
                      count: _countAll,
                      isSelected: _selectedUrgency == 'all',
                      onTap: () => _onUrgencyChanged('all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Urgent Contagion',
                      count: _countUrgent,
                      isSelected: _selectedUrgency == 'urgent',
                      onTap: () => _onUrgencyChanged('urgent'),
                      badgeColor: AppColors.statusContagion,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Watchlist',
                      count: _countWatchlist,
                      isSelected: _selectedUrgency == 'watchlist',
                      onTap: () => _onUrgencyChanged('watchlist'),
                      badgeColor: AppColors.statusIsolated,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Group triage list
              ..._groups.map((group) => _buildGroupCard(group)),
            ],
          );
  }

  Widget _buildGroupCard(GroupTriageItem group) {
    final isUrgent = group.urgency == 'urgent';
    final statusColor = isUrgent ? AppColors.statusContagion : (group.hasHiddenRisk ? AppColors.statusIsolated : AppColors.statusHealthy);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.paperRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.hairline),
            boxShadow: AppColors.cardElevation,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Group ${group.groupId}',
                        style: AppTypography.textTheme(AppColors.ink).titleMedium,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          group.causalLabel.toUpperCase(),
                          style: AppTypography.textTheme(statusColor).labelSmall?.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  Text('${group.region}, ${group.country}', style: AppTypography.textTheme(AppColors.inkMuted).bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              if (isNarrow)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _InfoStat(label: 'Total Members', value: '${group.totalMembers} borrowers')),
                        const SizedBox(width: 12),
                        Expanded(child: _InfoStat(label: 'Ledger Repayment', value: '${(group.onTimeRepaymentRecord * 100).toInt()}% on record')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoStat(
                            label: 'Hidden Risk Member',
                            value: group.drowningMemberId,
                            valueColor: statusColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoStat(
                            label: 'Peer Savings Drain',
                            value: '${group.peerSavingsDepletedPct.toInt()}% depleted',
                            valueColor: group.peerSavingsDepletedPct > 50 ? AppColors.statusContagion : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _InfoStat(label: 'Total Members', value: '${group.totalMembers} borrowers'),
                    ),
                    Expanded(
                      child: _InfoStat(label: 'Ledger Repayment', value: '${(group.onTimeRepaymentRecord * 100).toInt()}% on record'),
                    ),
                    Expanded(
                      child: _InfoStat(
                        label: 'Hidden Risk Member',
                        value: group.drowningMemberId,
                        valueColor: statusColor,
                      ),
                    ),
                    Expanded(
                      child: _InfoStat(
                        label: 'Peer Savings Drain',
                        value: '${group.peerSavingsDepletedPct.toInt()}% depleted',
                        valueColor: group.peerSavingsDepletedPct > 50 ? AppColors.statusContagion : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              Text(
                group.actionRecommendation,
                style: AppTypography.textTheme(AppColors.inkMuted).bodySmall,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showOverrideDialog(group),
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: Text('Log Override', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        ref.read(lenderTabIndexProvider.notifier).state = 2;
                        context.go('/lender?tab=2');
                      },
                      icon: const Icon(Icons.hub_outlined, size: 14),
                      label: Text('Inspect Cascade', style: AppTypography.textTheme(Colors.white).labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ledger,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeColor,
    this.count,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? badgeColor;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ledger.withValues(alpha: 0.12) : AppColors.paperRaised,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.ledger : AppColors.hairline,
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected ? AppColors.cardElevation : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              count != null ? '$label ($count)' : label,
              style: AppTypography.textTheme(isSelected ? AppColors.ledger : AppColors.ink).labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  const _InfoStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.textTheme(AppColors.inkMuted).labelSmall?.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.textTheme(valueColor ?? AppColors.ink).bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}