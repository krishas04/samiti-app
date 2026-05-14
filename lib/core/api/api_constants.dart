class ApiConstants{
  //baseUrl
  static const String baseUrl='http://192.168.101.5:8000/api';

  // Auth
  static const String register = 'v1/auth/register/';
  static const String login = '/v1/auth/token/';
  static const String tokenRefresh = 'v1/auth/token/refresh/';

  //Products
  static const String products = '/v1/products/';

  //Partners
  static const String partners = '/v1/partners';

  //vehicles
  static const String vehicles = '/v1/vehicles/';
  static const String vehicleTypes = '/v1/vehicle-types/';
  static const String vehicleBrands = '/v1/vehicle-brands/';

  //accidents
  static const String accidents = '/v1/accidents/';
}