import 'UserModel.dart';

class RouteModel {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final List<UserModel> passengers;
  final bool userIsDriver;

  RouteModel({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.passengers,
    this.userIsDriver = false
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    var passengersFromJson = (json['passengers'] as List)
        .map((passenger) => UserModel.fromJson(passenger))
        .toList();

    return RouteModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      passengers: passengersFromJson,
      userIsDriver: false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'destination': destination,
      'passengers': passengers.map((passenger) => passenger.toJson()).toList(),
      'userIsDriver': userIsDriver
    };
  }
}
