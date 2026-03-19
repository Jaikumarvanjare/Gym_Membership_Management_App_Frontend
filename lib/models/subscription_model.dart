class Subscription {
  final String plan;
  final String status;

  Subscription({required this.plan, required this.status});

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      plan: json["plan"],
      status: json["status"],
    );
  }
}