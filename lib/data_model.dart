class DataModel {
  String id;
  String? name;
  String? phone;
  String? oilType;
  String? notes;
  String? carType;
  String? address;
  double? latitude;
  double? longitude;
  String? date;

  DataModel({
    required this.id,
    this.name,
    this.phone,
    this.oilType,
    this.notes,
    this.carType,
    this.address,
    this.latitude,
    this.longitude,
    this.date,
  });

  DataModel.fromJson(this.id, Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    oilType = json['oilType'];
    notes = json['notes'];
    carType = json['carType'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "oilType": oilType,
        "notes": notes,
        "carType": carType,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "date": date,
      };
}
