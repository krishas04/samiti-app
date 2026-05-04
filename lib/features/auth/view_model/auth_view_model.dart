import 'package:flutter/material.dart';

import '../../../core/utils/token_storage.dart';
import '../model/auth_model.dart';
import '../repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier{
  final AuthRepository repository;

  AuthModel? auth;
  bool isLoading = false;
  String? error;

  AuthViewModel({required this.repository});

  Future<bool> login({required String login, required String password}) async{
    isLoading=true;
    error=null;
    notifyListeners();

    try{
      auth=await repository.login(login: login, password: password);
      await TokenStorage.saveTokens(
        accessToken:  auth!.accessToken,
        refreshToken: auth!.refreshToken,
      );
      return true;
    }catch(e){
      error = e.toString();
      error="Invalid username or password vm";
      return false;
    }
    finally{
      isLoading=false;
      notifyListeners();
    }
  }

  Future<bool> register({required String password, required String email,required String username}) async{
    isLoading=true;
    notifyListeners();

    try{
      auth=await repository.register(username: username, password: password, email: email);
      return true;
    }catch(e){
      error="Registration failed. Please try again.";
      return false;
    }
    finally{
      isLoading=false;
      notifyListeners();
    }
  }

  // Refresh the access token using the stored refresh token.
  Future<bool> refreshToken() async {
    try {
      final storedRefresh = await TokenStorage.getRefreshToken();
      if (storedRefresh == null) return false;

      auth = await repository.refreshToken(refreshToken: storedRefresh);
      await TokenStorage.saveAccessToken(auth!.accessToken);
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  // Logout belongs to ViewModel because it is state management and UI control,
  // not a data-repository (API) operation. So, its logic isn't kept in repository.
  Future<void> logout() async {
    await TokenStorage.clearTokens();
    auth = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}