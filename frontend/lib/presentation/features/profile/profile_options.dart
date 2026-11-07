import 'package:flutter/material.dart';
import 'package:staki_mobile/domain/entities/borrower_type.dart';

/// Option lists and per-type copy for Section 02 (from the Figma frames).
abstract final class ProfileOptions {
  static const businessTypes = [
    'Retail / Trade',
    'Agriculture',
    'Food & Hospitality',
    'Services',
    'Manufacturing',
    'Transport',
    'Tech / Digital',
    'Other',
  ];
  static const yearsOperating = [
    'Less than 1 year',
    '1-2 years',
    '2-5 years',
    '5-10 years',
    '10+ years',
  ];
  static const businessRevenue = [
    'Under 100K',
    '100K-500K',
    '500K-1M',
    '1M-5M',
    'Over 5M',
  ];
  static const startupStages = [
    'Idea stage',
    'MVP built',
    'Early traction',
    'Revenue generating',
    'Growth stage',
  ];
  static const startupActivities = [
    'Software / App',
    'E-commerce',
    'AgriTech',
    'FinTech',
    'EdTech',
    'HealthTech',
    'Logistics',
    'Other',
  ];
  static const operatingHistory = [
    'Less than 6 months',
    '6-12 months',
    '1-2 years',
    '2-4 years',
    '4+ years',
  ];
  static const startupRevenue = [
    'Pre-revenue',
    'Under 100K',
    '100K-500K',
    '500K-1M',
    '1M-5M',
    'Over 5M',
  ];
  static const studyLevels = [
    'Certificate / Diploma',
    "Bachelor's degree",
    "Master's degree",
    'PhD',
    'Vocational / TVET',
  ];
  static const enrollment = ['Full-time', 'Part-time', 'Distance learning'];
  static const incomeSources = [
    'Family / guardian',
    'Scholarship / bursary',
    'Part-time work',
    'Government grant',
    'Self-funded savings',
  ];
  static const studentIncome = [
    'Under 30K RWF',
    '30K-80K RWF',
    '80K-150K RWF',
    '150K-300K RWF',
    'Over 300K RWF',
  ];

  // P30_SalaryEmployment / P31_SalaryIncome
  static const employmentTypes = [
    'Full-time permanent',
    'Full-time contract',
    'Part-time',
    'Civil servant',
    'NGO / INGO',
  ];
  static const salaryRanges = [
    'Under 100K RWF',
    '100K–300K RWF',
    '300K–600K RWF',
    '600K–1M RWF',
    'Over 1M RWF',
  ];
  static const tenures = [
    'Less than 6 months',
    '6–12 months',
    '1–3 years',
    '3–5 years',
    'Over 5 years',
  ];

  // P40_OtherInfo
  static const occupations = [
    'Freelancer',
    'Farmer / Agriculture',
    'Gig worker',
    'Informal trader',
    'Artist / Creative',
    'Religious / Community',
    'Unemployed / Seeking work',
  ];
  static const otherIncomes = [
    'No regular income',
    'Under 100K',
    '100K–500K',
    '500K–1M',
  ];

  /// Total steps in the progress header per borrower type (P01 is step 1).
  /// Read from the Figma frames: business 5, startup 4, student 4,
  /// salaried 4, other 3. The last step of each flow is P05_Review.
  static int totalSteps(BorrowerType? type) => switch (type) {
        BorrowerType.business || null => 5,
        BorrowerType.startup => 4,
        BorrowerType.student => 4,
        BorrowerType.salaried => 4,
        BorrowerType.other => 3,
      };

  static String title(BorrowerType type) => switch (type) {
        BorrowerType.business => 'Business owner',
        BorrowerType.startup => 'Startup founder',
        BorrowerType.student => 'Student',
        BorrowerType.salaried => 'Salaried professional',
        BorrowerType.other => 'Other',
      };

  static String subtitle(BorrowerType type) => switch (type) {
        BorrowerType.business => 'Running an existing SME or micro-business',
        BorrowerType.startup => 'Early-stage or growth-phase venture',
        BorrowerType.student => 'University, college or vocational training',
        BorrowerType.salaried =>
          'Employed full-time or part-time with a payslip',
        BorrowerType.other =>
          'Freelancer, farmer, gig worker or informal sector',
      };

  static IconData icon(BorrowerType type) => switch (type) {
        BorrowerType.business => Icons.storefront_outlined,
        BorrowerType.startup => Icons.rocket_launch_outlined,
        BorrowerType.student => Icons.school_outlined,
        BorrowerType.salaried => Icons.badge_outlined,
        BorrowerType.other => Icons.person_outline,
      };
}
