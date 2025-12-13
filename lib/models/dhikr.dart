class Dhikr {
  final String text;
  final int count;
  final String? reference;

  Dhikr({required this.text, required this.count, this.reference});

  factory Dhikr.fromJson(Map<String, dynamic> json) {
    return Dhikr(
      text: json['text'] as String,
      count: json['count'] as int,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'count': count, 'reference': reference};
  }
}
