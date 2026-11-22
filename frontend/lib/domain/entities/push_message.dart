/// A push notification, reduced to what the app needs.
class PushMessage {
  const PushMessage({this.title, this.body, this.route});

  final String? title;
  final String? body;

  /// Optional `route` value sent in the message data, e.g. '/marketplace'.
  final String? route;
}
