import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/config/firebase_config.dart';
import 'features/auth/presentation/screens/welcome_page.dart';
import 'core/config/routes.dart';
import 'shared/services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseConfig.enableFirestoreOffline();
  await Get.putAsync(() => ConnectivityService().init());
  runApp(const GrowiseApp());
}

class GrowiseApp extends StatelessWidget {
  const GrowiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Growise',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome,
      getPages: AppRoutes.pages,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
    );
  }
}
