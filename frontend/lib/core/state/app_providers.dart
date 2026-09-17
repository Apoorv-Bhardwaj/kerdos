import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The two entry points into the product. Selecting one drives routing
/// into the matching portal shell.
enum PortalType { lender, borrower }

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

final selectedPortalProvider = StateProvider<PortalType?>((ref) => null);

/// Active tab index inside whichever portal shell is on screen.
final lenderTabIndexProvider = StateProvider<int>((ref) => 0);

final borrowerTabIndexProvider = StateProvider<int>((ref) => 0);

/// Trigger counter incremented whenever new group profiles are ingested,
/// prompting FieldTriageTab and AiOverviewCard to re-fetch and re-run AI triage.
final triageRefreshTriggerProvider = StateProvider<int>((ref) => 0);