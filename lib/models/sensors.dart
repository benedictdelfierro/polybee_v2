class Geolocation {
  final double accuracy;
  final double altitude;
  final double heading;
  final double latitude;
  final double longitude;
  final double speed;
  final double speedAccuracy;
  final DateTime timestamp;

  Geolocation(
      {required this.accuracy,
      required this.altitude,
      required this.heading,
      required this.latitude,
      required this.longitude,
      required this.speed,
      required this.speedAccuracy,
      required this.timestamp});

  factory Geolocation.fromRTDB(Map<String, dynamic> data) {
    return Geolocation(
        accuracy: data['accuracy'],
        altitude: data['altitude'],
        heading: data['heading'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        speed: data['speed'],
        speedAccuracy: data['speedAccuracy'],
        timestamp: data['timestamp']);
  }
}



