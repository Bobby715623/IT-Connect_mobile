class Post {
  final int postID;
  final String content;
  final String type;
  final bool isPinned;
  final DateTime createDate;
  final String officerName;
  final List<String> images;

  Post({
    required this.postID,
    required this.content,
    required this.type,
    required this.isPinned,
    required this.createDate,
    required this.officerName,
    required this.images,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postID: json['PostID'],
      content: json['Content'] ?? '',
      type: json['Type'] ?? 'normal',
      isPinned: json['IsPinned'] ?? false,
      createDate: json['CreateDate'] != null
          ? DateTime.parse(json['CreateDate'])
          : DateTime.now(),
      officerName: json['Officer']?['Name'] ?? '-',
      images: json['PostPicture'] == null
          ? []
          : (json['PostPicture'] as List)
                .map((e) => e['Picture'] as String)
                .toList(),
    );
  }
}
