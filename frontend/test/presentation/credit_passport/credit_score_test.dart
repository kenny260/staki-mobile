import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';

CreditScore _scoreOf(int value) =>
    CreditScore(value: value, updatedLabel: 'Updated today', factors: const []);

void main() {
  group('CreditScore.band', () {
    test('maps the lowest and highest poor scores', () {
      expect(_scoreOf(300).band, ScoreBand.poor);
      expect(_scoreOf(579).band, ScoreBand.poor);
    });

    test('maps fair and good boundaries', () {
      expect(_scoreOf(580).band, ScoreBand.fair);
      expect(_scoreOf(669).band, ScoreBand.fair);
      expect(_scoreOf(670).band, ScoreBand.good);
      expect(_scoreOf(739).band, ScoreBand.good);
    });

    test('maps very good and exceptional boundaries', () {
      expect(_scoreOf(740).band, ScoreBand.veryGood);
      expect(_scoreOf(799).band, ScoreBand.veryGood);
      expect(_scoreOf(800).band, ScoreBand.exceptional);
      expect(_scoreOf(1000).band, ScoreBand.exceptional);
    });
  });

  test('bandLabel matches the band', () {
    expect(_scoreOf(780).bandLabel, 'VERY GOOD');
    expect(_scoreOf(500).bandLabel, 'POOR');
  });
}
