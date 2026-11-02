import 'package:flutter/material.dart';

// TEMP: replace with domain entities once the backend team publishes them.

enum AssessmentStatus { processing, needsInfo, complete, failed }

enum CheckState { done, active, pending }

enum ScoreBand { poor, fair, good, veryGood, exceptional }

class DataCheck {
  const DataCheck(this.label, this.state);

  final String label;
  final CheckState state;
}

class NeedsInfoIssue {
  const NeedsInfoIssue({required this.documentName, required this.message});

  final String documentName;
  final String message;
}

class ScoreFactor {
  const ScoreFactor({
    required this.title,
    required this.levelLabel,
    required this.progress,
    required this.summary,
    required this.helped,
    required this.improve,
    required this.icon,
  });

  final String title;
  final String levelLabel;
  final double progress; // 0.0 to 1.0
  final String summary;
  final String helped;
  final String improve;
  final IconData icon;
}

class CreditScore {
  const CreditScore({
    required this.value,
    required this.updatedLabel,
    required this.factors,
  });

  final int value; // 300 to 1000
  final String updatedLabel;
  final List<ScoreFactor> factors;

  /// Bands from the team plan: 300-579, 580-669, 670-739, 740-799, 800-1000.
  ScoreBand get band {
    if (value < 580) return ScoreBand.poor;
    if (value < 670) return ScoreBand.fair;
    if (value < 740) return ScoreBand.good;
    if (value < 800) return ScoreBand.veryGood;
    return ScoreBand.exceptional;
  }

  /// Figma shows "STRONG" for 780, which the plan calls Very Good.
  /// Confirm the final wording with Abdull-Kudus; change it only here.
  String get bandLabel {
    switch (band) {
      case ScoreBand.poor:
        return 'POOR';
      case ScoreBand.fair:
        return 'FAIR';
      case ScoreBand.good:
        return 'GOOD';
      case ScoreBand.veryGood:
        return 'STRONG';
      case ScoreBand.exceptional:
        return 'EXCEPTIONAL';
    }
  }
}
