import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:samiti_app/core/utils/token_storage.dart';

import '../exception/api_exception.dart';
import '../utils/jwt_decoder.dart';
import 'api_constants.dart';

//abstract class that contains the shared logic for making API calls
abstract class BaseApiService<T> {
  final http.Client client;
  final String baseUrl;

  BaseApiService({required this.client, this.baseUrl = ApiConstants.baseUrl});

  // helper method for building HTTP request headers
  Future<Map<String, String>> _authHeader() async {
    String? token = await TokenStorage.getAccessToken();


    if (token == null || token.isEmpty) {
      return {
        'Content-Type': 'application/json',
      };
    }

    // refresh the token
    if (JwtDecoder.isExpired(token)) {
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw ApiException(401, "Session expired");
      }

      final response = await client.post(
        Uri.parse('$baseUrl${ApiConstants.tokenRefresh}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode != 200) {
        throw ApiException(response.statusCode, "Token refresh failed");
      }

      final data = jsonDecode(response.body);
      token = data['access_token'];

      await TokenStorage.saveAccessToken(token!);
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }


  // generic helper for fetching lists of data from an API
  Future<List<T>> getList<T>({
    required String endpoint,
    required T Function(Map<String,dynamic>) fromJson,
})async{
    final response = await client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeader(),
    );
    if (response.statusCode == 200) {
      final dynamic decodedBody=jsonDecode(response.body);
      List<dynamic> listData= [];
      if(decodedBody is List){
        listData=decodedBody;
      }
      else if(decodedBody is Map<String,dynamic>){
        listData = decodedBody['results'] ?? [];
      }
      return listData.map<T>((item) => fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> getSingle({
    required String endpoint,
  }) async {
    final response = await client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeader(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeader(),
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }


  Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    print('post of apiservice called');
    final response = await client.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeader(),
      body: jsonEncode(body),
    );
    print('post of apiservice returned');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> patch({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final response = await client.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeader(),
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

  Future<bool> delete({
    required String endpoint,
  }) async {
    final response = await client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _authHeader(),
    );
    if (response.statusCode == 204 || response.statusCode == 200) {
      return true;
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

  // Multipart POST for image uploads
  Future<Map<String, dynamic>> multipartPost({
    required String endpoint,
    required Map<String, String> fields,
    String? singleImagePath,
    List<String>? multipleImagePath,
    String? fileFieldName,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    // Add auth header if token exists
    final token = await TokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add text fields
    request.fields.addAll(fields);

    // Case 1: single image (vehicle)
    if (singleImagePath != null && fileFieldName != null) {
      request.files.add(await http.MultipartFile.fromPath(fileFieldName, singleImagePath));
    }

    // Case 2: multiple images (accident)
    if (multipleImagePath != null && fileFieldName != null) {
      for (int i = 0; i < multipleImagePath.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            '$fileFieldName[$i][image]',  // → images[0]image, images[1]image
            multipleImagePath[i],
          ),
        );
      }
    }

    // Send request
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

}

