import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kerdos/core/network/api_service.dart';
import 'package:kerdos/core/state/app_providers.dart';
import 'package:kerdos/core/theme/app_colors.dart';
import 'package:kerdos/core/theme/app_typography.dart';

/// Primary Data Ingestion & Group Profile Input Tab for Bank/MFI Institutions.
/// Allows risk officers and judges to enter group attributes directly,
/// load judge-ready demo scenarios, or import custom CSV/JSON profiles.
class GroupInputTab extends ConsumerStatefulWidget {
  const GroupInputTab({super.key});

  @override
  ConsumerState<GroupInputTab> createState() => _GroupInputTabState();
}

class _GroupInputTabState extends ConsumerState<GroupInputTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Direct Input Form Controllers
  final _groupIdController = TextEditingController(text: 'G0188');
  final _groupNameController = TextEditingController(text: 'Varanasi Weavers Circle');
  final _countryController = TextEditingController(text: 'India');
  final _regionController = TextEditingController(text: 'Varanasi_R1');
  final _anchorBorrowerController = TextEditingController(text: 'B9101');
  final _loanAmountController = TextEditingController(text: '625.00');
  final _savingsController = TextEditingController(text: '150.00');
  final _actionController = TextEditingController(
    text: 'Action: Schedule confidential pre-meeting check-in with borrower B9101 before Wednesday center gathering.',
  );

  int _totalMembers = 6;
  double _peerSavingsDepletedPct = 68.0;
  String _urgency = 'urgent'; // 'urgent', 'watchlist', 'healthy'
  String _causalLabel = 'Contagion-Driven Stress';
  bool _isSubmitting = false;
  String? _successBannerMessage;

  // Raw file paste controller
  final _rawTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groupIdController.dispose();
    _groupNameController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    _anchorBorrowerController.dispose();
    _loanAmountController.dispose();
    _savingsController.dispose();
    _actionController.dispose();
    _rawTextController.dispose();
    super.dispose();
  }

  Color _getGradientColor(double pct) {
    final t = (pct / 100.0).clamp(0.0, 1.0);
    if (t < 0.35) {
      return Color.lerp(const Color(0xFF66BB6A), const Color(0xFFFFA726), t / 0.35)!;
    } else if (t < 0.70) {
      return Color.lerp(const Color(0xFFFFA726), const Color(0xFFE57373), (t - 0.35) / 0.35)!;
    } else {
      return Color.lerp(const Color(0xFFE57373), const Color(0xFFC62828), (t - 0.70) / 0.30)!;
    }
  }

  Future<void> _submitDirectInput() async {
    setState(() => _isSubmitting = true);
    final api = ref.read(apiServiceProvider);

    final groupId = _groupIdController.text.trim().isEmpty ? 'G0188' : _groupIdController.text.trim();
    final anchorBorrower = _anchorBorrowerController.text.trim().isEmpty ? 'B9101' : _anchorBorrowerController.text.trim();
    final groupData = {
      'group_id': groupId,
      'country': _countryController.text.trim().isEmpty ? 'India' : _countryController.text.trim(),
      'region': _regionController.text.trim().isEmpty ? 'Varanasi_R1' : _regionController.text.trim(),
      'total_members': _totalMembers,
      'on_time_repayment_record': 1.0,
      'has_hidden_risk': _urgency != 'healthy',
      'urgency': _urgency,
      'causal_label': _causalLabel,
      'drowning_member_id': anchorBorrower,
      'drowning_member_savings': double.tryParse(_savingsController.text.trim()) ?? 150.0,
      'drowning_member_loan': double.tryParse(_loanAmountController.text.trim()) ?? 625.0,
      'peer_savings_depleted_pct': _peerSavingsDepletedPct,
      'action_recommendation': _actionController.text.trim().isEmpty
          ? 'Action: Confidential pre-meeting check-in with borrower $anchorBorrower before upcoming center gathering.'
          : _actionController.text.trim(),
    };

    await api.importCustomGroups([groupData]);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _successBannerMessage = 'Lending Circle $groupId successfully ingested into active portfolio!';
      });
      // 1. Notify listeners to immediately refresh triage data & AI synthesis
      ref.read(triageRefreshTriggerProvider.notifier).state++;

      // 2. Feedback SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.statusHealthy, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lending Circle $groupId ingested! Running AI Triage...',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.ledgerDark,
          duration: const Duration(seconds: 3),
        ),
      );

      // 3. Seamlessly switch to Field Triage Tab (Tab 1)
      ref.read(lenderTabIndexProvider.notifier).state = 1;
      context.go('/lender?tab=1');
    }
  }

  Future<void> _loadJudgePreset(int presetIndex) async {
    setState(() => _isSubmitting = true);
    final api = ref.read(apiServiceProvider);

    Map<String, dynamic> preset;
    if (presetIndex == 1) {
      preset = {
        'group_id': 'G0188',
        'country': 'India',
        'region': 'Varanasi_R1',
        'total_members': 6,
        'on_time_repayment_record': 1.0,
        'has_hidden_risk': true,
        'urgency': 'urgent',
        'causal_label': 'Contagion-Driven Stress',
        'drowning_member_id': 'B9101',
        'drowning_member_savings': 150.0,
        'drowning_member_loan': 625.0,
        'peer_savings_depleted_pct': 72.0,
        'action_recommendation': 'Action: Pre-meeting check-in with B9101 to prevent joint-liability domino collapse.',
      };
    } else if (presetIndex == 2) {
      preset = {
        'group_id': 'G0341',
        'country': 'India',
        'region': 'Madurai_R2',
        'total_members': 7,
        'on_time_repayment_record': 1.0,
        'has_hidden_risk': true,
        'urgency': 'watchlist',
        'causal_label': 'Isolated Stress',
        'drowning_member_id': 'B9315',
        'drowning_member_savings': 280.0,
        'drowning_member_loan': 750.0,
        'peer_savings_depleted_pct': 30.0,
        'action_recommendation': 'Action: Individual livestock claim consultation. Zero contagion threat to peers.',
      };
    } else {
      preset = {
        'group_id': 'G0402',
        'country': 'Peru',
        'region': 'Cusco_R2',
        'total_members': 6,
        'on_time_repayment_record': 1.0,
        'has_hidden_risk': false,
        'urgency': 'healthy',
        'causal_label': 'Normal Operation',
        'drowning_member_id': 'B9401',
        'drowning_member_savings': 450.0,
        'drowning_member_loan': 600.0,
        'peer_savings_depleted_pct': 0.0,
        'action_recommendation': 'Action: Group operating stably with full mutual savings shield intact.',
      };
    }

    await api.importCustomGroups([preset]);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _successBannerMessage = 'Judge Demo Preset #$presetIndex (${preset['group_id']}) loaded successfully!';
      });
      ref.read(triageRefreshTriggerProvider.notifier).state++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demo Preset (${preset['group_id']}) loaded! Running AI Triage...'),
          backgroundColor: AppColors.ledgerDark,
          duration: const Duration(seconds: 2),
        ),
      );
      ref.read(lenderTabIndexProvider.notifier).state = 1;
      context.go('/lender?tab=1');
    }
  }

  void _navigateToTab(int tabIndex) {
    ref.read(lenderTabIndexProvider.notifier).state = tabIndex;
    context.go('/lender?tab=$tabIndex');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        // 1. Institutional Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.paperRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
            boxShadow: AppColors.cardElevation,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.ledger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.ledger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.input_rounded, size: 14, color: AppColors.ledger),
                        const SizedBox(width: 6),
                        Text(
                          'DATA INGESTION GATEWAY',
                          style: AppTypography.textTheme(AppColors.ledgerDark).labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Live Portfolio Integration • Instant Model Inference',
                      style: TextStyle(fontSize: 11, color: AppColors.inkMuted, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Lending Circle Profile Ingestion',
                style: AppTypography.textTheme(AppColors.ink).titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter lending circle parameters directly, load pre-configured Judge Demo scenarios, or import custom MFI portfolios. Ingested groups are instantly evaluated by the Causal Contagion Engine.',
                style: AppTypography.textTheme(AppColors.inkMuted).bodyMedium,
              ),
              const SizedBox(height: 16),

              // Navigation Quick Pills
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.groups_outlined, size: 16, color: AppColors.ledger),
                    label: const Text('Go to Morning Field Triage Queue →'),
                    onPressed: () => _navigateToTab(1),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.hub_outlined, size: 16, color: AppColors.ledger),
                    label: const Text('Go to Cascade Replay Simulator →'),
                    onPressed: () => _navigateToTab(2),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Success Feedback Banner
        if (_successBannerMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.statusHealthy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.statusHealthy.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.statusHealthy, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _successBannerMessage!,
                    style: AppTypography.textTheme(AppColors.ink).bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToTab(1),
                  child: const Text('View in Triage Queue →', style: TextStyle(color: AppColors.ledgerDark, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 2. Tab Bar for Ingestion Method
        Container(
          decoration: BoxDecoration(
            color: AppColors.paperRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.ledgerDark,
                unselectedLabelColor: AppColors.inkMuted,
                indicatorColor: AppColors.ledger,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.edit_note_rounded), text: 'Direct Parameter Input'),
                  Tab(icon: Icon(Icons.science_outlined), text: 'Judge Demo Presets'),
                  Tab(icon: Icon(Icons.file_upload_outlined), text: 'Upload / Paste File'),
                ],
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 620;
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: isNarrow ? 980 : 680,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDirectInputView(isNarrow),
                          _buildJudgePresetsView(isNarrow),
                          _buildFileUploadView(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 1: Direct Parameter Input Form
  Widget _buildDirectInputView(bool isNarrow) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.app_registration_rounded, size: 18, color: AppColors.ledger),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Direct Group Attributes (No File Required)', style: AppTypography.textTheme(AppColors.ink).titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Specify the exact group metrics that would otherwise be passed via CSV. Ingesting will dynamically update the live queue.',
            style: AppTypography.textTheme(AppColors.inkMuted).bodySmall,
          ),
          const SizedBox(height: 16),

          // Row 1: Group ID & Name
          if (isNarrow) ...[
            _buildTextField(
              label: 'Group ID (e.g. G0188)',
              controller: _groupIdController,
              icon: Icons.tag_rounded,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Lending Circle / Center Name',
              controller: _groupNameController,
              icon: Icons.apartment_rounded,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    label: 'Group ID (e.g. G0188)',
                    controller: _groupIdController,
                    icon: Icons.tag_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    label: 'Lending Circle / Center Name',
                    controller: _groupNameController,
                    icon: Icons.apartment_rounded,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),

          // Row 2: Country & Region
          if (isNarrow) ...[
            _buildTextField(
              label: 'Country',
              controller: _countryController,
              icon: Icons.public_rounded,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'MFI District / Region',
              controller: _regionController,
              icon: Icons.map_outlined,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Country',
                    controller: _countryController,
                    icon: Icons.public_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildTextField(
                    label: 'MFI District / Region',
                    controller: _regionController,
                    icon: Icons.map_outlined,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),

          // Row 3: Members & Anchor Borrower
          if (isNarrow) ...[
            _buildTextField(
              label: 'Anchor Borrower ID',
              controller: _anchorBorrowerController,
              icon: Icons.person_pin_outlined,
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Group Members: $_totalMembers', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                Slider(
                  value: _totalMembers.toDouble(),
                  min: 4,
                  max: 10,
                  divisions: 6,
                  label: '$_totalMembers members',
                  activeColor: AppColors.ledger,
                  onChanged: (v) => setState(() => _totalMembers = v.round()),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Anchor Borrower ID',
                    controller: _anchorBorrowerController,
                    icon: Icons.person_pin_outlined,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Group Members: $_totalMembers', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                      Slider(
                        value: _totalMembers.toDouble(),
                        min: 4,
                        max: 10,
                        divisions: 6,
                        label: '$_totalMembers members',
                        activeColor: AppColors.ledger,
                        onChanged: (v) => setState(() => _totalMembers = v.round()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),

          // Row 4: Loan & Savings (Rupees)
          if (isNarrow) ...[
            _buildTextField(
              label: 'Disbursed Loan Amount (₹)',
              controller: _loanAmountController,
              icon: Icons.currency_rupee_rounded,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Remaining Savings Buffer (₹)',
              controller: _savingsController,
              icon: Icons.savings_outlined,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Disbursed Loan Amount (₹)',
                    controller: _loanAmountController,
                    icon: Icons.currency_rupee_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildTextField(
                    label: 'Remaining Savings Buffer (₹)',
                    controller: _savingsController,
                    icon: Icons.savings_outlined,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),

          // Row 5: Peer Savings Depleted Slider
          Builder(
            builder: (context) {
              final depletionColor = _getGradientColor(_peerSavingsDepletedPct);
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: depletionColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: depletionColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hidden Peer Savings Depletion:', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                        Text(
                          '${_peerSavingsDepletedPct.toStringAsFixed(0)}% Drained',
                          style: AppTypography.figureStyle(
                            size: 13,
                            color: depletionColor,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _peerSavingsDepletedPct,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${_peerSavingsDepletedPct.toStringAsFixed(0)}%',
                      activeColor: depletionColor,
                      onChanged: (v) {
                        setState(() {
                          _peerSavingsDepletedPct = v;
                          if (v > 50) {
                            _urgency = 'urgent';
                            _causalLabel = 'Contagion-Driven Stress';
                          } else if (v > 20) {
                            _urgency = 'watchlist';
                            _causalLabel = 'Isolated Stress';
                          } else {
                            _urgency = 'healthy';
                            _causalLabel = 'Normal Operation';
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Row 6: Urgency & Causal Label
          if (isNarrow) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Urgency Status', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _urgency,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: const [
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent Contagion (Red Alert)')),
                    DropdownMenuItem(value: 'watchlist', child: Text('Watchlist (Isolated Stress)')),
                    DropdownMenuItem(value: 'healthy', child: Text('Healthy (Low Risk)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _urgency = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Causal Shock Category', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _causalLabel,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: const [
                    DropdownMenuItem(value: 'Contagion-Driven Stress', child: Text('Contagion-Driven Stress')),
                    DropdownMenuItem(value: 'Isolated Stress', child: Text('Isolated Household Shock')),
                    DropdownMenuItem(value: 'Independent Regional Shock', child: Text('Regional Macro Shock')),
                    DropdownMenuItem(value: 'Normal Operation', child: Text('Normal Operation')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _causalLabel = v);
                  },
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Urgency Status', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _urgency,
                        decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                        items: const [
                          DropdownMenuItem(value: 'urgent', child: Text('Urgent Contagion (Red Alert)')),
                          DropdownMenuItem(value: 'watchlist', child: Text('Watchlist (Isolated Stress)')),
                          DropdownMenuItem(value: 'healthy', child: Text('Healthy (Low Risk)')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _urgency = v);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Causal Shock Category', style: AppTypography.textTheme(AppColors.ink).labelSmall),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _causalLabel,
                        decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                        items: const [
                          DropdownMenuItem(value: 'Contagion-Driven Stress', child: Text('Contagion-Driven Stress')),
                          DropdownMenuItem(value: 'Isolated Stress', child: Text('Isolated Household Shock')),
                          DropdownMenuItem(value: 'Independent Regional Shock', child: Text('Regional Macro Shock')),
                          DropdownMenuItem(value: 'Normal Operation', child: Text('Normal Operation')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _causalLabel = v);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),

          // Row 7: Action Recommendation
          _buildTextField(
            label: 'Action Recommendation for Loan Officer',
            controller: _actionController,
            icon: Icons.recommend_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitDirectInput,
              icon: _isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(_isSubmitting ? 'Ingesting Group Profile...' : 'Save Group Profile & Run AI Triage'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ledger,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Judge Demo Presets
  Widget _buildJudgePresetsView(bool isNarrow) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, size: 18, color: AppColors.ledger),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Interactive Judge Demo Scenarios', style: AppTypography.textTheme(AppColors.ink).titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'One-click demonstrative scenarios crafted to show judges how Kerdos detects hidden co-liability contagion before standard ledgers.',
            style: AppTypography.textTheme(AppColors.inkMuted).bodySmall,
          ),
          const SizedBox(height: 16),

          // Demo Preset 1
          _buildJudgePresetCard(
            presetNumber: 1,
            title: 'Varanasi Weavers Co-Liability Contagion (Circle G0188)',
            badgeText: 'CRITICAL CASCADE',
            badgeColor: AppColors.statusContagion,
            description:
                '6-member silk weaving solidarity group. Anchor borrower B9101 suffers loom breakdown (-60% cash flow). Group members have secretly drained 72% of personal savings to cover installments. Standard bank ledger shows 100% on-time, but circle will collapse in 2 weeks.',
            impactMetric: '72% Peer Savings Drained • Imminent Domino Default',
            onLoad: () => _loadJudgePreset(1),
          ),
          const SizedBox(height: 12),

          // Demo Preset 2
          _buildJudgePresetCard(
            presetNumber: 2,
            title: 'Madurai Dairy Circle Isolated Shock (Circle G0341)',
            badgeText: 'WATCHLIST ISOLATED',
            badgeColor: AppColors.statusIsolated,
            description:
                '7-member dairy collective. Member B9315 incurred medical expense for livestock treatment. Group solidarity shield absorbed 30% without distress. Peer contagion coefficient is 0.02. AI recommends isolated grant, preserving group autonomy.',
            impactMetric: '30% Buffer Used • Zero Contagion Threat to Peers',
            onLoad: () => _loadJudgePreset(2),
          ),
          const SizedBox(height: 12),

          // Demo Preset 3
          _buildJudgePresetCard(
            presetNumber: 3,
            title: 'Cusco Agricultural Cooperative (Circle G0402)',
            badgeText: 'HEALTHY BASELINE',
            badgeColor: AppColors.statusHealthy,
            description:
                '6-member organic potato farming collective. 100% mutual savings intact (₹450 buffer per member). Zero hidden distress. Demonstrates baseline stability in the causal engine.',
            impactMetric: '100% Mutual Reserve Intact • Safe Baseline',
            onLoad: () => _loadJudgePreset(3),
          ),
        ],
      ),
    );
  }

  // TAB 3: Upload / Paste File View
  Widget _buildFileUploadView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.file_present_rounded, size: 18, color: AppColors.ledger),
              const SizedBox(width: 8),
              Text('Batch Ingestion via CSV or JSON', style: AppTypography.textTheme(AppColors.ink).titleMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Paste CSV rows or a JSON array below to import batch lending circles into the platform.',
            style: AppTypography.textTheme(AppColors.inkMuted).bodySmall,
          ),
          const SizedBox(height: 12),

          // Sample template quick fill buttons
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.description_outlined, size: 14),
                label: const Text('Load Sample CSV Template', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  _rawTextController.text =
                      'group_id,country,region,total_members,on_time_repayment_record,has_hidden_risk,urgency,causal_label,drowning_member_id,drowning_member_savings,drowning_member_loan,peer_savings_depleted_pct,action_recommendation\n'
                      'G0188,India,Varanasi_R1,6,1.0,true,urgent,Contagion-Driven Stress,B9101,150.0,625.0,72.0,"Action: Pre-meeting check-in with B9101 to prevent contagion default."\n'
                      'G0299,India,Kolar_R3,5,1.0,true,urgent,Contagion-Driven Stress,B9204,120.0,500.0,65.0,"Action: Emergency liquidity buffer grant recommended."\n'
                      'G0341,India,Madurai_R2,7,1.0,true,watchlist,Isolated Stress,B9315,280.0,750.0,30.0,"Action: Individual livestock claim consultation."';
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.code_rounded, size: 14),
                label: const Text('Load Sample JSON Template', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  _rawTextController.text = jsonEncode([
                    {
                      'group_id': 'G0188',
                      'country': 'India',
                      'region': 'Varanasi_R1',
                      'total_members': 6,
                      'on_time_repayment_record': 1.0,
                      'has_hidden_risk': true,
                      'urgency': 'urgent',
                      'causal_label': 'Contagion-Driven Stress',
                      'drowning_member_id': 'B9101',
                      'drowning_member_savings': 150.0,
                      'drowning_member_loan': 625.0,
                      'peer_savings_depleted_pct': 72.0,
                      'action_recommendation': 'Action: Pre-meeting check-in with B9101.',
                    }
                  ]);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Raw input area
          TextField(
            controller: _rawTextController,
            maxLines: 10,
            style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 11.5),
            decoration: const InputDecoration(
              hintText: 'Paste CSV or JSON formatted group records here...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),

          // Parse & Ingest Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final text = _rawTextController.text.trim();
                if (text.isEmpty) return;

                List<Map<String, dynamic>> items = [];
                if (text.startsWith('[') || text.startsWith('{')) {
                  try {
                    final decoded = jsonDecode(text);
                    if (decoded is List) {
                      items = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
                    } else if (decoded is Map) {
                      items = [Map<String, dynamic>.from(decoded)];
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid JSON format: $e')));
                    return;
                  }
                } else {
                  // CSV parser
                  final lines = text.split('\n');
                  if (lines.length > 1) {
                    final headers = lines[0].split(',').map((h) => h.trim()).toList();
                    for (int i = 1; i < lines.length; i++) {
                      if (lines[i].trim().isEmpty) continue;
                      final cols = lines[i].split(',').map((c) => c.trim().replaceAll('"', '')).toList();
                      if (cols.length >= headers.length) {
                        final map = <String, dynamic>{};
                        for (int h = 0; h < headers.length; h++) {
                          map[headers[h]] = cols[h];
                        }
                        items.add(map);
                      }
                    }
                  }
                }

                if (items.isNotEmpty) {
                  final api = ref.read(apiServiceProvider);
                  await api.importCustomGroups(items);
                  if (!mounted) return;
                  setState(() {
                    _successBannerMessage = 'Successfully ingested ${items.length} custom lending circles into active portfolio!';
                  });
                  ref.read(triageRefreshTriggerProvider.notifier).state++;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ingested ${items.length} custom circles! Running AI Triage...'),
                      backgroundColor: AppColors.ledgerDark,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  ref.read(lenderTabIndexProvider.notifier).state = 1;
                  context.go('/lender?tab=1');
                }
              },
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: const Text('Parse & Ingest Custom Records into Live Portfolio'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.ledger, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJudgePresetCard({
    required int presetNumber,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required String description,
    required String impactMetric,
    required VoidCallback onLoad,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.hairline),
        boxShadow: AppColors.cardElevation,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor),
                ),
              ),
              FilledButton.icon(
                onPressed: onLoad,
                icon: const Icon(Icons.bolt_rounded, size: 14),
                label: const Text('Load Demo', style: TextStyle(fontSize: 11)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ledger,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.textTheme(AppColors.ink).labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(description, style: AppTypography.textTheme(AppColors.inkMuted).bodySmall),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.analytics_outlined, size: 14, color: AppColors.ledger),
              const SizedBox(width: 6),
              Expanded(
                child: Text(impactMetric, style: AppTypography.figureStyle(size: 11, color: badgeColor, weight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.textTheme(AppColors.ink).labelSmall),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.textTheme(AppColors.ink).bodyMedium,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.inkMuted),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
