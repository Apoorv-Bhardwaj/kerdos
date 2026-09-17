import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kerdos/core/network/api_service.dart';
import 'package:kerdos/core/theme/app_colors.dart';
import 'package:kerdos/core/theme/app_typography.dart';

/// Member Portal: Declare Hardship Tab.
/// Dignified, confidential early hardship notification form submitted privately to the loan officer.
class DeclareHardshipTab extends ConsumerStatefulWidget {
  const DeclareHardshipTab({super.key});

  @override
  ConsumerState<DeclareHardshipTab> createState() => _DeclareHardshipTabState();
}

class _DeclareHardshipTabState extends ConsumerState<DeclareHardshipTab> {
  String _selectedCategory = 'Medical or Health Emergency';
  String _selectedRelief = '2-Week Temporary Grace Period';
  final TextEditingController _narrativeController = TextEditingController();
  bool _isSubmitting = false;
  bool _submittedSuccess = false;
  String _ticketId = '';

  @override
  void dispose() {
    _narrativeController.dispose();
    super.dispose();
  }

  Future<void> _submitHardship() async {
    setState(() => _isSubmitting = true);
    final api = ref.read(apiServiceProvider);
    final success = await api.submitHardship(
      borrowerId: 'B0058',
      hardshipCategory: _selectedCategory,
      requestedRelief: _selectedRelief,
      narrative: _narrativeController.text,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _submittedSuccess = success;
        _ticketId = 'HRD-${DateTime.now().millisecondsSinceEpoch % 1000000}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedSuccess) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
          padding: const EdgeInsets.all(28),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.paperRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.ledger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.ledger, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Hardship Notification Received Privately',
                style: AppTypography.textTheme(AppColors.ink).titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Confidential Reference: $_ticketId',
                style: AppTypography.figureStyle(size: 13, color: AppColors.ledger, weight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Your notification has been routed directly to your assigned Loan Officer (Maria Santos). '
                'This information is strictly confidential and will NOT be shared with your group peers during circle meetings.',
                textAlign: TextAlign.center,
                style: AppTypography.textTheme(AppColors.inkMuted).bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _submittedSuccess = false;
                    _narrativeController.clear();
                  });
                },
                style: FilledButton.styleFrom(backgroundColor: AppColors.ledger),
                child: const Text('Submit Another Update'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        Text(
          'Confidential Early Hardship Notification',
          style: AppTypography.textTheme(AppColors.ink).headlineSmall?.copyWith(fontFamily: AppTypography.display),
        ),
        const SizedBox(height: 4),
        Text(
          'If you anticipate difficulty meeting your upcoming installment, notify your loan officer in advance to restructure without peer pressure.',
          style: AppTypography.textTheme(AppColors.inkMuted).bodyMedium,
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.ledgerLight.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.ledger.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, size: 20, color: AppColors.ledger),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Privacy Protected: This request routes only to your loan officer. It will never be disclosed to other solidarity group members.',
                  style: AppTypography.textTheme(AppColors.ledgerDark).bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

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
              Text('1. Category of Hardship', style: AppTypography.textTheme(AppColors.ink).titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                style: AppTypography.textTheme(AppColors.ink).bodyMedium,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Medical or Health Emergency', child: Text('Medical or Health Emergency', overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'Crop or Agricultural Harvest Loss', child: Text('Crop or Agricultural Harvest Loss', overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'Business Sales Slowdown', child: Text('Business Sales Slowdown', overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'Family Emergency / Bereavement', child: Text('Family Emergency / Bereavement', overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'Natural Climate or Weather Event', child: Text('Natural Climate or Weather Event', overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 20),

              Text('2. Requested Assistance Relief', style: AppTypography.textTheme(AppColors.ink).titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRelief,
                isExpanded: true,
                style: AppTypography.textTheme(AppColors.ink).bodyMedium,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: '2-Week Temporary Grace Period', child: Text('2-Week Temporary Grace Period', overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'Loan Term Restructuring (Smaller Installments)', child: Text('Loan Term Restructuring (Smaller Installments)', overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'Solidarity Emergency Buffer Utilization', child: Text('Solidarity Emergency Buffer Utilization', overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'Private One-on-One Officer Consultation', child: Text('Private One-on-One Officer Consultation', overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRelief = val);
                },
              ),
              const SizedBox(height: 20),

              Text('3. Brief Description of Circumstance', style: AppTypography.textTheme(AppColors.ink).titleSmall),
              const SizedBox(height: 4),
              Text(
                'Help your officer understand the timeline and how we can best support your enterprise.',
                style: AppTypography.textTheme(AppColors.inkMuted).bodySmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _narrativeController,
                maxLines: 4,
                style: AppTypography.textTheme(AppColors.ink).bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Share any details about your situation (e.g. hospitalization date, delayed harvest market)...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submitHardship,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(_isSubmitting ? 'Routing Notification...' : 'Submit Confidential Hardship Notification'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ledger,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}