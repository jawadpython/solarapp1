import 'package:flutter/material.dart';
import 'package:noor_energy/features/auth/presentation/pages/login_page.dart';
import 'package:noor_energy/features/auth/presentation/pages/login_screen.dart';
import 'package:noor_energy/features/auth/presentation/pages/register_page.dart';
import 'package:noor_energy/features/home/presentation/pages/home_page.dart';
import 'package:noor_energy/features/home/presentation/pages/home_screen.dart';
import 'package:noor_energy/features/project_study/presentation/pages/project_study_page.dart';
import 'package:noor_energy/features/project_study/presentation/pages/project_type_screen.dart';
import 'package:noor_energy/features/project_study/presentation/pages/project_form_screen.dart';
import 'package:noor_energy/features/project_study/presentation/pages/on_grid_form_screen.dart';
import 'package:noor_energy/features/project_study/presentation/pages/off_grid_form_screen.dart';
import 'package:noor_energy/features/project_study/presentation/pages/hybrid_form_screen.dart';
import 'package:noor_energy/features/project_study/presentation/pages/pumping_form_screen.dart';
import 'package:noor_energy/features/quote/screens/quote_request_screen.dart';
import 'package:noor_energy/features/installation/screens/installation_maintenance_choice_screen.dart';
import 'package:noor_energy/features/installation/screens/installation_request_screen.dart';
import 'package:noor_energy/features/installation/screens/maintenance_request_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String homeScreen = '/home-screen';
  static const String login = '/login';
  static const String loginScreen = '/login-screen';
  static const String register = '/register';
  static const String projectStudy = '/project-study';
  static const String projectType = '/project-type';
  static const String projectForm = '/project-form';
  static const String onGridForm = '/on-grid-form';
  static const String offGridForm = '/off-grid-form';
  static const String hybridForm = '/hybrid-form';
  static const String pumpingForm = '/pumping-form';
  static const String quoteRequest = '/quote-request';
  static const String installationMaintenanceChoice = '/installation-maintenance-choice';
  static const String installationRequest = '/installation-request';
  static const String maintenanceRequest = '/maintenance-request';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case projectStudy:
        return MaterialPageRoute(builder: (_) => const ProjectStudyPage());
      case projectType:
        return MaterialPageRoute(builder: (_) => const ProjectTypeScreen());
      case projectForm:
        final type = settings.arguments as String? ?? 'ON-GRID';
        return MaterialPageRoute(builder: (_) => ProjectFormScreen(projectType: type));
      case onGridForm:
        return MaterialPageRoute(builder: (_) => const OnGridFormScreen());
      case offGridForm:
        return MaterialPageRoute(builder: (_) => const OffGridFormScreen());
      case hybridForm:
        return MaterialPageRoute(builder: (_) => const HybridFormScreen());
      case pumpingForm:
        return MaterialPageRoute(builder: (_) => const PumpingFormScreen());
      case quoteRequest:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuoteRequestScreen(
            systemType: args['systemType'] as String,
            panels: args['panels'] as int,
            systemPower: args['systemPower'] as double,
            batteryCapacity: args['batteryCapacity'] as double?,
          ),
        );
      case installationMaintenanceChoice:
        return MaterialPageRoute(builder: (_) => const InstallationMaintenanceChoiceScreen());
      case installationRequest:
        return MaterialPageRoute(builder: (_) => const InstallationRequestScreen());
      case maintenanceRequest:
        return MaterialPageRoute(builder: (_) => const MaintenanceRequestScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

