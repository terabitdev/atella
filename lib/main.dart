import 'package:atella/Routes/app_pages.dart';
import 'package:atella/core/themes/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) => GetMaterialApp(
        title: 'Atella',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
// import 'package:atella/Routes/app_pages.dart';
// import 'package:atella/core/themes/app_theme.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:device_preview_plus/device_preview_plus.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(
//     DevicePreview(
//       enabled: !bool.fromEnvironment('dart.vm.product'), // Enable only in debug
//       builder: (context) => const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       useInheritedMediaQuery: true, // 👈 Necessary for DevicePreview
//       builder: (context, child) => GetMaterialApp(
//         title: 'Atella',
//         theme: AppTheme.lightTheme,
//         debugShowCheckedModeBanner: false,
//         initialRoute: AppPages.INITIAL,
//         getPages: AppPages.routes,
//         locale: DevicePreview.locale(context), // 👈 Locale from DevicePreview
//         builder: DevicePreview.appBuilder,     // 👈 Wrap app with preview builder
//       ),
//     );
//   }
// }
