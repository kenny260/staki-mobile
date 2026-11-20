/// Where the Credit Passport scoring API lives (Vercel, owned by
/// Abdull-Kudus). Override at run time with:
/// flutter run --dart-define=SCORING_API_URL=https://your-project.vercel.app
abstract final class ScoringConfig {
  static const baseUrl = String.fromEnvironment(
    'SCORING_API_URL',
    // TODO(chris): replace with the real URL once Abdull-Kudus posts it in
    // issue #22.
    defaultValue: 'https://vercel-project.vercel.app',
  );

  static const computePath = '/api/credit-passport';
}
