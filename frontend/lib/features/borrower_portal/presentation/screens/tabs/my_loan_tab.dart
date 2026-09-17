import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kerdos/core/network/api_service.dart';
import 'package:kerdos/core/network/models.dart';
import 'package:kerdos/core/theme/app_colors.dart';
import 'package:kerdos/core/theme/app_typography.dart';

/// Member Portal: My Loan Tab.
/// Personal, dignified loan health view for the borrower.
class MyLoanTab extends ConsumerStatefulWidget {
  const MyLoanTab({super.key});

  @override
  ConsumerState<MyLoanTab> createState() => _MyLoanTabState();
}

class _MyLoanTabState extends ConsumerState<MyLoanTab> {
  bool _isLoading = true;
  BorrowerProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final api = ref.read(apiServiceProvider);
    final profile = await api.getBorrowerProfile('B0058');
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.ledger));
    }

    final p = _profile!;
    final repaidPct = ((p.loanAmount - p.remainingBalance) / p.loanAmount).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        // Homely Welcome Header Card
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.paperRaised,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.ledger.withValues(alpha: 0.25)),
            boxShadow: AppColors.cardElevation,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.ledger,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ledger.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'SD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hello, Sunita Devi',
                          style: AppTypography.textTheme(AppColors.ink).headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 19,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.ledgerLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.ledger.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Verified Borrower',
                            style: AppTypography.textTheme(AppColors.ledgerDark).labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Welcome to your personal circle portal • Member ID: ${p.borrowerId} • Solidarity Circle ${p.groupId}',
                      style: AppTypography.textTheme(AppColors.inkMuted).bodySmall?.copyWith(
                            fontSize: 11.5,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Welcome Banner
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
                      'ACTIVE MEMBER • ID ${p.borrowerId}',
                      style: AppTypography.textTheme(AppColors.ledgerDark).labelSmall?.copyWith(fontSize: 10),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.ledgerLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.ledger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.ledger),
                        const SizedBox(width: 4),
                        Text(
                          '${p.repaymentStreakWeeks}-Week On-Time Streak',
                          style: AppTypography.textTheme(AppColors.ledgerDark).labelSmall?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Micro-Enterprise Working Capital Loan',
                style: AppTypography.textTheme(AppColors.ink).titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Circle Group: ${p.groupId} • Repayment frequency: ${p.repaymentInterval}',
                style: AppTypography.textTheme(AppColors.inkMuted).bodySmall,
              ),
              const SizedBox(height: 20),

              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Repayment Completed: ${(repaidPct * 100).toInt()}%', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                  Text('Remaining: ₹${p.remainingBalance.toStringAsFixed(2)}', style: AppTypography.figureStyle(size: 13, color: AppColors.inkMuted)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: repaidPct,
                  minHeight: 8,
                  backgroundColor: AppColors.hairline,
                  color: AppColors.ledger,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Upcoming Payment Due Countdown Card
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 520;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.ledgerLight.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ledger.withValues(alpha: 0.3)),
              ),
              child: isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.ledger,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Next Scheduled Installment', style: AppTypography.textTheme(AppColors.inkMuted).labelSmall),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${p.nextInstallmentAmount.toStringAsFixed(2)}',
                                    style: AppTypography.figureStyle(size: 24, color: AppColors.ledgerDark, weight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Due in ${p.nextInstallmentDueDays} days at Thursday Circle Meeting',
                          style: AppTypography.textTheme(AppColors.ink).bodySmall,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Payment recorded for weekly circle meeting.'),
                                  backgroundColor: AppColors.ledger,
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(backgroundColor: AppColors.ledger),
                            child: const Text('Pay Installment'),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.ledger,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Next Scheduled Installment', style: AppTypography.textTheme(AppColors.inkMuted).labelSmall),
                              const SizedBox(height: 2),
                              Text(
                                '₹${p.nextInstallmentAmount.toStringAsFixed(2)}',
                                style: AppTypography.figureStyle(size: 24, color: AppColors.ledgerDark, weight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Due in ${p.nextInstallmentDueDays} days at Thursday Circle Meeting',
                                style: AppTypography.textTheme(AppColors.ink).bodySmall,
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payment recorded for weekly circle meeting.'),
                                backgroundColor: AppColors.ledger,
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(backgroundColor: AppColors.ledger),
                          child: const Text('Pay Installment'),
                        ),
                      ],
                    ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Account Financial Highlights
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 460;
            if (isNarrow) {
              return Column(
                children: [
                  _FinancialStatCard(
                    title: 'Total Loan Disbursed',
                    value: '₹${p.loanAmount.toStringAsFixed(2)}',
                    subtitle: 'Disbursed to business inventory',
                    icon: Icons.payments_outlined,
                  ),
                  const SizedBox(height: 12),
                  _FinancialStatCard(
                    title: 'Current Savings Buffer',
                    value: '₹${p.currentSavings.toStringAsFixed(2)}',
                    subtitle: 'Emergency reserve in solidarity pool',
                    icon: Icons.savings_outlined,
                    valueColor: AppColors.ledger,
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: _FinancialStatCard(
                    title: 'Total Loan Disbursed',
                    value: '₹${p.loanAmount.toStringAsFixed(2)}',
                    subtitle: 'Disbursed to business inventory',
                    icon: Icons.payments_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FinancialStatCard(
                    title: 'Current Savings Buffer',
                    value: '₹${p.currentSavings.toStringAsFixed(2)}',
                    subtitle: 'Emergency reserve in solidarity pool',
                    icon: Icons.savings_outlined,
                    valueColor: AppColors.ledger,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // Supportive Assistance Notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.paperRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(
            children: [
              const Icon(Icons.support_agent_rounded, color: AppColors.ledger, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Experiencing temporary business difficulty or emergency?',
                      style: AppTypography.textTheme(AppColors.ink).titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Submit a confidential hardship request. Your loan officer will consult with you privately before the group meeting.',
                      style: AppTypography.textTheme(AppColors.inkMuted).bodySmall,
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

class _FinancialStatCard extends StatelessWidget {
  const _FinancialStatCard({
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
            style: AppTypography.figureStyle(size: 22, color: valueColor ?? AppColors.ink, weight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.textTheme(AppColors.inkMuted).bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}