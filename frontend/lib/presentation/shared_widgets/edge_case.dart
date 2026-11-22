import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';

/// Colour family of an edge-case icon tile (from the Figma tints).
enum EdgeCaseTone { error, warning, info, neutral }

/// The 34 edge cases in the Figma Edge Case Library, E01 to E34.
enum EdgeCaseType {
  loading,
  skeleton,
  emptyState,
  offline,
  poorNetwork,
  sessionExpired,
  otpExpired,
  wrongOtp,
  invalidPhone,
  incorrectPin,
  forgotPin,
  momoFailed,
  momoUnavailable,
  momoNotEligible,
  insufficientHistory,
  docUploadFailed,
  poorDocQuality,
  docRejected,
  identityFailed,
  kycIncomplete,
  kycRejected,
  assessmentDelayed,
  assessmentFailed,
  scoreUnavailable,
  loanIncomplete,
  loanDeclined,
  offerExpired,
  disbursementDelayed,
  repaymentFailed,
  repaymentOverdue,
  fundingUnavailable,
  insufficientBalance,
  noOpportunities,
  opportunityFullyFunded,
}

class EdgeCaseContent {
  const EdgeCaseContent({
    required this.code,
    required this.tone,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.secondaryLabel,
  });

  final String code;
  final EdgeCaseTone tone;
  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final String? secondaryLabel;
}

extension EdgeCaseTypeContent on EdgeCaseType {
  EdgeCaseContent get content => _contents[this]!;
}

// Copy, tones and button labels are taken from the Figma frames.
// Icons are Material stand-ins; swap for the exported Figma icons later.
const Map<EdgeCaseType, EdgeCaseContent> _contents = {
  EdgeCaseType.loading: EdgeCaseContent(
    code: 'E01',
    tone: EdgeCaseTone.info,
    icon: AppIcons.hourglass,
    title: 'Processing securely',
    message: 'Please wait a moment while we retrieve your information.',
  ),
  EdgeCaseType.skeleton: EdgeCaseContent(
    code: 'E02',
    tone: EdgeCaseTone.neutral,
    icon: AppIcons.rows,
    title: 'Loading',
    message: '',
  ),
  EdgeCaseType.emptyState: EdgeCaseContent(
    code: 'E03',
    tone: EdgeCaseTone.neutral,
    icon: AppIcons.tray,
    title: 'Nothing to display yet',
    message: 'There are no active records to show right now. Check '
        'back later or start a new application.',
    primaryLabel: 'Refresh page',
  ),
  EdgeCaseType.offline: EdgeCaseContent(
    code: 'E04',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.wifiSlash,
    title: 'You are offline',
    message: 'We cannot reach the Staki fund network. Please check '
        'your internet connection and try again.',
    primaryLabel: 'Try again',
    secondaryLabel: 'Check network settings',
  ),
  EdgeCaseType.poorNetwork: EdgeCaseContent(
    code: 'E05',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.cellSignalLow,
    title: 'Connection is slow',
    message: 'Your network is experiencing delays. This process might '
        'take a little longer than usual to complete securely.',
    primaryLabel: 'Continue waiting',
    secondaryLabel: 'Cancel',
  ),
  EdgeCaseType.sessionExpired: EdgeCaseContent(
    code: 'E06',
    tone: EdgeCaseTone.info,
    icon: AppIcons.lockKey,
    title: 'Session expired',
    message: 'For your security, we have paused your session due to '
        'inactivity. Please log in again to continue.',
    primaryLabel: 'Log in securely',
  ),
  EdgeCaseType.otpExpired: EdgeCaseContent(
    code: 'E07',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.timer,
    title: 'Code expired',
    message: 'The verification code has expired for your security. '
        'Please request a new code to continue.',
    primaryLabel: 'Resend code',
    secondaryLabel: 'Update phone number',
  ),
  EdgeCaseType.wrongOtp: EdgeCaseContent(
    code: 'E08',
    tone: EdgeCaseTone.error,
    icon: AppIcons.warningCircle,
    title: 'Incorrect code',
    message: 'The code entered does not match the one we sent. Please '
        'check the code and try again.',
    primaryLabel: 'Try again',
  ),
  EdgeCaseType.invalidPhone: EdgeCaseContent(
    code: 'E09',
    tone: EdgeCaseTone.error,
    icon: AppIcons.phoneSlash,
    title: 'Invalid phone number',
    message: 'The phone number entered is not a recognized format. '
        'Please ensure it is a valid active number.',
    primaryLabel: 'Edit phone number',
  ),
  EdgeCaseType.incorrectPin: EdgeCaseContent(
    code: 'E10',
    tone: EdgeCaseTone.error,
    icon: AppIcons.password,
    title: 'Incorrect PIN',
    message: 'The PIN entered is incorrect. You have 2 attempts '
        'remaining before your account is temporarily locked.',
    primaryLabel: 'Try again',
    secondaryLabel: 'Reset PIN',
  ),
  EdgeCaseType.forgotPin: EdgeCaseContent(
    code: 'E11',
    tone: EdgeCaseTone.info,
    icon: AppIcons.arrowCounterClockwise,
    title: 'Reset your PIN',
    message: 'To secure your account, we will send a verification code '
        'to your registered phone number to help you reset your '
        'PIN.',
    primaryLabel: 'Send reset code',
    secondaryLabel: 'Return to login',
  ),
  EdgeCaseType.momoFailed: EdgeCaseContent(
    code: 'E12',
    tone: EdgeCaseTone.error,
    icon: AppIcons.linkBreak,
    title: 'Connection failed',
    message: 'We could not securely connect to your MTN MoMo account. '
        'This might be due to a timeout or declined prompt.',
    primaryLabel: 'Retry connection',
    secondaryLabel: 'Upload statement manually',
  ),
  EdgeCaseType.momoUnavailable: EdgeCaseContent(
    code: 'E13',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.cloudSlash,
    title: 'Service unavailable',
    message: 'The MTN Mobile Money service is currently experiencing '
        'downtime. Please try connecting again later.',
    primaryLabel: 'Try again later',
  ),
  EdgeCaseType.momoNotEligible: EdgeCaseContent(
    code: 'E14',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.wallet,
    title: 'Account not supported',
    message: 'This MoMo account type is currently not supported for '
        'Credit Passport verification.',
    primaryLabel: 'Use a different number',
    secondaryLabel: 'Connect bank account',
  ),
  EdgeCaseType.insufficientHistory: EdgeCaseContent(
    code: 'E15',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.clockCounterClockwise,
    title: 'More history needed',
    message: 'Your connected accounts do not have enough recent '
        'transaction history to generate a reliable score.',
    primaryLabel: 'Keep using your account',
    secondaryLabel: 'Add another data source',
  ),
  EdgeCaseType.docUploadFailed: EdgeCaseContent(
    code: 'E16',
    tone: EdgeCaseTone.error,
    icon: AppIcons.cloudArrowUp,
    title: 'Upload failed',
    message: 'We could not upload your document securely. Please '
        'ensure your connection is stable and the file is under '
        '5MB.',
    primaryLabel: 'Try again',
    secondaryLabel: 'Choose different file',
  ),
  EdgeCaseType.poorDocQuality: EdgeCaseContent(
    code: 'E17',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.dotsNine,
    title: 'Document is unclear',
    message: 'The document uploaded is blurry or cut off. Please '
        'ensure all text is legible and well-lit.',
    primaryLabel: 'Retake photo',
  ),
  EdgeCaseType.docRejected: EdgeCaseContent(
    code: 'E18',
    tone: EdgeCaseTone.error,
    icon: AppIcons.fileText,
    title: 'Document rejected',
    message: 'The submitted document could not be accepted. Please '
        'ensure it is the correct, valid document requested.',
    primaryLabel: 'Upload new document',
    secondaryLabel: 'Contact support',
  ),
  EdgeCaseType.identityFailed: EdgeCaseContent(
    code: 'E19',
    tone: EdgeCaseTone.error,
    icon: AppIcons.identificationCard,
    title: 'Verification failed',
    message: 'We could not verify your identity with the provided '
        'information. Please review your details and try again.',
    primaryLabel: 'Review information',
  ),
  EdgeCaseType.kycIncomplete: EdgeCaseContent(
    code: 'E20',
    tone: EdgeCaseTone.info,
    icon: AppIcons.fileDashed,
    title: 'Profile incomplete',
    message: 'We need a few more details to comply with financial '
        'regulations before activating your account.',
    primaryLabel: 'Complete profile',
  ),
  EdgeCaseType.kycRejected: EdgeCaseContent(
    code: 'E21',
    tone: EdgeCaseTone.error,
    icon: AppIcons.shieldWarning,
    title: 'Verification declined',
    message: 'We are unable to offer you an account at this time based '
        'on regulatory criteria. If you believe this is an error, '
        'please contact us.',
    primaryLabel: 'Contact support',
  ),
  EdgeCaseType.assessmentDelayed: EdgeCaseContent(
    code: 'E22',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.clock,
    title: 'Assessment delayed',
    message: 'Generating your Credit Passport is taking longer than '
        'usual due to high data volume. We will notify you when '
        'it is ready.',
    primaryLabel: 'Return to dashboard',
  ),
  EdgeCaseType.assessmentFailed: EdgeCaseContent(
    code: 'E23',
    tone: EdgeCaseTone.error,
    icon: AppIcons.warningCircle,
    title: 'Assessment incomplete',
    message: 'We encountered an error while finalizing your score. '
        'Your data is safe, but we need to restart the '
        'assessment.',
    primaryLabel: 'Restart assessment',
    secondaryLabel: 'Contact support',
  ),
  EdgeCaseType.scoreUnavailable: EdgeCaseContent(
    code: 'E24',
    tone: EdgeCaseTone.neutral,
    icon: AppIcons.gauge,
    title: 'Score unavailable',
    message: 'Your Credit Passport score cannot be generated right '
        'now. This is usually due to insufficient recent '
        'financial activity.',
    primaryLabel: 'Learn how to improve',
  ),
  EdgeCaseType.loanIncomplete: EdgeCaseContent(
    code: 'E25',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.notePencil,
    title: 'Application incomplete',
    message: 'Your loan application is missing some required details. '
        'Please review and complete it to proceed.',
    primaryLabel: 'Resume application',
  ),
  EdgeCaseType.loanDeclined: EdgeCaseContent(
    code: 'E26',
    tone: EdgeCaseTone.neutral,
    icon: AppIcons.minusCircle,
    title: 'Application declined',
    message: 'The lending partner was unable to approve this loan '
        'request based on their current criteria.',
    primaryLabel: 'View decline reasons',
    secondaryLabel: 'Explore other options',
  ),
  EdgeCaseType.offerExpired: EdgeCaseContent(
    code: 'E27',
    tone: EdgeCaseTone.neutral,
    icon: AppIcons.calendarX,
    title: 'Offer expired',
    message: 'This funding offer is no longer valid. Please refresh '
        'your Credit Passport to see new opportunities.',
    primaryLabel: 'Refresh offers',
  ),
  EdgeCaseType.disbursementDelayed: EdgeCaseContent(
    code: 'E28',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.bank,
    title: 'Disbursement delayed',
    message: 'The partner bank is experiencing a delay in transferring '
        'your funds. The transaction is secure and will complete '
        'shortly.',
    primaryLabel: 'View status',
  ),
  EdgeCaseType.repaymentFailed: EdgeCaseContent(
    code: 'E29',
    tone: EdgeCaseTone.error,
    icon: AppIcons.money,
    title: 'Repayment failed',
    message: 'We could not process your repayment. Please check your '
        'account balance or try a different payment method.',
    primaryLabel: 'Try again',
    secondaryLabel: 'Change payment method',
  ),
  EdgeCaseType.repaymentOverdue: EdgeCaseContent(
    code: 'E30',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.bellRinging,
    title: 'Payment overdue',
    message: 'Your scheduled loan repayment is past due. Please make a '
        'payment as soon as possible to maintain your score.',
    primaryLabel: 'Make a payment',
    secondaryLabel: 'View schedule',
  ),
  EdgeCaseType.fundingUnavailable: EdgeCaseContent(
    code: 'E31',
    tone: EdgeCaseTone.error,
    icon: AppIcons.prohibit,
    title: 'Allocation failed',
    message: 'We could not allocate your funds to this opportunity. '
        'The opportunity may have just been fully funded.',
    primaryLabel: 'Refresh marketplace',
  ),
  EdgeCaseType.insufficientBalance: EdgeCaseContent(
    code: 'E32',
    tone: EdgeCaseTone.warning,
    icon: AppIcons.wallet,
    title: 'Insufficient balance',
    message: 'You do not have enough available funds to complete this '
        'allocation. Please add more funds to your account.',
    primaryLabel: 'Add funds',
    secondaryLabel: 'Adjust allocation',
  ),
  EdgeCaseType.noOpportunities: EdgeCaseContent(
    code: 'E33',
    tone: EdgeCaseTone.neutral,
    icon: AppIcons.magnifyingGlass,
    title: 'No opportunities',
    message: 'There are currently no funding opportunities that match '
        'your filters. Please check back later.',
    primaryLabel: 'Clear filters',
  ),
  EdgeCaseType.opportunityFullyFunded: EdgeCaseContent(
    code: 'E34',
    tone: EdgeCaseTone.info,
    icon: AppIcons.checkCircle,
    title: 'Fully funded',
    message: 'This opportunity has already reached its funding goal '
        'and is no longer accepting new allocations.',
    primaryLabel: 'View other opportunities',
  ),
};
