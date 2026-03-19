class Member {
  final String id;
  final String name;
  final String email;

  Member({required this.id, required this.name, required this.email});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json["_id"],
      name: json["name"],
      email: json["email"],
    );
  }
}