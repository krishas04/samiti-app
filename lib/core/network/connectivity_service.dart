import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class ConnectivityService extends ChangeNotifier{
  final _connectivity = Connectivity();
  StreamSubscription? _sub;

  bool _isOnline = true;
  bool get isOnline=> _isOnline;

  // constructor runs at DI
  ConnectivityService(){
    _init();
  }

  Future<void> _init() async{
    // step 1: get current state
    final result= await _connectivity.checkConnectivity();  //returns list of ConnectivityResult
    _isOnline= _fromResult(result);

    // step 2: start listening for future changes
    _sub= _connectivity.onConnectivityChanged.listen((result){
      final online= _fromResult(result);
      if(online != _isOnline){
        _isOnline=online;
        notifyListeners();
      }
    });
  }

  // connectivity parser - returns false when app is not connected to any network
  bool _fromResult(List<ConnectivityResult> result) {
    return result.any((r)=> r != ConnectivityResult.none);
  }

  @override
  void dispose(){
    _sub?.cancel();
    super.dispose();
  }
}