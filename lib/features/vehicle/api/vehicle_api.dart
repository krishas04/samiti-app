// it contains api logic related to vehicle
import 'package:samiti_app/core/api/api_service.dart';
import 'package:samiti_app/core/api/api_constants.dart';
import '../model/vehicle_model.dart';

class VehicleApi extends BaseApiService {
  VehicleApi({required super.client});

  Future<List<VehicleModel>> fetchVehicles() async {
    return getList<VehicleModel>(
      endpoint: ApiConstants.vehicles,
      fromJson: VehicleModel.fromJson,
    );
  }

  Future<VehicleModel> fetchVehicle(int id) async {
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
      fileFieldName: imagePath != null ? 'vehicle_image' : null,
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

  Future<bool> deleteVehicle(int id) async {
    return delete(endpoint: '${ApiConstants.vehicles}$id/');
  }

  Future<List<VehiclePartnerEmbed>> fetchPartners() async {
    return getList<VehiclePartnerEmbed>(
      endpoint: ApiConstants.partners,
      fromJson: VehiclePartnerEmbed.fromJson,
    );
  }

  Future<List<VehicleBrandEmbed>> fetchVehicleBrands() async {
    return getList<VehicleBrandEmbed>(
      endpoint: ApiConstants.vehicleBrands,
      fromJson: VehicleBrandEmbed.fromJson,
    );
  }

  Future<List<VehicleTypeEmbed>> fetchVehicleTypes() async {
    return getList<VehicleTypeEmbed>(
      endpoint: ApiConstants.vehicleTypes,
      fromJson: VehicleTypeEmbed.fromJson,
    );
  }
}