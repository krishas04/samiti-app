class VehicleModel {
  final int id;
  final String displayName;
  final String vehicleNo;
  final bool isActive;
  final String? fuelType;
  final String? modelNo;
  final VehiclePartnerEmbed? partner;
  final VehicleBrandEmbed? vehicleBrand;
  final VehicleTypeEmbed? vehicleType;
  final String? vehicleImage;

  // For database queries (foreign key)
  final int? partnerId;
  final int? vehicleBrandId;
  final int? vehicleTypeId;

  VehicleModel({
    required this.id,
    required this.displayName,
    required this.vehicleNo,
    required this.isActive,
    this.fuelType,
    this.modelNo,
    this.partner,
    this.vehicleBrand,
    this.vehicleType,
    this.vehicleImage,
    this.partnerId,
    this.vehicleBrandId,
    this.vehicleTypeId
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      displayName: json['display_name'],
      vehicleNo: json['vehicle_no'] ?? '',
      isActive: json['is_active'] ?? true,
      fuelType: json['fuel_type'],
      modelNo: json['model_no'],
      partner: json['partner'] != null
          ? VehiclePartnerEmbed.fromJson(json['partner'])
          : null,
      vehicleBrand: json['vehicle_brand']!= null
          ? VehicleBrandEmbed.fromJson(json['vehicle_brand'])
          : null,
      vehicleType: json['vehicle_type']!= null
          ? VehicleTypeEmbed.fromJson(json['vehicle_type'])
          : null,
      vehicleImage: json['vehicle_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name':displayName,
      'vehicle_no': vehicleNo,
      'partner': partner?.id, //Only send partner.id, not full object Or sends null
      'vehicle_brand': vehicleBrand?.id,
      'vehicle_type': vehicleType?.id,
      'fuel_type': fuelType,
      'model_no': modelNo,
      'vehicle_image': vehicleImage,
    };
  }
}

// a container that holds partner info when you need it,
// but can be reduced to just an ID when saving.
class VehiclePartnerEmbed {
  final int id;
  final String displayName;
  final bool isActive;
  final String name;
  final String email;

  VehiclePartnerEmbed({required this.id, required this.displayName,required this.isActive, required this.name, required this.email});

  factory VehiclePartnerEmbed.fromJson(Map<String, dynamic> json) {
    return VehiclePartnerEmbed(
      id: json['id'],
      displayName: json['display_name'] ?? '',
      isActive: json['is_active'] ?? true,
      name: json['display_name'] ,
      email: json['display_name'] ,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'display_name': displayName,
      'is_active': isActive,
      'name': name,
      'email': email,
    };
  }
}

class VehicleBrandEmbed{
  final int id;
  final String displayName;

  VehicleBrandEmbed({required this.id, required this.displayName});

  factory VehicleBrandEmbed.fromJson(Map<String, dynamic> json) {
    return VehicleBrandEmbed(
      id: json['id'],
      displayName: json['display_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
  };
}

class VehicleTypeEmbed {
  final int id;
  final String displayName;

  VehicleTypeEmbed({required this.id, required this.displayName});

  factory VehicleTypeEmbed.fromJson(Map<String, dynamic> json) {
    return VehicleTypeEmbed(
      id: json['id'],
      displayName: json['display_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
  };
}