import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final isOnline = false.obs;

  final List<VoidCallback> _onlineCallbacks = [];

  Future<ConnectivityService> init() async {
    final results = await _connectivity.checkConnectivity();
    isOnline.value = !results.contains(ConnectivityResult.none);

    _connectivity.onConnectivityChanged.listen((results) {
      final wasOffline = !isOnline.value;
      isOnline.value = !results.contains(ConnectivityResult.none);

      if (wasOffline && isOnline.value) {
        for (final cb in _onlineCallbacks) {
          cb();
        }
      }
    });

    return this;
  }

  void onConnectivityRestored(VoidCallback callback) {
    _onlineCallbacks.add(callback);
  }
}
