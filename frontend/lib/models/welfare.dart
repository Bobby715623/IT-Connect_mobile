import 'welfare_file.dart';

class Welfare {
  final int id;
  final String type;
  final String title;
  final String? description;
  final String? coverImage;
  final List<WelfareFile> files;

  Welfare({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.coverImage,
    required this.files,
  });

  factory Welfare.fromJson(Map<String, dynamic> json, String baseUrl) {
    return Welfare(
      id: json['WelfareID'],
      type: json['WelfareType'],
      title: json['Title'],
      description: json['Description'],
      coverImage: json['CoverImage'] != null
          ? "$baseUrl${json['CoverImage']}"
          : null,
      files: (json['Files'] as List)
          .map((file) => WelfareFile.fromJson(file, baseUrl))
          .toList(),
    );
  }
}
