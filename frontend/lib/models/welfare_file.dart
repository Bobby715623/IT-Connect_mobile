class WelfareFile {
  final int id;
  final String fileName;
  final String fileUrl;
  final String? fileType;

  WelfareFile({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
  });

  factory WelfareFile.fromJson(Map<String, dynamic> json, String baseUrl) {
    return WelfareFile(
      id: json['WelfareFileID'],
      fileName: json['FileName'],
      fileUrl: "$baseUrl${json['FileUrl']}",
      fileType: json['FileType'],
    );
  }
}
