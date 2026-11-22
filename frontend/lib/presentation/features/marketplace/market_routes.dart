/// Route paths for Section 09 (lender marketplace and portfolio).
abstract final class MarketRoutes {
  static const base = '/marketplace'; // LE01
  static const fund = '/marketplace/fund'; // LE03
  static const review = '/marketplace/review'; // LE04
  static const confirm = '/marketplace/confirm'; // LE05
  static const success = '/marketplace/success'; // LE06
  static const portfolio = '/marketplace/portfolio'; // LE07
  static const notifications = '/marketplace/notifications'; // LE08
  static const ledger = '/marketplace/ledger'; // LE09

  static String opportunity(String id) => '/marketplace/opportunity/$id';

  static String allocation(String id) => '/marketplace/allocation/$id';
}
