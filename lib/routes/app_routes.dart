import 'package:flutter/material.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:turo/models/user_model.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
import '../presentation/mentor_registration_screen/institutional_verification_screen.dart';
import '../presentation/terms_and_conditions_screen/terms_and_conditions_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/user_registration_screen/user_registration_screen.dart';
import '../presentation/mentee_onboarding/pages/mentee_onboarding_page.dart';

class AppRoutes {
  static const String mentorRegistrationScreen = '/mentor_registration_screen';
  static const String idUploadScreen = '/id_upload_screen';
  static const String institutionalVerificationScreen =
      '/institutional_verification_screen';
  static const String institutionalVerificationScreen =
      '/institutional_verification_screen';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String credentialsAchievementsScreen =
      '/credentials_achievements_screen';
  static const String credentialsAchievementsScreen =
      '/credentials_achievements_screen';
  static const String selfieVerificationScreen = '/selfie_verification_screen';
  static const String emailVerificationScreen = '/email_verification_screen';
  static const String termsAndConditionsScreen = '/terms_and_conditions_screen';
  static const String splashScreen = '/splash_screen';
  static const String loginScreen = '/login_screen';
  static const String userRegistrationScreen = '/user_registration_screen';
  static const String menteeOnboardingPage = '/mentee_onboarding_page';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
        mentorRegistrationScreen: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final user = args['user'] as UserModel;
        final userDetail = args['userDetail'] as UserDetailModel;
        
        return InstitutionalVerificationScreen(user: user, userDetail: userDetail);
        },
        appNavigationScreen: (context) => AppNavigationScreen(),
        initialRoute: (context) => AppNavigationScreen(),
        termsAndConditionsScreen: (context) => TermsAndConditionsScreen(),
        splashScreen: (context) => SplashScreen(),
        loginScreen: (context) => LoginScreen(),
        userRegistrationScreen: (context) => UserRegistrationScreen(),
      };
}