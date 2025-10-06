import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();

  factory NetworkHelper() => _instance;

  NetworkHelper._internal();

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  bool? _lastEmitted; // avoid duplicate emissions

  Stream<bool> get onConnectionChange => _controller.stream;

  void initialize() {
    _connectivity.onConnectivityChanged.listen(_checkConnection);
  }

  Future<void> _checkConnection(List<ConnectivityResult> result) async {
    final isOnline = await InternetConnection().hasInternetAccess;
    if (_lastEmitted == null || _lastEmitted != isOnline) {
      _lastEmitted = isOnline;
      _controller.sink.add(isOnline);
    }
  }

  Future<bool> checkNow() async {
    return await InternetConnection().hasInternetAccess;
  }

  void dispose() => _controller.close();
}
