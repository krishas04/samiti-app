class ApiConstants{
  //baseUrl
  static const String baseUrl='http://192.168.101.2:8000/api';

  // Auth
  static const String register = 'v1/auth/register';
  static const String login = '/v1/auth/token/';
  static const String tokenRefresh = 'v1/auth/token/refresh/';

  //Products
  static const String products = '/v1/products/';

  //vehicles
  static const String vehicles = '/v1/vehicles/';

  //accidents
  static const String accidents = '/v1/accidents/';
}