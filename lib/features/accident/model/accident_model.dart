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


  final String? syncStatus; // 'synced', 'pending_create', 'pending_update', 'pending_delete'
  final List<String>? localImagePaths;
  final int? createdAt;

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

    this.syncStatus,
    this.localImagePaths,
    this.createdAt,
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
      createdAt: DateTime.tryParse(json['created_at'])?.millisecondsSinceEpoch
      // syncStatus and localImagePaths are local-only, not from server JSON
    );
  }

  // Create copy with updated fields (immutable pattern)
  AccidentModel copyWith({
    int? id,
    String? displayName,
    String? name,
    bool? isActive,
    String? accidentDate,
    String? driverName,
    String? accidentPlace,
    String? accidentCause,
    String? remarks,
    AccidentVehicleEmbed? vehicle,
    List<AccidentImageModel>? images,
    String? syncStatus,
    List<String>? localImagePaths,
    int? createdAt
  }) {
    return AccidentModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      accidentDate: accidentDate ?? this.accidentDate,
      driverName: driverName ?? this.driverName,
      accidentPlace: accidentPlace ?? this.accidentPlace,
      accidentCause: accidentCause ?? this.accidentCause,
      remarks: remarks ?? this.remarks,
      vehicle: vehicle ?? this.vehicle,
      images: images ?? this.images,
      syncStatus: syncStatus ?? this.syncStatus,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      createdAt: createdAt ?? this.createdAt
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

  // factory can return cached instance instead of creating new one
  factory AccidentVehicleEmbed.fromJson(Map<String, dynamic> json) {
    return AccidentVehicleEmbed(
      id: json['id'],
      vehicleNo: json['vehicle_no'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'vehicle_no': vehicleNo,
      'is_active': isActive,
    };
  }
}

class AccidentImageModel{
  final int id;
  final String image; // can be remote url or localpath
  final bool isLocal;

  AccidentImageModel({
    required this.id,
    required this.image,
    this.isLocal= false
  });

  factory AccidentImageModel.fromJson(Map<String, dynamic> json){
    return AccidentImageModel(
        id: json['id'],
        image: json['image'] ?? [],
        isLocal: false  // server images are never local initially
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'image': image
    };
  }
}