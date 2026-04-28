class AccidentModel {
  final int id;
  final String displayName;
  final String name;
  final bool isActive;
  final String? accidentDate;
  final String? driverName;
  final String? accidentPlace;
  final String? accidentCause;
  final String? remarks;
  final AccidentVehicleEmbed? vehicle;
  final List<AccidentImageModel> images;

  AccidentModel({
    required this.id,
    required this.displayName,
    required this.name,
    required this.isActive,
    this.accidentDate,
    this.driverName,
    this.accidentPlace,
    this.accidentCause,
    this.remarks,
    this.vehicle,
    this.images = const [],
  });

  factory AccidentModel.fromJson(Map<String, dynamic> json) {
    return AccidentModel(
      id: json['id'],
      displayName: json['display_name'] ?? '',
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? true,
      accidentDate: json['accident_date'],
      driverName: json['driver_name'],
      accidentPlace: json['accident_place'],
      accidentCause: json['accident_cause'],
      remarks: json['remarks'],
      vehicle: json['vehicle'] != null
          ? AccidentVehicleEmbed.fromJson(json['vehicle'])
          : null,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => AccidentImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

}

// a container that holds vehicle info when you need it,
// but can be reduced to just an ID when saving.
class AccidentVehicleEmbed {
  final int id;
  final String vehicleNo;
  final bool isActive;

  AccidentVehicleEmbed({required this.id, required this.vehicleNo,required this.isActive, });

  factory AccidentVehicleEmbed.fromJson(Map<String, dynamic> json) {
    return AccidentVehicleEmbed(
      id: json['id'],
      vehicleNo: json['vehicle_no'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

class AccidentImageModel{
  final int id;
  final String image;

  AccidentImageModel({required this.id, required this.image});

  factory AccidentImageModel.fromJson(Map<String, dynamic> json){
    return AccidentImageModel(
        id: json['id'],
        image: json['image'] ?? [],
    );
  }
}