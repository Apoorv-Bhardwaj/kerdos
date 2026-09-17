import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kerdos/core/network/api_service.dart';
import 'package:kerdos/core/network/models.dart';
import 'package:kerdos/core/state/app_providers.dart';
import 'package:kerdos/core/theme/app_colors.dart';
import 'package:kerdos/core/theme/app_typography.dart';

/// Executive AI Overview Card for Field Triage.
/// Displays an animated writing / typewriter synthesis of current portfolio risk,
/// summarizing the hidden co-liability reality and key pre-meeting field actions.
class AiOverviewCard extends ConsumerStatefulWidget {
  const AiOverviewCard({
    super.key,
    required this.selectedUrgency,
  });

  final String selectedUrgency;

  @override
  ConsumerState<AiOverviewCard> createState() => _AiOverviewCardState();
}

class _AiOverviewCardState extends ConsumerState<AiOverviewCard> with SingleTickerProviderStateMixin {
  AiTriageOverview? _overview;
  bool _isLoading = true;

  // Typewriter animation state
  String _displayedSummary = '';
  Timer? _typewriterTimer;
  int _charIndex = 0;
  bool _isTyping = false;

  // Pulse animation for cursor
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _fetchOverview();
  }

  @override
  void didUpdateWidget(covariant AiOverviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedUrgency != widget.selectedUrgency) {
      _fetchOverview();
    }
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  Future<void> _fetchOverview() async {
    setState(() {
      _isLoading = true;
      _displayedSummary = '';
      _charIndex = 0;
    });

    final api = ref.read(apiServiceProvider);
    final data = await api.getTriageAiOverview(urgency: widget.selectedUrgency);

    if (mounted) {
      setState(() {
        _overview = data;
        _isLoading = false;
      });
      _startTypewriterAnimation(data.summary);
    }
  }

  void _startTypewriterAnimation(String fullText) {
    _typewriterTimer?.cancel();
    _charIndex = 0;
    _displayedSummary = '';
    _isTyping = true;

    // Fast typewriter typing speed (14ms per character)
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 14), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex < fullText.length) {
        setState(() {
          _charIndex++;
          _displayedSummary = fullText.substring(0, _charIndex);
        });
      } else {
        setState(() {
          _isTyping = false;
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(triageRefreshTriggerProvider, (previous, next) {
      if (previous != next) {
        _fetchOverview();
      }
    });

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.paperRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.hairline),
          boxShadow: AppColors.cardElevation,
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ledger),
            ),
            const SizedBox(width: 12),
            Text(
              'Synthesizing live causal triage overview...',
              style: AppTypography.textTheme(AppColors.inkMuted).bodyMedium,
            ),
          ],
        ),
      );
    }

    final data = _overview!;
    final isUrgent = widget.selectedUrgency == 'urgent';
    final isWatchlist = widget.selectedUrgency == 'watchlist';
    final accentColor = isUrgent
        ? AppColors.statusContagion
        : (isWatchlist ? AppColors.statusIsolated : AppColors.ledger);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.paperRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          ...AppColors.cardElevation,
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Header Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.15),
                          AppColors.ledger.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: accentColor.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 14, color: accentColor),
                        const SizedBox(width: 6),
                        Text(
                          'AI PORTFOLIO SYNTHESIS',
                          style: AppTypography.textTheme(accentColor).labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                fontSize: 10.5,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 12, color: AppColors.statusHealthy),
                        const SizedBox(width: 4),
                        Text(
                          '${(data.confidenceScore * 100).toInt()}% Causal Confidence',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.generatedAt,
                    style: const TextStyle(fontSize: 11, color: AppColors.inkMuted, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.inkMuted),
                    tooltip: 'Regenerate AI Synthesis',
                    onPressed: _fetchOverview,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dynamic Headline
          Text(
            data.headline,
            style: AppTypography.textTheme(AppColors.ink).titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
          ),
          const SizedBox(height: 10),

          // Animated Typewriter Summary Body
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _displayedSummary,
                          style: AppTypography.textTheme(AppColors.ink).bodyMedium?.copyWith(
                                height: 1.5,
                                fontSize: 13,
                              ),
                        ),
                        if (_isTyping)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: FadeTransition(
                              opacity: _cursorController,
                              child: Container(
                                width: 2,
                                height: 15,
                                margin: const EdgeInsets.only(left: 2),
                                color: accentColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Key Recommended Action Callout Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.ledger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.ledger.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 18, color: AppColors.ledger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.keyAction,
                    style: AppTypography.textTheme(AppColors.ledgerDark).bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
