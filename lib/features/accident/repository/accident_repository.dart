import 'package:samiti_app/core/api/api_service.dart';
import 'package:samiti_app/core/api/api_constants.dart';
import 'package:samiti_app/features/accident/model/accident_model.dart';


class AccidentRepository extends BaseApiService {
  AccidentRepository({required super.client});

  Future<List<AccidentModel>> getAccidents() async {
    final response= await getList<AccidentModel>(
      endpoint: ApiConstants.accidents,
      fromJson: AccidentModel.fromJson,
    );

    return response;
  }

  Future<AccidentModel> getAccident({required int id,}) async {
    final data = await getSingle(
      endpoint: '${ApiConstants.accidents}$id/',
    );
    return AccidentModel.fromJson(data);
  }

  Future<AccidentModel> createAccident({
    required Map<String, String> fields,
    List<String> imagePaths=const [],
  }) async {
    final data = await multipartPost(
      endpoint: ApiConstants.accidents,
      fields: fields,
      multipleImagePath: imagePaths,
      fileFieldName: 'images'
    );
    return AccidentModel.fromJson(data);
  }

  Future<AccidentModel> updateAccident({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    final data = await patch(
      endpoint: '${ApiConstants.accidents}$id/',
      body: body,
    );
    return AccidentModel.fromJson(data);
  }

  Future<bool> deleteAccident({required int id,}) async {
    return delete(
      endpoint: '${ApiConstants.accidents}$id/',
    );
  }
}