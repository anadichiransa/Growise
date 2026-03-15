import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends GetxController {
  var storageGranted = false.obs;
  var notificationGranted = false.obs;
  var cameraGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkCurrentStatus();
  }

  Future<void> checkCurrentStatus() async {
    storageGranted.value = await Permission.photos.isGranted;
    notificationGranted.value = await Permission.notification.isGranted;
    cameraGranted.value = await Permission.camera.isGranted;
  }

  Future<void> requestAllPermissions() async {
    await requestStorage();
    await requestNotifications();
    await requestCamera();
  }

  Future<void> requestStorage() async {
    final status = await Permission.photos.request();
    storageGranted.value = status.isGranted;
  }

  Future<void> requestNotifications() async {
    final status = await Permission.notification.request();
    notificationGranted.value = status.isGranted;
  }

  Future<void> requestCamera() async {
    final status = await Permission.camera.request();
    cameraGranted.value = status.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  bool get allGranted =>
      storageGranted.value &&
      notificationGranted.value &&
      cameraGranted.value;
}
```
```
git add lib/features/dashboard/presentation/controllers/permission_controller.dart
git commit -m "feat: add PermissionController to handle storage, camera and notification requests"