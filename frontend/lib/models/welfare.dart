class Welfare {
  final int id;
  final String? type;
  final String? title;
  final String? description;
  final String? guide;
  final String? document;

  Welfare({
    required this.id,
    this.type,
    this.title,
    this.description,
    this.guide,
    this.document,
  });

  factory Welfare.fromJson(Map<String, dynamic> json) {
    return Welfare(
      id: json['WelfareID'],
      type: json['WelfareType'],
      title: json['WelfareTitle'],
      description: json['Description'],
      guide: json['WelfareGuide'],
      document: json['WelfareDocument'],
    );
  }
}
