class VehicleModel {
  final int id;
  final String displayName;
  final String vehicleNo;
  final bool isActive;
  final String? fuelType;
  final String? modelNo;
  final VehiclePartnerEmbed? partner;
  final int? vehicleBrand;
  final int? vehicleType;
  final String? vehicleImage;

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
    this.vehicleImage
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
      vehicleBrand: json['vehicle_brand'],
      vehicleType: json['vehicle_type'],
      vehicleImage: json['vehicle_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name':displayName,
      'vehicle_no': vehicleNo,
      'partner': partner?.id, //Only send partner.id, not full object Or sends null
      'vehicle_brand': vehicleBrand,
      'vehicle_type': vehicleType,
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
}