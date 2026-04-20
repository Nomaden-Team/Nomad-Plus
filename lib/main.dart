import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'user/controllers/auth/login_controller.dart';
import 'user/controllers/auth/register_controller.dart';
import 'user/controllers/cart/cart_controller.dart';
import 'user/controllers/home/home_controller.dart';
import 'user/controllers/home/main_controller.dart';
import 'user/controllers/menu/menu_controller.dart';
import 'user/controllers/order/order_controller.dart';
import 'user/core/app_state.dart';
import 'user/core/constants/app_colors.dart';
import 'user/core/constants/app_text_styles.dart';
import 'user/core/routes/app_pages.dart';
import 'user/core/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Inisialisasi Controller (Gunakan permanent: true agar tidak hilang dari memory)
  if (!Get.isRegistered<CartController>())
    Get.put<CartController>(CartController(), permanent: true);
  if (!Get.isRegistered<AppStateController>())
    Get.put<AppStateController>(AppStateController(), permanent: true);
  if (!Get.isRegistered<LoginController>())
    Get.put<LoginController>(LoginController(), permanent: true);
  if (!Get.isRegistered<RegisterController>())
    Get.put<RegisterController>(RegisterController(), permanent: true);
  if (!Get.isRegistered<MainController>())
    Get.put<MainController>(MainController(), permanent: true);
  if (!Get.isRegistered<HomeController>())
    Get.put<HomeController>(HomeController(), permanent: true);
  if (!Get.isRegistered<MenuController>())
    Get.put<MenuController>(MenuController(), permanent: true);
  if (!Get.isRegistered<OrderController>())
    Get.put<OrderController>(OrderController(), permanent: true);

  runApp(const NomadApp());
}

class NomadApp extends StatelessWidget {
  const NomadApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.heading1,
        headlineMedium: AppTextStyles.heading2,
        titleLarge: AppTextStyles.heading3,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.captionBold,
        labelSmall: AppTextStyles.label,
      ),
    );

    return GetMaterialApp(
      title: 'Kedai Nomad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          brightness: Brightness.light,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primary,
        ),
        textTheme: baseTextTheme,

        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0, 
          centerTitle: true,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.cardBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceSoft,
          hintStyle: GoogleFonts.inter(
            color: AppColors.textHint,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.error, width: 1.2),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
