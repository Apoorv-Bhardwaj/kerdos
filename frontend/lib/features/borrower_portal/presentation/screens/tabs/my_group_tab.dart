import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kerdos/core/network/api_service.dart';
import 'package:kerdos/core/network/models.dart';
import 'package:kerdos/core/theme/app_colors.dart';
import 'package:kerdos/core/theme/app_typography.dart';

/// Member Portal: My Group Tab.
/// Dignified, privacy-preserving group milestone view for solidarity members.
/// Strictly ZERO peer distress, default, or savings drain details are displayed.
class MyGroupTab extends ConsumerStatefulWidget {
  const MyGroupTab({super.key});

  @override
  ConsumerState<MyGroupTab> createState() => _MyGroupTabState();
}

class _MyGroupTabState extends ConsumerState<MyGroupTab> {
  bool _isLoading = true;
  GroupMilestones? _milestones;

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    setState(() => _isLoading = true);
    final api = ref.read(apiServiceProvider);
    final ms = await api.getGroupMilestones('B0058');
    if (mounted) {
      setState(() {
        _milestones = ms;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.ledger));
    }

    final m = _milestones!;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.paperRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.ledger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SOLIDARITY CIRCLE • ${m.groupId}',
                      style: AppTypography.textTheme(AppColors.ledgerDark).labelSmall?.copyWith(fontSize: 10),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.ledger),
                  const SizedBox(width: 4),
                  Text('Good Standing', style: AppTypography.textTheme(AppColors.ledger).labelSmall),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                m.groupName,
                style: AppTypography.textTheme(AppColors.ink).titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '6 community members united by mutual trust and collective growth.',
                style: AppTypography.textTheme(AppColors.inkMuted).bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 460;
            if (isNarrow) {
              return Column(
                children: [
                  _MilestoneBadgeCard(
                    title: 'Meetings Completed',
                    value: '${m.completedOnTimeMeetings}',
                    subtitle: 'Consecutive on-time gatherings',
                    icon: Icons.workspace_premium_outlined,
                  ),
                  const SizedBox(height: 12),
                  _MilestoneBadgeCard(
                    title: 'Collective Savings Shield',
                    value: m.collectiveSavingsShield,
                    subtitle: 'Solidarity buffer for unexpected shocks',
                    icon: Icons.shield_outlined,
                    valueColor: AppColors.ledger,
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: _MilestoneBadgeCard(
                    title: 'Meetings Completed',
                    value: '${m.completedOnTimeMeetings}',
                    subtitle: 'Consecutive on-time gatherings',
                    icon: Icons.workspace_premium_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MilestoneBadgeCard(
                    title: 'Collective Savings Shield',
                    value: m.collectiveSavingsShield,
                    subtitle: 'Solidarity buffer for unexpected shocks',
                    icon: Icons.shield_outlined,
                    valueColor: AppColors.ledger,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.paperRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 18, color: AppColors.ledger),
                  const SizedBox(width: 8),
                  Text('Next Weekly Center Meeting', style: AppTypography.textTheme(AppColors.ink).titleSmall),
                ],
              ),
              const SizedBox(height: 16),
              _MeetingDetailRow(icon: Icons.access_time_rounded, label: 'Date & Time', value: m.nextMeetingDatetime),
              const Divider(color: AppColors.hairline, height: 20),
              _MeetingDetailRow(icon: Icons.location_on_outlined, label: 'Gathering Venue', value: m.nextMeetingLocation),
              const Divider(color: AppColors.hairline, height: 20),
              _MeetingDetailRow(icon: Icons.person_pin_outlined, label: 'Loan Officer Assigned', value: '${m.loanOfficerName} (${m.officerPhone})'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.ledgerLight.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.ledger.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_person_outlined, size: 22, color: AppColors.ledger),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Strict Confidentiality Policy', style: AppTypography.textTheme(AppColors.ledgerDark).labelMedium),
                    const SizedBox(height: 2),
                    Text(
                      m.peerPrivacyGuarantee,
                      style: AppTypography.textTheme(AppColors.ink).bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MilestoneBadgeCard extends StatelessWidget {
  const _MilestoneBadgeCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.valueColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paperRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.ledger),
          const SizedBox(height: 10),
          Text(title, style: AppTypography.textTheme(AppColors.inkMuted).labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.figureStyle(size: 24, color: valueColor ?? AppColors.ink, weight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.textTheme(AppColors.inkMuted).bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _MeetingDetailRow extends StatelessWidget {
  const _MeetingDetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.inkMuted),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.textTheme(AppColors.inkMuted).bodySmall),
        const Spacer(),
        Text(value, style: AppTypography.textTheme(AppColors.ink).labelSmall),
      ],
    );
  }
}