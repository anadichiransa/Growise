import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Monitors network connectivity and exposes current state reactively.
/// Used by the repository to decide whether to attempt backend sync.
class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final isOnline = false.obs;

  // Callbacks that fire when connectivity is restored
  final List<VoidCallback> _onlineCallbacks = [];

  Future<ConnectivityService> init() async {
    // Check initial state
    final result = await _connectivity.checkConnectivity();
    isOnline.value = result != ConnectivityResult.none;

    // Listen for changes
    _connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = !isOnline.value;
      isOnline.value = result != ConnectivityResult.none;

      // If we just came back online, fire registered callbacks
      if (wasOffline && isOnline.value) {
        for (final cb in _onlineCallbacks) {
          cb();
        }
      }
    });

    return this;
  }

  /// Register a callback to fire whenever connectivity is restored.
  /// Used by GrowthRepository to trigger background backend sync.
  void onConnectivityRestored(VoidCallback callback) {
    _onlineCallbacks.add(callback);
  }
}