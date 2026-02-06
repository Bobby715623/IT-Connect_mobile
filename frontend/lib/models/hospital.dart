class Hospital {
  final int hospitalID;
  final String name;
  final String? province;
  final String? placeId;
  final double? latitude;
  final double? longitude;

  Hospital({
    required this.hospitalID,
    required this.name,
    this.province,
    this.placeId,
    this.latitude,
    this.longitude,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      hospitalID: json['HospitalID'],
      name: json['HospitalName'] ?? '-',
      province: json['province'],
      placeId: json['PlaceID'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
