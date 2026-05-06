import 'package:samiti_app/core/api/api_service.dart';
import 'package:samiti_app/core/api/api_constants.dart';

import '../model/vehicle_model.dart';

class VehicleRepository extends BaseApiService {
  VehicleRepository({required super.client});

  Future<List<VehicleModel>> getVehicles() async {
    final response= await getList<VehicleModel>(
      endpoint: ApiConstants.vehicles,
      fromJson: VehicleModel.fromJson,
    );

    return response;
  }

  Future<VehicleModel> getVehicle({required int id,}) async {
    final data = await getSingle(
      endpoint: '${ApiConstants.vehicles}$id/',
    );
    return VehicleModel.fromJson(data);
  }

  Future<VehicleModel> createVehicle({
    required Map<String, String> fields,
    String? imagePath,
  }) async {
    final data = await multipartPost(
      endpoint: ApiConstants.vehicles,
      fields: fields,
      singleImagePath: imagePath,
      fileFieldName: imagePath != null ? 'vehicle_image' : null
    );
    return VehicleModel.fromJson(data);
  }

  Future<VehicleModel> updateVehicle({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    final data = await patch(
      endpoint: '${ApiConstants.vehicles}$id/',
      body: body,
    );
    return VehicleModel.fromJson(data);
  }

  Future<bool> deleteVehicle({required int id,}) async {
    return delete(
      endpoint: '${ApiConstants.vehicles}$id/',
    );
  }

  Future<List<VehiclePartnerEmbed>> getPartners() async {
    return getList<VehiclePartnerEmbed>(
      endpoint: ApiConstants.partners,
      fromJson: VehiclePartnerEmbed.fromJson,
    );
  }

  Future<List<VehicleBrandEmbed>> getVehicleBrands() async {
    return getList<VehicleBrandEmbed>(
      endpoint: ApiConstants.vehicleBrands,
      fromJson: VehicleBrandEmbed.fromJson,
    );
  }

  Future<List<VehicleTypeEmbed>> getVehicleTypes() async {
    return getList<VehicleTypeEmbed>(
      endpoint: ApiConstants.vehicleTypes,
      fromJson: VehicleTypeEmbed.fromJson,
    );
  }
}
