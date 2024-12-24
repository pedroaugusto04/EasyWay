class UserModel {
  final String id;
  final String name;
  final String email;
  final double lat;
  final double lng;
  bool notificate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.lat,
    required this.lng,
    this.notificate = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      lat: map['lat'].toDouble(),
      lng: map['lng'].toDouble(),
      notificate: map['notificate'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'lat': lat,
      'lng': lng,
      'notificate': notificate,
    };
  }
}
