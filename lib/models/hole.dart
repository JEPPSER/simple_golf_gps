class Hole {
  final String front;
  final String mid;
  final String back;

  Hole({required this.front, required this.mid, required this.back});

  factory Hole.fromJson(Map<String, dynamic> json) {
    return Hole(
      front: json['front'] as String,
      mid: json['mid'] as String,
      back: json['back'] as String,
    );
  }
}
