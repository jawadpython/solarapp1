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
import 'package:noor_energy/features/partners/presentation/pages/partners_list_screen.dart';
import 'package:noor_energy/features/technicians/presentation/pages/technicians_list_screen.dart';
import 'package:noor_energy/features/intervention/presentation/pages/intervention_choice_screen.dart';
import 'package:noor_energy/features/etude_devis/presentation/pages/etude_devis_screen.dart';
import 'package:noor_energy/features/financing/presentation/pages/financing_form_screen.dart';
import 'package:noor_energy/features/espace_pro/presentation/pages/espace_pro_screen.dart';
import 'package:noor_energy/features/espace_pro/presentation/pages/partner_registration_screen.dart';
import 'package:noor_energy/features/espace_pro/presentation/pages/technician_registration_screen.dart';
import 'package:noor_energy/features/calculator/views/calculator_input_screen.dart';
import 'package:noor_energy/features/pumping/screens/pumping_input_screen.dart';
import 'package:noor_energy/features/pumping/screens/pumping_devis_form_screen.dart';
import 'package:noor_energy/core/utils/admin_access_helper.dart';

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
  static const String partnersList = '/partners-list';
  static const String techniciansList = '/technicians-list';
  static const String interventionChoice = '/intervention-choice';
  static const String etudeDevis = '/etude-devis';
  static const String financingForm = '/financing-form';
  static const String espacePro = '/espace-pro';
  static const String partnerRegistration = '/partner-registration';
  static const String technicianRegistration = '/technician-registration';
  static const String calulatorInput = '/calculator';
  static const String pumpingCalculator = '/pumping-calculator';
  static const String pumpingDevisForm = '/pumping-devis-form';
  static const String adminDashboard = '/admin-dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        // Redirect old home route to HomeScreen
        return MaterialPageRoute(builder: (_) => const HomeScreen());
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
      case partnersList:
        return MaterialPageRoute(builder: (_) => const PartnersListScreen());
      case techniciansList:
        return MaterialPageRoute(builder: (_) => const TechniciansListScreen());
      case interventionChoice:
        return MaterialPageRoute(builder: (_) => const InterventionChoiceScreen());
      case etudeDevis:
        return MaterialPageRoute(builder: (_) => const EtudeDevisScreen());
      case financingForm:
        return MaterialPageRoute(builder: (_) => const FinancingFormScreen());
      case espacePro:
        return MaterialPageRoute(builder: (_) => const EspaceProScreen());
      case partnerRegistration:
        return MaterialPageRoute(builder: (_) => const PartnerRegistrationScreen());
      case technicianRegistration:
        return MaterialPageRoute(builder: (_) => const TechnicianRegistrationScreen());
      case calulatorInput:
        return MaterialPageRoute(builder: (_) => const CalculatorInputScreen());
      case pumpingCalculator:
        return MaterialPageRoute(builder: (_) => const PumpingInputScreen());
      case pumpingDevisForm:
        final result = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => PumpingDevisFormScreen(result: result as dynamic),
        );
      case adminDashboard:
        // Admin dashboard is web-only - show dialog instead
        return MaterialPageRoute(
          builder: (context) {
            // Show dialog immediately when route is accessed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Pop the route first, then show dialog
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              // Show dialog after a short delay to ensure route is popped
              Future.delayed(const Duration(milliseconds: 100), () {
                if (context.mounted) {
                  AdminAccessHelper.showAdminAccessDialog(context);
                }
              });
            });
            // Return a temporary scaffold while dialog shows
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
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

