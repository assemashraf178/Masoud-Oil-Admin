class OilTypeModel {
  String? name;
  String? id;

  OilTypeModel({
    this.name,
    this.id,
  });

  factory OilTypeModel.fromJson(Map<String, dynamic>? json) => OilTypeModel(
        name: json!["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

class DetailsOilTypeModel {
  String? name;
  String? price;
  String? id;

  DetailsOilTypeModel({this.name, this.price, this.id});

  factory DetailsOilTypeModel.fromJson(Map<String, dynamic> json) {
    return DetailsOilTypeModel(
      name: json['name'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}
