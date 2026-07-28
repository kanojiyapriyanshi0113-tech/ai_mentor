import "package:dio/dio.dart";

import "../models/user_model.dart";
import "api_client.dart";

class ProfileApiService {
  final Dio _dio = ApiClient().dio;

  Future<UserModel> getProfile() async {
    final response = await _dio.get("/profile");
    final data = response.data["data"] as Map<String, dynamic>;
    return UserModel.fromApiJson(data);
  }

  Future<UserModel> updateProfile({required String name}) async {
    final response = await _dio.put("/profile", data: {"name": name});
    final data = response.data["data"] as Map<String, dynamic>;
    return UserModel.fromApiJson(data);
  }
}
