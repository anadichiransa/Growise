// frontend/lib/features/dashboard/presentation/widgets/offline_status_banner.dart

import 'dart:async';
import 'package:flutter/material.dart';

/// A banner that auto-detects connectivity and shows a dismissible
/// "You are offline" warning when the device loses internet access.
///
/// Sits at the top of DashboardScreen inside a Column (zero height when online).
///
/// Add `connectivity_plus` to pubspec.yaml for real network monitoring:
/// ```yaml
/// dependencies:
///   connectivity_plus: ^6.0.0
/// ```
///
/// The widget works without the package too — it stays silent unless
/// you call [_OfflineStatusBannerState.setOffline] via a notifier or
/// swap the stub listener below for a real ConnectivityResult stream.
class OfflineStatusBanner extends StatefulWidget {
  const OfflineStatusBanner({Key? key}) : super(key: key);

  @override
  State<OfflineStatusBanner> createState() => _OfflineStatusBannerState();
}

class _OfflineStatusBannerState extends State<OfflineStatusBanner>
    with SingleTickerProviderStateMixin {
  bool _isOffline = false;
  bool _isDismissed = false;

  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;

  // ── Connectivity stub ─────────────────────────────────────────
  // Replace this with a real connectivity_plus stream listener:
  //
  //   StreamSubscription<ConnectivityResult>? _connectivitySub;
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     _connectivitySub = Connectivity()
  //         .onConnectivityChanged
  //         .listen((ConnectivityResult result) {
  //       final offline = result == ConnectivityResult.none;
  //       if (offline != _isOffline) {
  //         _setOffline(offline);
  //       }
  //     });
  //   }
  //
  //   @override
  //   void dispose() {
  //     _connectivitySub?.cancel();
  //     super.dispose();
  //   }
  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _setOffline(bool offline) {
    setState(() {
      _isOffline = offline;
      _isDismissed = false;
    });
    if (offline) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  void _dismiss() {
    setState(() => _isDismissed = true);
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Hide completely when online or manually dismissed
    if (!_isOffline || _isDismissed) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        color: const Color(0xFF3A1010),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── Icon ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFFF6B6B),
                size: 16,
              ),
            ),

            const SizedBox(width: 10),

            // ── Message ───────────────────────────────────────
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "You're offline",
                    style: TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Some features may be unavailable.",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // ── Dismiss button ────────────────────────────────
            GestureDetector(
              onTap: _dismiss,
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white38,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// OPTIONAL: Global notifier so the DashboardController (or any
// service) can push offline state without needing BuildContext.
//
// Usage in your connectivity service:
//   offlineBannerNotifier.value = true;  // goes offline
//   offlineBannerNotifier.value = false; // back online
//
// Then swap _OfflineStatusBannerState.initState() to listen on it:
//   offlineBannerNotifier.addListener(() {
//     _setOffline(offlineBannerNotifier.value);
//   });
// ─────────────────────────────────────────────────────────────
final offlineBannerNotifier = ValueNotifier<bool>(false);
