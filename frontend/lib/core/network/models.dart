import 'package:flutter/foundation.dart';

/// Typed models for Kerdos API payloads and offline data.

@immutable
class PortfolioSummary {
  const PortfolioSummary({
    required this.totalExposure,
    required this.activeLoans,
    required this.par30,
    required this.par60,
    required this.par90,
    required this.parChangePercentage,
    required this.isolatedStressPct,
    required this.contagionSpreadPct,
    required this.regionalShockPct,
    required this.neighborCoef,
    required this.neighborPval,
    required this.regionalCoef,
    required this.regionalPval,
    required this.historicalTrendline,
  });

  final double totalExposure;
  final int activeLoans;
  final double par30;
  final double par60;
  final double par90;
  final double parChangePercentage;
  final double isolatedStressPct;
  final double contagionSpreadPct;
  final double regionalShockPct;
  final double neighborCoef;
  final double neighborPval;
  final double regionalCoef;
  final double regionalPval;
  final List<TrendPoint> historicalTrendline;

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    final causal = json['causal_breakdown'] as Map<String, dynamic>? ?? {};
    final explainer = causal['explainer_model'] as Map<String, dynamic>? ?? {};
    final trendRaw = json['historical_trendline'] as List<dynamic>? ?? [];

    return PortfolioSummary(
      totalExposure: (json['total_exposure'] as num?)?.toDouble() ?? 1656550.0,
      activeLoans: (json['active_loans'] as num?)?.toInt() ?? 2000,
      par30: (json['par30'] as num?)?.toDouble() ?? 0.042,
      par60: (json['par60'] as num?)?.toDouble() ?? 0.028,
      par90: (json['par90'] as num?)?.toDouble() ?? 0.014,
      parChangePercentage: (json['par_change_percentage'] as num?)?.toDouble() ?? -0.6,
      isolatedStressPct: (causal['isolated_stress_percentage'] as num?)?.toDouble() ?? 35.0,
      contagionSpreadPct: (causal['contagion_spread_percentage'] as num?)?.toDouble() ?? 42.0,
      regionalShockPct: (causal['regional_shock_percentage'] as num?)?.toDouble() ?? 23.0,
      neighborCoef: (explainer['neighbor_coef'] as num?)?.toDouble() ?? 1.345,
      neighborPval: (explainer['neighbor_pval'] as num?)?.toDouble() ?? 2.2e-19,
      regionalCoef: (explainer['regional_coef'] as num?)?.toDouble() ?? 1.261,
      regionalPval: (explainer['regional_pval'] as num?)?.toDouble() ?? 8.6e-48,
      historicalTrendline: trendRaw
          .map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

@immutable
class TrendPoint {
  const TrendPoint({required this.t, required this.par});
  final int t;
  final double par;

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      t: (json['t'] as num?)?.toInt() ?? 0,
      par: (json['par'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

@immutable
class GroupTriageItem {
  const GroupTriageItem({
    required this.groupId,
    required this.country,
    required this.region,
    required this.totalMembers,
    required this.onTimeRepaymentRecord,
    required this.hasHiddenRisk,
    required this.urgency,
    required this.causalLabel,
    required this.drowningMemberId,
    required this.drowningMemberSavings,
    required this.drowningMemberLoan,
    required this.peerSavingsDepletedPct,
    required this.actionRecommendation,
  });

  final String groupId;
  final String country;
  final String region;
  final int totalMembers;
  final double onTimeRepaymentRecord;
  final bool hasHiddenRisk;
  final String urgency;
  final String causalLabel;
  final String drowningMemberId;
  final double drowningMemberSavings;
  final double drowningMemberLoan;
  final double peerSavingsDepletedPct;
  final String actionRecommendation;

  factory GroupTriageItem.fromJson(Map<String, dynamic> json) {
    return GroupTriageItem(
      groupId: json['group_id'] as String? ?? '',
      country: json['country'] as String? ?? 'Peru',
      region: json['region'] as String? ?? 'Cusco',
      totalMembers: (json['total_members'] as num?)?.toInt() ?? 6,
      onTimeRepaymentRecord: (json['on_time_repayment_record'] as num?)?.toDouble() ?? 1.0,
      hasHiddenRisk: json['has_hidden_risk'] as bool? ?? false,
      urgency: json['urgency'] as String? ?? 'healthy',
      causalLabel: json['causal_label'] as String? ?? 'Healthy',
      drowningMemberId: json['drowning_member_id'] as String? ?? 'B0058',
      drowningMemberSavings: (json['drowning_member_savings'] as num?)?.toDouble() ?? 200.0,
      drowningMemberLoan: (json['drowning_member_loan'] as num?)?.toDouble() ?? 600.0,
      peerSavingsDepletedPct: (json['peer_savings_depleted_pct'] as num?)?.toDouble() ?? 0.0,
      actionRecommendation: json['action_recommendation'] as String? ?? '',
    );
  }
}

@immutable
class AiTriageOverview {
  const AiTriageOverview({
    required this.headline,
    required this.summary,
    required this.keyAction,
    required this.urgencyLevel,
    required this.activeGroupsCount,
    required this.criticalGroupsCount,
    required this.highestRiskCircle,
    required this.anchorBorrower,
    required this.generatedAt,
    required this.confidenceScore,
  });

  final String headline;
  final String summary;
  final String keyAction;
  final String urgencyLevel;
  final int activeGroupsCount;
  final int criticalGroupsCount;
  final String highestRiskCircle;
  final String anchorBorrower;
  final String generatedAt;
  final double confidenceScore;

  factory AiTriageOverview.fromJson(Map<String, dynamic> json) {
    return AiTriageOverview(
      headline: json['headline'] as String? ?? 'Morning Portfolio Brief',
      summary: json['summary'] as String? ?? 'AI causal engine active.',
      keyAction: json['key_action'] as String? ?? 'Maintain standard monitoring.',
      urgencyLevel: json['urgency_level'] as String? ?? 'all',
      activeGroupsCount: (json['active_groups_count'] as num?)?.toInt() ?? 7,
      criticalGroupsCount: (json['critical_groups_count'] as num?)?.toInt() ?? 4,
      highestRiskCircle: json['highest_risk_circle'] as String? ?? 'G0107',
      anchorBorrower: json['anchor_borrower'] as String? ?? 'B0058',
      generatedAt: json['generated_at'] as String? ?? 'Just now • Causal AI Inference',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.94,
    );
  }
}

@immutable
class BorrowerMember {
  const BorrowerMember({
    required this.borrowerId,
    required this.loanAmount,
    required this.termMonths,
    required this.repaymentInterval,
    required this.currentSavings,
    required this.isStressed,
    required this.stressReason,
    required this.individualRiskScore,
  });

  final String borrowerId;
  final double loanAmount;
  final int termMonths;
  final String repaymentInterval;
  final double currentSavings;
  final int isStressed;
  final String stressReason;
  final double individualRiskScore;

  factory BorrowerMember.fromJson(Map<String, dynamic> json) {
    return BorrowerMember(
      borrowerId: json['borrower_id'] as String? ?? '',
      loanAmount: (json['loan_amount'] as num?)?.toDouble() ?? 600.0,
      termMonths: (json['term_months'] as num?)?.toInt() ?? 12,
      repaymentInterval: json['repayment_interval'] as String? ?? 'monthly',
      currentSavings: (json['current_savings'] as num?)?.toDouble() ?? 200.0,
      isStressed: (json['is_stressed'] as num?)?.toInt() ?? 0,
      stressReason: json['stress_reason'] as String? ?? 'Healthy',
      individualRiskScore: (json['individual_risk_score'] as num?)?.toDouble() ?? 0.04,
    );
  }
}

@immutable
class GraphPayload {
  const GraphPayload({
    required this.nodes,
    required this.edges,
    required this.edgeTypesAvailable,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final List<String> edgeTypesAvailable;

  factory GraphPayload.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as List<dynamic>? ?? [];
    final rawEdges = json['edges'] as List<dynamic>? ?? [];
    final rawTypes = json['edge_types_available'] as List<dynamic>? ?? ['group', 'partner', 'region'];

    return GraphPayload(
      nodes: rawNodes.map((e) => GraphNode.fromJson(e as Map<String, dynamic>)).toList(),
      edges: rawEdges.map((e) => GraphEdge.fromJson(e as Map<String, dynamic>)).toList(),
      edgeTypesAvailable: rawTypes.map((e) => e.toString()).toList(),
    );
  }
}

@immutable
class GraphNode {
  const GraphNode({
    required this.id,
    required this.groupId,
    required this.x,
    required this.y,
    required this.isStressed,
    required this.state,
    required this.reason,
    required this.loanAmount,
    required this.savings,
  });

  final String id;
  final String groupId;
  final double x;
  final double y;
  final int isStressed;
  final int state;
  final String reason;
  final double loanAmount;
  final double savings;

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      id: json['id'] as String? ?? '',
      groupId: json['group_id'] as String? ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 0.5,
      y: (json['y'] as num?)?.toDouble() ?? 0.5,
      isStressed: (json['is_stressed'] as num?)?.toInt() ?? 0,
      state: (json['state'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? 'Healthy',
      loanAmount: (json['loan_amount'] as num?)?.toDouble() ?? 500.0,
      savings: (json['savings'] as num?)?.toDouble() ?? 200.0,
    );
  }
}

@immutable
class GraphEdge {
  const GraphEdge({
    required this.source,
    required this.target,
    required this.weight,
    required this.edgeType,
  });

  final String source;
  final String target;
  final double weight;
  final String edgeType;

  factory GraphEdge.fromJson(Map<String, dynamic> json) {
    return GraphEdge(
      source: json['source'] as String? ?? '',
      target: json['target'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      edgeType: json['edge_type'] as String? ?? 'group',
    );
  }
}

@immutable
class SimulationPanelPayload {
  const SimulationPanelPayload({required this.timesteps});
  final List<TimestepSnapshot> timesteps;

  factory SimulationPanelPayload.fromJson(Map<String, dynamic> json) {
    final raw = json['timesteps'] as List<dynamic>? ?? [];
    return SimulationPanelPayload(
      timesteps: raw.map((e) => TimestepSnapshot.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

@immutable
class TimestepSnapshot {
  const TimestepSnapshot({
    required this.t,
    required this.totalStressed,
    required this.nodeStates,
  });

  final int t;
  final int totalStressed;
  final Map<String, int> nodeStates;

  factory TimestepSnapshot.fromJson(Map<String, dynamic> json) {
    final rawStates = json['node_states'] as Map<String, dynamic>? ?? {};
    final states = <String, int>{};
    rawStates.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        states[k] = (v['state'] as num?)?.toInt() ?? 0;
      } else if (v is num) {
        states[k] = v.toInt();
      }
    });

    return TimestepSnapshot(
      t: (json['t'] as num?)?.toInt() ?? 0,
      totalStressed: (json['total_stressed'] as num?)?.toInt() ?? 0,
      nodeStates: states,
    );
  }
}

@immutable
class BorrowerProfile {
  const BorrowerProfile({
    required this.borrowerId,
    required this.groupId,
    required this.loanAmount,
    required this.remainingBalance,
    required this.nextInstallmentAmount,
    required this.nextInstallmentDueDays,
    required this.currentSavings,
    required this.repaymentStreakWeeks,
    required this.repaymentInterval,
    required this.hardshipEligible,
  });

  final String borrowerId;
  final String groupId;
  final double loanAmount;
  final double remainingBalance;
  final double nextInstallmentAmount;
  final int nextInstallmentDueDays;
  final double currentSavings;
  final int repaymentStreakWeeks;
  final String repaymentInterval;
  final bool hardshipEligible;

  factory BorrowerProfile.fromJson(Map<String, dynamic> json) {
    return BorrowerProfile(
      borrowerId: json['borrower_id'] as String? ?? 'B0058',
      groupId: json['group_id'] as String? ?? 'G0107',
      loanAmount: (json['loan_amount'] as num?)?.toDouble() ?? 625.0,
      remainingBalance: (json['remaining_balance'] as num?)?.toDouble() ?? 343.75,
      nextInstallmentAmount: (json['next_installment_amount'] as num?)?.toDouble() ?? 11.16,
      nextInstallmentDueDays: (json['next_installment_due_days'] as num?)?.toInt() ?? 4,
      currentSavings: (json['current_savings'] as num?)?.toDouble() ?? 203.64,
      repaymentStreakWeeks: (json['repayment_streak_weeks'] as num?)?.toInt() ?? 18,
      repaymentInterval: json['repayment_interval'] as String? ?? 'monthly',
      hardshipEligible: json['hardship_eligible'] as bool? ?? true,
    );
  }
}

@immutable
class GroupMilestones {
  const GroupMilestones({
    required this.groupId,
    required this.groupName,
    required this.completedOnTimeMeetings,
    required this.collectiveSavingsShield,
    required this.nextMeetingDatetime,
    required this.nextMeetingLocation,
    required this.loanOfficerName,
    required this.officerPhone,
    required this.peerPrivacyGuarantee,
  });

  final String groupId;
  final String groupName;
  final int completedOnTimeMeetings;
  final String collectiveSavingsShield;
  final String nextMeetingDatetime;
  final String nextMeetingLocation;
  final String loanOfficerName;
  final String officerPhone;
  final String peerPrivacyGuarantee;

  factory GroupMilestones.fromJson(Map<String, dynamic> json) {
    return GroupMilestones(
      groupId: json['group_id'] as String? ?? 'G0107',
      groupName: json['group_name'] as String? ?? 'Solidarity Circle G0107',
      completedOnTimeMeetings: (json['completed_on_time_meetings'] as num?)?.toInt() ?? 18,
      collectiveSavingsShield: json['collective_savings_shield'] as String? ?? '₹1,420.00',
      nextMeetingDatetime: json['next_meeting_datetime'] as String? ?? 'Thursday, 10:00 AM',
      nextMeetingLocation: json['next_meeting_location'] as String? ?? 'Community Center Hall, West Wing',
      loanOfficerName: json['loan_officer_name'] as String? ?? 'Maria Santos',
      officerPhone: json['officer_phone'] as String? ?? '+1-800-KERDOS-01',
      peerPrivacyGuarantee: json['peer_privacy_guarantee'] as String? ?? 'Peer repayment status is strictly confidential and protected.',
    );
  }
}

@immutable
class FairnessAuditReport {
  const FairnessAuditReport({
    required this.auditPeriod,
    required this.excludedAttributes,
    required this.disparateImpactThreshold,
    required this.minParityRatioObserved,
    required this.status,
    required this.regions,
  });

  final String auditPeriod;
  final List<String> excludedAttributes;
  final double disparateImpactThreshold;
  final double minParityRatioObserved;
  final String status;
  final List<RegionAuditRow> regions;

  factory FairnessAuditReport.fromJson(Map<String, dynamic> json) {
    final rawRegions = json['regions'] as List<dynamic>? ?? [];
    final rawAttr = json['excluded_sensitive_attributes'] as List<dynamic>? ?? [];

    return FairnessAuditReport(
      auditPeriod: json['audit_period'] as String? ?? '2026-Q1',
      excludedAttributes: rawAttr.map((e) => e.toString()).toList(),
      disparateImpactThreshold: (json['disparate_impact_threshold'] as num?)?.toDouble() ?? 0.80,
      minParityRatioObserved: (json['min_parity_ratio_observed'] as num?)?.toDouble() ?? 0.95,
      status: json['status'] as String? ?? 'COMPLIANT_ZERO_BIAS',
      regions: rawRegions.map((e) => RegionAuditRow.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

@immutable
class RegionAuditRow {
  const RegionAuditRow({
    required this.region,
    required this.activeLoans,
    required this.flaggedCases,
    required this.flagRate,
    required this.parityRatio,
  });

  final String region;
  final int activeLoans;
  final int flaggedCases;
  final double flagRate;
  final double parityRatio;

  factory RegionAuditRow.fromJson(Map<String, dynamic> json) {
    return RegionAuditRow(
      region: json['region'] as String? ?? '',
      activeLoans: (json['active_loans'] as num?)?.toInt() ?? 0,
      flaggedCases: (json['flagged_cases'] as num?)?.toInt() ?? 0,
      flagRate: (json['flag_rate'] as num?)?.toDouble() ?? 0.0,
      parityRatio: (json['parity_ratio'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
